
require_relative '../lib/locker'
require_relative 'errors'
require 'bcrypt'
require 'json'

class App

  def initialize

    @pword_chars = {
      :lowcase => ('a'..'z').to_a,
      :highcase => ('A'..'Z').to_a,
      :digits => ('0'..'9').to_a,
      :symbols => ['!', '@', '#', '$', '%', '^', '&', '=', ':', '?', '.', '/', '|', '~', '>', '*', '(', ')', '<']
    }
    open_locker()
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

  def hash_password(password)
    BCrypt::Password.create(password)
  end

  def open_locker
    locker = File.read('data/temp_json')
    @locker = JSON.parse(locker)
  end

  def get_locker_name
    @locker['name']
  end

  def verify_pword(user_input)
    raise WrongPassword if @locker['password'] != user_input
    @locker['password'] == user_input
  end

  def get_locker_data
    @locker['data']
  end

  def get_password_names
    @locker['data']['passwords'].map {|password| password['name']}
  end
end

