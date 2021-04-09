require_relative 'locker'
require_relative 'session'
require_relative 'error'
require 'bcrypt'
require 'json'
require 'tty-prompt'
require 'artii'
require 'clipboard'

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
    @locker =nil
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

  def login
    lockers = get_lockers
    begin
      display_header()
      name = @prompt.select('Select a locker to login to:') do |locker|
        lockers.each {|name| locker.choice name, name}
      end
      password = prompt.mask('Enter password:')
      raise WrongPassword if verify_password(password, name) == false
    rescue WrongPassword
      @prompt.error("Wrong password!")
      @prompt.keypress("Press key to try again")
      retry
    end
    start_session(name, password)
    locker_menu
  end

  def locker_menu
    display_header
    input = @prompt.select("What would you like to do?") do |action|
      action.choice 'View'
      action.choice 'Add'
      action.choice 'Edit'
      action.choice 'Quit'
    end
    action_select(input)
  end

  def action_select(input)
    case input
    when 'View'
      input = show_categories
      view(input)
    when 'Add'
      input = show_categories
      add(input)
    when 'Edit'
      input = show_categories
      edit(input)
    end
  end

  def show_categories
    display_header
    input = @prompt.select('Pick a category:') do |category|
      category.choice 'passwords'
      category.choice 'servers'
      category.choice 'notes'
    end
  end

  def add(input)
    display_header
    puts "Give the entry a name and then enter username and password"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Username?")
    entry << password_prompt()
    @prompt.keypress("Press key to save password")
    @session.add_password(entry[0], entry[1], entry[2])
    @session.write_to_disk
    locker_menu
  end

  def password_prompt
    
    input = @prompt.select("Enter or generate password?") do |menu|
      menu.choice "Generate password"
      menu.choice "Enter password"
    end

    case input
    when "Generate password"
      new_password = generate_password
      puts "Generated password: #{new_password}"
      return new_password
    when "Enter password"
      begin
        password = @prompt.ask('Enter password:')
        password_verify = @prompt.ask('Enter password again to verify:')
        raise NoMatch if password != password_verify
        test_password(password)
      rescue NoMatch
        @prompt.error("Passwords don't match!")
        @prompt.keypress("Press key to try again")
        retry
      rescue ShortPassword, WeakPassword
        @prompt.error("Password isn't strong!")
        @prompt.error("We recommend changing it in the future.")
        return password
      end
      return password
    end
  end

  def view(category)
    entries = @session.list_entries(category)
    display_header()
    index = @prompt.select('Pick an entry to view:') do |entry|
      entries.each_with_index {|name, index| entry.choice name, index}
    end
    puts @session.display_entry(category, index)
    input = @prompt.select('Select an option:') do |option|
      option.choice 'Copy username to clipboard', 1
      option.choice 'Copy a password to clipboard', 2
      option.choice 'Exit', 3
    end

    case input
    when 1
      Clipboard.copy(@session.get_entry(category, index)['user'])
      locker_menu
    when 2
      Clipboard.copy(@session.get_entry(category, index)['pword'])
      locker_menu
    when 3
      locker_menu
    end
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
    raise WeakPassword if low_case < 1 || high_case < 1 || digits < 1 || symbols < 1
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
    return password
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
