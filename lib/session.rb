require 'openssl'
require 'bcrypt'
require 'json'
require 'base64'

class Session

  def initialize(name, plain_password, encrypted_data = nil)
    @name = name
    @password = plain_password
    @salt = 'thissalt'
    encrypted_data == nil ? @data = set_up() : @data = JSON.parse(decrypt_it(encrypted_data))
  end

  def set_up
    empty_data = { 'passwords' => {}, 'servers' => {}, 'notes' => {} }
    system 'mkdir', "../data/#{@name}"
    write_to_disk(empty_data)
    empty_data
  end

  def write_to_disk(data)
    hash = create_hash(@password)
    enc_data = Base64.encode64(encrypt_it(JSON.generate(data)))
    File.open("../data/#{@name}/data",'w+') do |f|
      f.write(hash)
    end
    File.open("../data/#{@name}/crypt",'w+') do |f|
      f.write(enc_data)
    end
  end

  def create_hash(password)
    BCrypt::Password.create(password)
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

  def list_entries(category)
    @data[category].map {|hash| hash['name']}
  end

  def get_entry(category, index)
    @data[category][index].map {|k,value| value}
  end

end
