require 'openssl'
require 'json'

class Locker

  def initialize(data)
    @data = data
  end

  def add_password

  end

  def get_password_names

  end

  def get_server_names

  end

  def get_notes_names

  end

  def add_password

  end

  def add_server

  end

  def add_notes

  end

  def edit_password

  end
  
  def edit_server

  end

  def edit_note

  end

  def delete_password

  end

  def delete_server

  end

  def delete_note

  end
  
  
end


# Encryption key and password both use the same user passphrase. App data file contains locker name, encrypted key, hashed password and data

# app_data = [[name. hashed_password, encrypted_key, data]]

# Locker class receives the unencrypted data only. The data contains only the saved locker contents. Locker contains all methods required to modify and read the data. 

# App takes care of UI, authentication and starting a user session.

# Session class takes care of encryption, decryption, loading and saving data. It receives name, plain password, encrypted key and encrypted data (if any) from app class. If no data is passed the session will create an empty data packet and encrypt it with key.