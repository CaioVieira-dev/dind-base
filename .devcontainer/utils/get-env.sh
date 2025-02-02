#!/bin/bash

# verify the number of arguments
if [ "$#" -ne 2 ]; then
    echo "Use: $0 <'.env' file> <key>"
    exit 1
fi

ENV_FILE=$1
KEY=$2

# Verify if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "$ENV_FILE not found!"
    exit 1
fi

# read file line by line
while IFS='=' read -r env_key env_value; do
    # trim whitespace
    env_key=$(echo $env_key | xargs)
    env_value=$(echo $env_value | xargs)

    if [ "$env_key" == "$KEY" ]; then
        echo "$env_value"
        exit 0
    fi
done < "$ENV_FILE"

# Error message
echo "Key $KEY not found in $ENV_FILE"
exit 1
