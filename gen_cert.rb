require 'rubygems'
require 'openssl'
require 'base64'

CURRENT_DIR = File.expand_path(__dir__)
EXPORTER_BIN_PATH = File.join(CURRENT_DIR, 'exporter')
COMMON_NAME = ARGV[0]
raise ArgumentError, 'Certificate CN is required' if ARGV[0].nil? || ARGV[0].empty?

CERT_DIR = 'certs'.freeze

key = OpenSSL::PKey::RSA.new(1024)
public_key = key.public_key

subject = "/C=BE/O=Test/OU=Test/CN=#{COMMON_NAME}"

cert = OpenSSL::X509::Certificate.new
cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
cert.not_before = Time.now
cert.not_after = Time.now + 365 * 24 * 60 * 60
cert.public_key = public_key
cert.serial = 0x0
cert.version = 2

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.extensions = [
  ef.create_extension('basicConstraints', 'CA:TRUE', true),
  ef.create_extension('subjectKeyIdentifier', 'hash')
  # ef.create_extension("keyUsage", "cRLSign,keyCertSign", true),
]
cert.add_extension ef.create_extension('authorityKeyIdentifier',
                                       'keyid:always,issuer:always')

cert.sign key, OpenSSL::Digest::SHA1.new

# Package
pkcs12 = OpenSSL::PKCS12.create('qwertyasdf', "#{COMMON_NAME} p12 cert", key, cert).to_der
pkcs12_base64 = Base64.encode64(pkcs12)

cert_obj = Struct.new(:cert, :key, :pkcs12, :pkcs12_base64).new(cert, key, pkcs12, pkcs12_base64)

puts cert_obj.cert.to_pem
puts '....Private key starts....'
puts cert_obj.key
puts '....pkcs12_base64 starts....'
puts cert_obj.pkcs12_base64

Dir.mkdir CERT_DIR unless Dir.exist?(CERT_DIR)
cert_path = File.join(CURRENT_DIR, CERT_DIR, "#{COMMON_NAME}.p12")
File.open(cert_path, 'wb') { |f| f << cert_obj.pkcs12 }

# Import
`sudo security -v import #{cert_path} -f pkcs12 -P qwertyasdf -T #{EXPORTER_BIN_PATH} -k /Library/Keychains/System.keychain`
puts '....done....'
