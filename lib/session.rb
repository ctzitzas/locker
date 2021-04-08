require 'openssl'
require 'bcrypt'
require 'json'

class Session

  def initialize(name, plain_password, data = nil)
    @name = name
    @password = plain_password
    @salt = 'thissalt'
    data == nil ? @data = set_up() : @data = decrypt_it(data)
  end

  def set_up
    empty_data = {
      'passwords' => {},
      'servers' => {},
      'notes' => {}
    }
    write_to_disk(empty_data)
    empty_data
  end

  def write_to_disk(data)
    hash = create_hash(@password)
    enc_data = Base64.encode64(encrypt_data(JSON.generate(data)))
    File.open("data/#{@name}/pword",'w+') do |f|
      f.write(hash)
    end
    File.open("data/#{@name}/data",'w+') do |f|
      f.write(enc_data)
    end
  end

  def create_hash(password)
    BCrypt::Password.create("my password")
  end

  def encrypt_it(data)
    encryptor = OpenSSL::Cipher.new 'AES-256-CBC'
    encryptor.encrypt
    encryptor.pkcs5_keyivgen @password, @salt
    encrypted = encryptor.update data
    encrypted << encryptor.final
  end

  def decrypt_it(data)
    decryptor = OpenSSL::Cipher.new 'AES-256-CBC'
    decryptor.decrypt
    decryptor.pkcs5_keyivgen @password, @salt
    plain = decryptor.update data
    plain << decryptor.final
  end

end
