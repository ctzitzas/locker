require 'openssl'
require 'bcrypt'
require 'json'
require 'base64'

class Session

  attr_accessor :locker

  def initialize(name, plain_password, encrypted_data = nil)
    @name = name
    @password = plain_password
    @salt = 'thissalt'
    encrypted_data == nil ? @data = set_up() : @data = JSON.parse(decrypt_it(encrypted_data))
    write_to_disk()
  end

  def set_up
    system 'mkdir', "../data/#{@name}"
    empty_data = { 'passwords' => [], 'servers' => [], 'notes' => [] }
  end

  def write_to_disk
    hash = create_hash(@password)
    enc_data = Base64.encode64(encrypt_it(JSON.generate(@data)))
    File.open("../data/#{@name}/data",'w+') do |f|
      f.write(hash)
    end
    File.open("../data/#{@name}/crypt",'w+') do |f|
      f.write(enc_data)
    end
  end

# Encryption and hash functions

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

  # Getter functions

  def get_entries(category)
    @data[category].map {|entry| entry['name']}
  end

  def get_value(category, index)
    @data[category][index]
  end

  def get_entry(category, index)
    CategoryEmpty if @data[category][index].map {|key, value| "#{key} - #{value}"}
  end

  # Add entry functions

  def add_password(name, username, password)
    @data['passwords'] << {
      'name' => name,
      'user' => username,
      'pword' => password
    }
  end

  def add_server(name, user, pword, ip_address, ports = nil , notes = nil)
    @data['servers'] << {
      'name' => name,
      'user' => user,
      'pword' => pword,
      'ip_address' => ip_address,
      'ports' => ports,
      'notes' => notes
    }
  end

  def add_note(name, note)
    @data['notes'] << {
      'name' => name,
      'note' => note
    }
  end

  # Edit entry functions

  def edit_entry(category, index, entry, new)
    @data[category][index][entry] = new
  end

  def delete_entry(category, index)
    @data[category].delete_at(index)
  end

end
