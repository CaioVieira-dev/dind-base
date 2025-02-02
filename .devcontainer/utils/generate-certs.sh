#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ENV_FILE="$SCRIPT_DIR/../.env"
GET_ENV="$SCRIPT_DIR/get-env.sh"

CERTS_DIR=$($GET_ENV $ENV_FILE "CERTS_DIR")

if [ -z "$CERTS_DIR" ]; then
    echo "Error: CERTS_DIR not found at '.devcontainer/.env'"
    exit 1
fi

COUNTRY_NAME=$($GET_ENV $ENV_FILE COUNTRY_NAME)

if [ -z "$COUNTRY_NAME" ]; then
    echo "Error: COUNTRY_NAME not found at '.devcontainer/.env'"
    exit 1
fi

STATE_NAME=$($GET_ENV $ENV_FILE STATE_NAME)

if [ -z "$STATE_NAME" ]; then
    echo "Error: STATE_NAME not found at '.devcontainer/.env'"
    exit 1
fi

LOCALITY_NAME=$($GET_ENV $ENV_FILE LOCALITY_NAME)

if [ -z "$LOCALITY_NAME" ]; then
    echo "Error: LOCALITY_NAME not found at '.devcontainer/.env'"
    exit 1
fi

ORGANIZATION_NAME=$($GET_ENV $ENV_FILE ORGANIZATION_NAME)

if [ -z "$ORGANIZATION_NAME" ]; then
    echo "Error: ORGANIZATION_NAME not found at '.devcontainer/.env'"
    exit 1
fi

ORGANIZATIONAL_UNIT=$($GET_ENV $ENV_FILE ORGANIZATIONAL_UNIT)

if [ -z "$ORGANIZATIONAL_UNIT" ]; then
    echo "Error: ORGANIZATIONAL_UNIT not found at '.devcontainer/.env'"
    exit 1
fi

COMMON_NAME=$($GET_ENV $ENV_FILE COMMON_NAME)

if [ -z "$COMMON_NAME" ]; then
    echo "Error: COMMON_NAME not found at '.devcontainer/.env'"
    exit 1
fi

EMAIL_ADDRESS=$($GET_ENV $ENV_FILE EMAIL_ADDRESS)

if [ -z "$EMAIL_ADDRESS" ]; then
    echo "Error: EMAIL_ADDRESS not found at '.devcontainer/.env'"
    exit 1
fi

PEM_PASS_PHRASE=$($GET_ENV $ENV_FILE PEM_PASS_PHRASE)

if [ -z "$PEM_PASS_PHRASE" ]; then
    echo "Error: PEM_PASS_PHRASE not found at '.devcontainer/.env'"
    exit 1
fi

SERVER_CONF="$CERTS_DIR/server-openssl.cnf"

# Create certs folder
mkdir -p $CERTS_DIR

# Generate CA key
openssl genrsa -aes256  -passout pass:"$PEM_PASS_PHRASE" -out $CERTS_DIR/ca-key.pem 4096
chmod 400 $CERTS_DIR/ca-key.pem

# Generate CA certificate
openssl req -new -x509 -days 365 -key "$CERTS_DIR/ca-key.pem" -sha256 -out "$CERTS_DIR/ca.pem" -subj "/C=$COUNTRY_NAME/ST=$STATE_NAME/L=$LOCALITY_NAME/O=$ORGANIZATION_NAME/OU=$ORGANIZATIONAL_UNIT/CN=client/emailAddress=$EMAIL_ADDRESS" -passin pass:"$PEM_PASS_PHRASE"

# Create server config file
cat > $SERVER_CONF <<EOL
[ req ]
default_bits       = 4096
default_md         = sha256
default_keyfile    = server-key.pem
prompt             = no
encrypt_key        = yes

distinguished_name = req_distinguished_name
req_extensions     = req_ext

[ req_distinguished_name ]
C = $COUNTRY_NAME
ST = $STATE_NAME
L = $LOCALITY_NAME
O = $ORGANIZATION_NAME
OU = $ORGANIZATIONAL_UNIT
CN = $COMMON_NAME
emailAddress = $EMAIL_ADDRESS

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOL

# generate server key
openssl genrsa -out "$CERTS_DIR/server-key.pem" 4096
chmod 400 "$CERTS_DIR/server-key.pem"

# generate server CSR
openssl req -new -key "$CERTS_DIR/server-key.pem" -out "$CERTS_DIR/server.csr" -config "$SERVER_CONF"

# sign server CSR with CA key
openssl x509 -req -days 365 -in "$CERTS_DIR/server.csr" -CA "$CERTS_DIR/ca.pem" -CAkey "$CERTS_DIR/ca-key.pem" -CAcreateserial -out "$CERTS_DIR/server-cert.pem" -extensions req_ext -extfile "$SERVER_CONF" -passin pass:"$PEM_PASS_PHRASE"
chmod 444 "$CERTS_DIR/server-cert.pem"

# generate client key
openssl genrsa -out "$CERTS_DIR/key.pem" 4096
chmod 400 "$CERTS_DIR/key.pem"

# generate client CSR
openssl req -subj "/C=$COUNTRY_NAME/ST=$STATE_NAME/L=$LOCALITY_NAME/O=$ORGANIZATION_NAME/OU=$ORGANIZATIONAL_UNIT/CN=client/emailAddress=$EMAIL_ADDRESS" -new -key "$CERTS_DIR/key.pem" -out "$CERTS_DIR/client.csr"

# sign client CSR with CA key
openssl x509 -req -days 365 -in "$CERTS_DIR/client.csr" -CA "$CERTS_DIR/ca.pem" -CAkey "$CERTS_DIR/ca-key.pem" -CAcreateserial -out "$CERTS_DIR/cert.pem" -passin pass:"$PEM_PASS_PHRASE"
chmod 444 "$CERTS_DIR/cert.pem"

# Clear tem files
rm "$CERTS_DIR/client.csr" "$CERTS_DIR/server.csr" "$CERTS_DIR/ca.srl"

echo "Certificados gerados com sucesso em: $CERTS_DIR"