#!/bin/bash

# Usage: ./verify_stores.sh keystore.p12 truststore.p12

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <keystore_file> <truststore_file>"
    exit 1
fi

KEYSTORE="$1"
TRUSTSTORE="$2"

# Check if files exist
[ ! -f "$KEYSTORE" ] && { echo "Error: Keystore file '$KEYSTORE' not found."; exit 1; }
[ ! -f "$TRUSTSTORE" ] && { echo "Error: Truststore file '$TRUSTSTORE' not found."; exit 1; }

# Get passwords
read -sp "Enter keystore password: " KEYSTORE_PASS
echo
read -sp "Enter truststore password: " TRUSTSTORE_PASS
echo

echo "Verifying Keystore..."
keytool -list -v -keystore "$KEYSTORE" -storetype PKCS12 -storepass "$KEYSTORE_PASS" | grep -E "Alias name|Entry type"

echo "Verifying Truststore..."
keytool -list -v -keystore "$TRUSTSTORE" -storetype PKCS12 -storepass "$TRUSTSTORE_PASS" | grep -E "Alias name|Entry type"
