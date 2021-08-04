require 'openssl'

CURRENT_DIR = File.expand_path(__dir__)
CERT_PATH = File.join(CURRENT_DIR, 'certs', "exported_#{ARGV[0]}.p12")
p12 = OpenSSL::PKCS12.new(File.binread(CERT_PATH), "")

puts p12
key = p12.key
certificate = p12.certificate

puts key
puts certificate
