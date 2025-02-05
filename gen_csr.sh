CERT_DIR="claim-certs"
PUBLIC_KEY_OUTFILE="$CERT_DIR/public.pem.key"
PRIVATE_KEY_OUTFILE="$CERT_DIR/private.pem.key"
CSR_KEY_OUTFILE="$CERT_DIR/csr.pem"

# Create the claim-certs directory if it doesn't exist
mkdir -p $CERT_DIR

# Create private key, public key and csr
openssl ecparam -genkey -name prime256v1 -noout -out $PRIVATE_KEY_OUTFILE
openssl ec -in $PRIVATE_KEY_OUTFILE -pubout -out $PUBLIC_KEY_OUTFILE
openssl req -new -key $PRIVATE_KEY_OUTFILE -out $CSR_KEY_OUTFILE
