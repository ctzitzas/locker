require 'openssl'
require 'json'

class Locker

  def initialize(data)
    @data = data
  end

  def get_entry_names(category)
    @data[category].map { |hash| hash['name']}
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
