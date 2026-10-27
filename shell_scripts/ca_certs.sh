# Point HTTPS clients at the system's certificate store, which has corporate root
# certificates (Bloomberg re-signs HTTPS traffic with its own). mise's prebuilt Ruby
# and Python bring their own OpenSSL, which doesn't look there, and Node only reads
# the store named in NODE_EXTRA_CA_CERTS. Values already set are left alone.
if [ -z "${SSL_CERT_FILE:-}" ]; then
  for _ca_file in \
    /opt/homebrew/etc/openssl@3/cert.pem \
    /usr/local/etc/openssl@3/cert.pem \
    /etc/pki/tls/certs/ca-bundle.crt \
    /etc/ssl/certs/ca-certificates.crt; do
    if [ -f "$_ca_file" ]; then
      export SSL_CERT_FILE="$_ca_file"
      break
    fi
  done
  unset _ca_file
fi
if [ -z "${NODE_EXTRA_CA_CERTS:-}" ] && [ -n "${SSL_CERT_FILE:-}" ]; then
  export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"
fi
