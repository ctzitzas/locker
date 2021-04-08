require_relative 'locker'
require_relative 'session'
require_relative 'error'
require 'bcrypt'
require 'json'

class App < Session

  def initialize

    @pword_chars = {
      :lowcase => ('a'..'z').to_a,
      :highcase => ('A'..'Z').to_a,
      :digits => ('0'..'9').to_a,
      :symbols => ['!', '@', '#', '$', '%', '^', '&', '=', ':', '?', '.', '/', '|', '~', '>', '*', '(', ')', '<']
    }

    @session = nil
  end

  def test_password(password)
    
    low_case = 0
    high_case = 0
    digits = 0
    symbols = 0
    char_arr = password.split('')
    char_arr.each do |char| 
      low_case += 1 if @pword_chars[:lowcase].include?(char) 
      high_case += 1 if @pword_chars[:highcase].include?(char)
      digits += 1 if @pword_chars[:digits].include?(char)
      symbols += 1 if @pword_chars[:symbols].include?(char)
    end

    begin
      raise ShortPassword if char_arr.length <= 7
      if low_case < 1 || high_case < 1 || digits < 1 || symbols < 1
        raise WeakPassword
      end
    end

    return true
  end

  def generate_password
    password_letter_categories = [:lowcase, :highcase]
    begin
    password =[]
      1.times { password << @pword_chars[:digits].sample }
      1.times { password << @pword_chars[:symbols].sample }
      6.times { password << @pword_chars[password_letter_categories.sample].sample }
      password = password.shuffle.join
      raise if test_password(password) == false
    rescue
      retry
    end
    password
  end

  def verify_hash(password, hash)
    verify = BCrypt::Password.new(hash)
    password == verify
  end

  def get_lockers()
    Dir.chdir('./data')
    Dir.glob('*').select {|f| File.directory? f}
  end

  def start_session(index, password)
    name = get_lockers()
    data = Base64.decode64(File.read("./#{name[index]}/data"))
    @session = Session.new(name[index], password, data)
  end

end
