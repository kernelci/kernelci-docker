FQDN="kci.org"

## Generate server Key
openssl genrsa -out ./server-key.pem 2048
echo "-> Server key created"

## Generate signing request using configuration file
openssl req -new -key ./server-key.pem -out ./server.csr -config $FQDN.cnf
echo "-> Server csr issued"

## Sign server certificate with Root CA
echo "subjectAltName = DNS.1:$FQDN,DNS.2:www.$FQDN,IP:127.0.0.1" > extfile-san.cnf
openssl x509 -req -days 365 -in ./server.csr -CA ./ca.pem -CAkey ./ca-key.pem -CAcreateserial -out ./server-cert.pem -extfile ./extfile-san.cnf
echo "-> Server certificate signed by Root CA"

# Set key/cert access rights
chmod -v 0400 ./server-key.pem
chmod -v 0444 ./server-cert.pem

# Create Server bundle (if needed)
cat ./server-cert.pem ./ca.pem > ./server-cert-bundle.pem

# Cleanup
rm ./server.csr
