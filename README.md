## Keychain cert import/export POC
This POC implements -
1. A ruby script to import cert (with priv key)
2. A golang script/binary to export cert
3. Ruby script to read/parse exported cert

### Setup
For exporter binary build, use `go build exporter.go` (after go modules setup)

### Usage
1. Generate/import cert `ruby gen_cert.rb testcert`
2. Export cert `./exporter testcert`

**Note**: Cert name passed as argument should be a valid subject CN

### Additional Resources
- https://developer.apple.com/documentation/security/keychain_services?language=objc
- https://developer.apple.com/documentation/security/certificate_key_and_trust_services/keys/storing_keys_in_the_secure_enclave?language=objc
