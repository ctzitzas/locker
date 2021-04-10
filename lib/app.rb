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
    @name = nil
    @password = nil
  end

  def run
    while true
      display_header()
      input = @prompt.select('Menu') do |menu|
        menu.choice "Create new locker", 1
        menu.choice "Open locker", 2
        menu.choice "Quit", 3
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
      create_locker_menu
    when 2
      login_menu
    when 3
      system 'clear'
      exit
    end
  end

  # Locker creation display

  def create_locker_menu
    begin
      display_header()
      create_locker_prompt()
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
    create_success()
  end

  def create_locker_prompt
      @name = @prompt.ask("Name your locker:")
      @password = @prompt.mask("Enter a password:")
      password_verify = @prompt.mask("Confirm password:")
      raise NoMatch if @password != password_verify
      raise NameTaken if get_lockers.include? name
      test_password(@password)
  end

  def create_success
    Session.new(@name, @password)
    puts "Locker creation sucessful!"
    puts 'Login to start adding passwords'
    @prompt.keypress('Press key to return to main menu')
  end

  # Locker login display

  def login_menu
    display_header()
    display_login()
    begin
      @password = @prompt.mask('Enter password:')
      raise WrongPassword if verify_password(@password, @name) == false
    rescue WrongPassword
      @prompt.error("Wrong password!")
      retry
    end
    start_session(@name, @password)
    session_menu
  end

  def display_login
    lockers = get_lockers
    @name = @prompt.select('Select a locker to login to:') do |locker|
      lockers.each {|name| locker.choice name, name}
    end
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
    @session = Session.new(@name, @password, load_data)
  end

  def load_data()
    Base64.decode64(File.read("../data/#{@name}/crypt"))
  end

  # Display session display

  def session_menu
    display_header
    input = @prompt.select("What would you like to do?") do |action|
      action.choice 'View'
      action.choice 'Add'
      action.choice 'Edit'
      action.choice 'Quit session'
    end
    action_select(input)
  end

  def action_select(input)
    case input
    when 'View'
      view_menu(select_category)
    when 'Add'
      add_menu(select_category)
    when 'Edit'
      edit_menu(select_category)
    when 'Quit session'
      @session = nil
    end
  end

  def select_category
    display_header
    @prompt.select('Pick a category:') do |category|
      category.choice 'passwords'
      category.choice 'servers'
      category.choice 'notes'
    end
  end

  # View entry display

  def view_menu(category)
    entries = @session.get_entries(category)
    begin
      raise CategoryEmpty if entries == []
    rescue
      @prompt.error('No entries in category!')
      @prompt.keypress("Press key to return to menu.")
      session_menu
    end
    display_header()
    entry_index = @prompt.select('Pick an entry to view:') do |entry|
      entries.each_with_index {|name, index| entry.choice name, index}
    end
    puts @session.get_entry(category, entry_index)
    view_select(category, view_options, entry_index)
  end

  def view_options
    @prompt.select('Select an option:') do |option|
      option.choice 'Copy username to clipboard', 1
      option.choice 'Copy a password to clipboard', 2
      option.choice 'Exit', 3
    end
  end

  def view_select(category, option, entry_index)
    case option
    when 1
      Clipboard.copy(@session.get_value(category, entry_index)['user'])
      display_header
      @prompt.ok('Copied to clipboard!')
      @prompt.keypress('Press key to return to menu')
      session_menu
    when 2
      Clipboard.copy(@session.get_value(category, entry_index)['pword'])
      display_header
      @prompt.ok('Copied to clipboard!')
      @prompt.keypress('Press key to return to menu')
      session_menu
    when 3
      session_menu
    end
  end

  # Add entry display

  def add_menu(category)
    case category
    when 'passwords'
      add_password_entry(category)
    when 'servers'
      add_server_entry(category)
    when 'notes'
      add_note_entry(category)
    end
  end

  def add_password_entry
    display_header
    puts "Enter details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Username?")
    entry << password_prompt()
    @prompt.keypress("Press key to save password")
    @session.add_password(entry[0], entry[1], entry[2])
    @session.write_to_disk
    @session = Session.new
    session_menu
  end

  def add_server_entry(category)
    display_header
    puts "Enter details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Username?")
    entry << password_prompt()
    entry << @prompt.ask('Ip address?')
    entry << @prompt.ask('Notes?')
    @prompt.keypress("Press key to save server")
    @session.add_server(entry[0], entry[1], entry[2], entry[3], entry[4])
    save_add
  end

  def add_note_entry(category)
    display_header
    puts "Enter details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Note?")
    @prompt.keypress("Press key to save note")
    @session.add_note(entry[0], entry[1])
    save_add
  end

  def save_add
    @session.write_to_disk
    @session = Session.new(@name, @password, load_data)
    @prompt.ok('Entry added!')
    @prompt.keypress('Press key to continue')
    session_menu
  end

  def password_prompt
    input = @prompt.select("Enter or generate password?") do |menu|
      menu.choice "Generate password"
      menu.choice "Enter password"
    end
    password_option
  end
  
  def password_option
    case input
    when "Generate password"
      new_password = generate_password
      puts "Generated password: #{new_password}"
      new_password
    when "Enter password"
      enter_password
    end
  end

  def enter_password
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

  # Edit entry display

  def edit_menu(category)
    entries = @session.get_entries(category)
    display_header
    index = @prompt.select('Pick an entry to edit;') do |entry|
      entries.each_with_index {|name, index| entry.choice name, index}
    end
    puts @session.get_entry(category, index)
    input = edit_prompt
    edit_entry(category, input, index)
  end

  def edit_prompt
    @prompt.select('Select an option:') do |option|
      option.choice 'Edit name', 1
      option.choice 'Edit username', 2
      option.choice 'Edit password', 3
      option.choice 'Delete entry', 4
      option.choice 'Exit', 5
    end
  end

  def edit_entry(category, input, index)
    case category
    when 'passwords'
      edit_password
    when 'servers'
      edit_server
    when 'notes'
      edit_notes
    end
  end

  def edit_password
    case input
    when 1
      new_name = @prompt.ask('Enter the new name:')
      @session.edit_entry(category, index, 'name', new_name)
      @session.write_to_disk
      @prompt.keypress("Edit success! Press a key to exit")
      session_menu
    when 2
      new_username = @prompt.ask('Enter the new username:')
      @session.edit_entry(category, index, 'username', new_username)
      @session.write_to_disk
      @prompt.keypress("Edit success! Press a key to exit")
      session_menu
    when 3
      new_password = password_prompt
      @session.edit_entry(category, index, 'password', new_password)
      @session.write_to_disk
      @prompt.keypress("Edit success! Press a key to exit")
      session_menu
    when 4
      @session.delete_entry(category, index)
      @session.write_to_disk
      @prompt.keypress("Deleted! Press a key to exit")
      session_menu
    when 5
    end
  end

  # Password and authorisation functions

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
    hash == password
  end
end