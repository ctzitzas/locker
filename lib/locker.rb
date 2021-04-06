require 'openssl'
require 'json'

class Locker

  def initialize(name, password, data = create_data())
    @name = name
    @password = password
    @data = data
    @locker = create_locker()
  end
  
  def create_data
    {
      'passwords' => [],
      'servers' => [],
      'notes' => []
    }
  end

  def create_locker
    { 
      'name' => @name,
      'password' => @password,
      'data' => @data
    }
  end

  def create_file()
    File.open('data/temp_json','w+') do |f|
      f.write(@locker.to_json)
    end
  end
  
end

lock = Locker.new('Chris', 'Password')
lock.create_file