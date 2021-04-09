require_relative 'locker'
require_relative 'session'
require_relative 'error'
require 'bcrypt'
require 'json'
require 'tty-prompt'
require 'artii'

class App 

  attr_accessor :prompt

  def initialize

    @pword_chars = {
      :lowcase => ('a'..'z').to_a,
      :highcase => ('A'..'Z').to_a,
      :digits => ('0'..'9').to_a,
      :symbols => ['!', '@', '#', '$', '%', '^', '&', '=', ':', '?', '.', '/', '|', '~', '>', '*', '(', ')', '<']
    }
    @prompt = TTY::Prompt.new
    @artii = Artii::Base.new :font => 'slant'
    @session = nil
  end

  def run
    while true
      display_header()
      input = @prompt.select('Menu') do |menu|
        menu.choice "Create new locker", 1
        menu.choice "Open locker", 2
        menu.choice "Exit", 3
      end
      process_main_menu(input)
    end
  end

  def display_header()
    system 'clear'
    puts '-' * 52
    puts @artii.asciify('   Locker!   ')
    puts '          Secure local password storage'
    puts '            Developed by Chris Tzitzas'
    puts '-' * 52
  end

  def process_main_menu(choice)
    case choice
    when 1
      create_locker
    when 2
      login
    when 3
      system 'clear'
      exit
    end
  end

  def create_locker
    begin
      display_header()
      results = []
      name = @prompt.ask("Name your locker:")
      password = @prompt.mask("Enter a password:")
      password_verify = @prompt.mask("Confirm password:")
      raise NoMatch if password != password_verify
      raise NameTaken if get_lockers.include? name
      test_password(password)
    rescue NoMatch
      @prompt.error("Passwords don't match!")
      @prompt.keypress("Press key to try again")
      retry
    rescue NameTaken
      @prompt.error("Locker name taken!")
      @prompt.keypress("Press key to try again")
      retry
    rescue ShortPassword
      @prompt.error("Password must be at least 8 characters long!")
      @prompt.keypress("Press key to try again")
      retry
    rescue WeakPassword
      @prompt.error("Weak password!")
      puts "Passwords must contain:"
      puts "One lower case letter"
      puts "One upper case letter"
      puts "One digit"
      puts "One symbol"
      @prompt.keypress("Press key to try again")
      retry
    end
    Session.new(name, password)
    puts "Locker creation sucessful!"
    puts 'Login to start adding passwords'
    @prompt.keypress('Press key to return to main menu')
  end

  def test_password(password)
    
    low_case = high_case = digits = symbols = 0
    char_arr = password.split('')
    char_arr.each do |char| 
      low_case += 1 if @pword_chars[:lowcase].include?(char) 
      high_case += 1 if @pword_chars[:highcase].include?(char)
      digits += 1 if @pword_chars[:digits].include?(char)
      symbols += 1 if @pword_chars[:symbols].include?(char)
    end
      
    raise ShortPassword if char_arr.length < 8
    if low_case < 1 || high_case < 1 || digits < 1 || symbols < 1
      raise WeakPassword
    end
    return true
  end

  def generate_password
    letter_categories = [:lowcase, :highcase]
    begin
      password =[]
      rand(1..2).times { password << @pword_chars[:digits].sample }
      rand(1..3).times { password << @pword_chars[:symbols].sample }
      rand(3..5).times { password << @pword_chars[letter_categories.sample].sample }
      password = password.shuffle.join
      raise if test_password(password) == false
    rescue
      retry
    end
  end

  def verify_password(password, name)
    hash = BCrypt::Password.new(File.read("../data/#{name}/data"))
    hash == password.chomp
  end

  def get_lockers()
    begin
      Dir.chdir('./data')
      Dir.glob('*').select {|f| File.directory? f}
    rescue
      Dir.chdir('../data')
      Dir.glob('*').select {|f| File.directory? f}
    end
  end

  def start_session(name, password)
    data = Base64.decode64(File.read("../data/#{name}/crypt"))
    @session = Session.new(name, password, data)
  end

end
