require 'openssl'
require 'json'

class Locker

  def initialize(data)
    @data = data
  end

  def get_entry_names(category)
    @data[category].map { |hash| hash['name']}
  end

  def add_password(name, username, password)
    @data['passwords'] << {
      'name' => name,
      'user' => username,
      'pword' => password
    }
    @data
  end

  def add_server(name, user, pword, ip_address, ports = nil, notes = nil)
    @data['servers'] << {
      'name' => name,
      'user' => user,
      'pword' => pword,
      'ip_address' => ip_address,
      'ports' => ports,
      'notes' => notes
    }
    @data
  end

  def add_note(name, note)
    @data['notes'] << {
      'name' => name,
      'note' => note
    }
    @data

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
