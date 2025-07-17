#!/bin/bash

# Usage: ./extract_pfx.sh your_certificate.pfx

# Check if OpenSSL is installed
if ! command -v openssl &> /dev/null; then
    echo "Error: OpenSSL is not installed. Please install it first."
    exit 1
fi

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <pfx-file>"
    exit 1
fi

PFX_FILE="$1"
CRT_FILE="${PFX_FILE%.pfx}.crt"
KEY_FILE="${PFX_FILE%.pfx}.key"

# Check if PFX file exists
if [ ! -f "$PFX_FILE" ]; then
    echo "Error: PFX file '$PFX_FILE' not found."
    exit 1
fi

# Extract certificate (CRT)
echo "Extracting certificate to $CRT_FILE..."
openssl pkcs12 -in "$PFX_FILE" -clcerts -nokeys -out "$CRT_FILE" || {
    echo "Error: Failed to extract certificate."
    exit 1
}

# Extract private key (KEY)
echo "Extracting private key to $KEY_FILE..."
openssl pkcs12 -in "$PFX_FILE" -nocerts -out "$KEY_FILE" || {
    echo "Error: Failed to extract private key."
    exit 1
}

# Set appropriate permissions for the key file
chmod 600 "$KEY_FILE"

echo "Conversion completed successfully!"
echo "Certificate: $CRT_FILE"
echo "Private Key: $KEY_FILE"
