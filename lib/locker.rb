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
  end

  def add_note(name, note)
    @data['notes'] << {
      'name' => name,
      'note' => note
    }
  end

  def edit_entry(category, index, entry, new)
    @data[category][index][entry] = new
  end


  def delete_entry(category, index)
    @data[category].delete_at(index)
  end
  
  
end
