
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
  
end
