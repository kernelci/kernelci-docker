rm -rf CA/*.pem

# Create CA key
openssl genrsa -aes256 -out ./ca-key.pem 2048
echo "-> Root CA key created"

# Create CA self signed certificate
openssl req -new -x509 -days 365 -key ./ca-key.pem -sha256 -config ./kci.ca.cnf -out ./ca.pem
echo "-> Root CA cert created"

# Set key/cert access rights
chmod -v 0400 ./ca-key.pem
chmod -v 0444 ./ca.pem
