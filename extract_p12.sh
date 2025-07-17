#!/bin/bash

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo "Error: OpenSSL is not installed. Please install it first."
    exit 1
fi

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input.p12>"
    exit 1
fi

P12_FILE="$1"
CRT_FILE="${P12_FILE%.p12}.crt"
KEY_FILE="${P12_FILE%.p12}.key"

# Check if input file exists
if [ ! -f "$P12_FILE" ]; then
    echo "Error: File $P12_FILE not found."
    exit 1
fi

# Prompt for p12 password
read -sp "Enter the password for $P12_FILE: " P12_PASSWORD
echo

# Extract certificate
openssl pkcs12 -in "$P12_FILE" -clcerts -nokeys -out "$CRT_FILE" -passin pass:"$P12_PASSWORD"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract certificate."
    exit 1
fi

# Extract private key
openssl pkcs12 -in "$P12_FILE" -nocerts -out "$KEY_FILE" -passin pass:"$P12_PASSWORD" -passout pass:"$P12_PASSWORD"
if [ $? -ne 0 ]; then
    echo "Error: Failed to extract private key."
    exit 1
fi

# Remove password from private key (optional, comment out if you want to keep the password)
openssl rsa -in "$KEY_FILE" -out "$KEY_FILE" -passin pass:"$P12_PASSWORD"
if [ $? -ne 0 ]; then
    echo "Error: Failed to remove password from private key."
    exit 1
fi

echo "Successfully extracted:"
echo "Certificate: $CRT_FILE"
echo "Private key: $KEY_FILE"
