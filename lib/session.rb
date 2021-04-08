require 'openssl'
require 'bcrypt'
require 'json'

class Session

  def initialize(name, plain_password, iv = nil , encrypted_key = nil , data = nil)
    @name = name
    @password = plain_password
    @iv = iv
    @key = encrypted_key
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
    enc_data = encrypt_data(data, @password)
    enc_key = encrypt_key(@key, @password)
    iv = @iv
    pp hash
    pp enc_data
    pp enc_key
    pp iv
    File.open("data/#{@name}/pword",'w+') do |f|
      f.write(hash)
    end
    File.open("data/#{@name}/data",'w+') do |f|
      f.write(enc_data)
    end
    File.open("data/#{@name}/key",'w+') do |f|
      f.write(enc_key)
    end
    File.open("data/#{@name}/iv",'w+') do |f|
      f.write(@iv)
    end
    
    

  end

  # def save_file(data)
  #   @locker = [ @name, create_hash(@password), encrypt_it(data, @password), enc@key, @iv ]
  #   File.open("data/#{@name}",'w+') do |f|
  #     f.write(@locker.to_json)
  #   end
  # end

  def create_hash(password)
    BCrypt::Password.create("my password")
  end


  def encrypt_data(data, password)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    @key = Digest::SHA256.digest password
    cipher.key = @key
    @iv = cipher.random_iv
    cipher.update(data.to_json) + cipher.final
  end

  def encrypt_key(key, password)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = @key
    cipher.iv = @iv
    cipher.update(key) + cipher.final
  end

  def decrypt_it(data)
    decipher = OpenSSL::Cipher.new('aes-256-cbc')
    decipher.decrypt
    decipher.iv = @iv
    decipher.key = @key
    decipher.update(data) + decipher.final
  end

end

session = Session.new('temp', 'temporary')

# Encryption key and password both use the same user passphrase. App data file contains locker name, encrypted key, hashed password and data

# app_data = [[name. hashed_password, data, encrypted_key, iv]]

# Locker class receives the unencrypted data only. The data contains only the saved locker contents. Locker contains all methods required to modify and read the data. 

# App takes care of UI, authentication, loading data and starting a user session.

# Session class takes care of encryption, decryption and saving data. It receives name, plain password, encrypted key and encrypted data (if any) from app class. If no data is passed the session will create an empty data packet and encrypt it with key.