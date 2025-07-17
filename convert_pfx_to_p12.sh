#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required tools
if ! command_exists openssl; then
    echo "Error: OpenSSL is not installed. Please install it first."
    exit 1
fi

if ! command_exists keytool; then
    echo "Error: keytool is not installed. Please install Java JDK first."
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 <input_pfx_file> <output_keystore_name> <output_truststore_name>"
    echo "Example: $0 certificate.pfx mykeystore.p12 mytruststore.p12"
    exit 1
}

# Check if correct number of arguments are provided
if [ "$#" -ne 3 ]; then
    usage
fi

INPUT_PFX="$1"
KEYSTORE_OUT="$2"
TRUSTSTORE_OUT="$3"

# Check if input file exists
if [ ! -f "$INPUT_PFX" ]; then
    echo "Error: Input PFX file '$INPUT_PFX' does not exist."
    exit 1
fi

# Get passwords
read -sp "Enter PFX file password: " PFX_PASS
echo
read -sp "Enter new keystore password: " KEYSTORE_PASS
echo
read -sp "Enter new truststore password: " TRUSTSTORE_PASS
echo

# Temporary files
TEMP_KEY="temp_key.pem"
TEMP_CERT="temp_cert.pem"
TEMP_P12="temp.p12"

# Cleanup function
cleanup() {
    rm -f "$TEMP_KEY" "$TEMP_CERT" "$TEMP_P12"
}

# Trap to ensure cleanup on exit
trap cleanup EXIT

# Extract private key and certificate from PFX
echo "Extracting private key and certificate..."
if ! openssl pkcs12 -in "$INPUT_PFX" -nocerts -out "$TEMP_KEY" -passin pass:"$PFX_PASS" -passout pass:"$KEYSTORE_PASS" 2>/dev/null; then
    echo "Error: Failed to extract private key from PFX file. Check PFX password."
    exit 1
fi

if ! openssl pkcs12 -in "$INPUT_PFX" -clcerts -nokeys -out "$TEMP_CERT" -passin pass:"$PFX_PASS" 2>/dev/null; then
    echo "Error: Failed to extract certificate from PFX file. Check PFX password."
    exit 1
fi

# Create temporary PKCS12 file
echo "Creating temporary PKCS12 file..."
if ! openssl pkcs12 -export -in "$TEMP_CERT" -inkey "$TEMP_KEY" -out "$TEMP_P12" -passin pass:"$KEYSTORE_PASS" -passout pass:"$KEYSTORE_PASS" -name keyAlias 2>/dev/null; then
    echo "Error: Failed to create temporary PKCS12 file."
    exit 1
fi

# Create keystore
echo "Creating keystore..."
if ! keytool -importkeystore -srckeystore "$TEMP_P12" -srcstoretype PKCS12 -srcstorepass "$KEYSTORE_PASS" \
    -destkeystore "$KEYSTORE_OUT" -deststoretype PKCS12 -deststorepass "$KEYSTORE_PASS" -noprompt 2>/dev/null; then
    echo "Error: Failed to create keystore."
    exit 1
fi

# Create truststore (only certificates)
echo "Creating truststore..."
if ! keytool -importcert -file "$TEMP_CERT" -keystore "$TRUSTSTORE_OUT" -storetype PKCS12 \
    -storepass "$TRUSTSTORE_PASS" -alias certAlias -noprompt 2>/dev/null; then
    echo "Error: Failed to create truststore."
    exit 1
fi

echo "Successfully created:"
echo "Keystore: $KEYSTORE_OUT"
echo "Truststore: $TRUSTSTORE_OUT"

# Cleanup is handled by trap
