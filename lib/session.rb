module Session

  def data_menu
    display_header
    input = @prompt.select("What would you like to do?") do |action|
      action.choice 'View'
      action.choice 'Add'
      action.choice 'Edit'
      action.choice 'Main menu'
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
    when 'Main menu'
      @data = nil
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
    entries = @data.get_entries(category)
    rescue_no_entries(entries)
    display_header()
    entry_index = @prompt.select('Pick an entry to view:') do |entry|
      entries.each_with_index {|name, index| entry.choice name, index}
    end
    puts @data.get_entry(category, entry_index)
    input = view_options
    view_select(category, input, entry_index)
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
      Clipboard.copy(@data.get_value(category, entry_index)['user'])
      @prompt.ok('Copied to clipboard!')
      @prompt.keypress('Press key to return to menu')
      data_menu
    when 2
      Clipboard.copy(@data.get_value(category, entry_index)['pword'])
      @prompt.ok('Copied to clipboard!')
      @prompt.keypress('Press key to return to menu')
      data_menu
    when 3
      data_menu
    end
  end

  def rescue_no_entries(entries)
    begin
      raise CategoryEmpty if entries == []
    rescue
      @prompt.error('No entries in category!')
      @prompt.keypress("Press key to return to menu.")
      data_menu
    end
  end

  # Add entry display

  def add_menu(category)
    case category
    when 'passwords'
      add_password_entry()
    when 'servers'
      add_server_entry()
    when 'notes'
      add_note_entry()
    end
  end

  def add_password_entry
    display_header
    puts "Enter site details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Username?")
    entry << password_prompt()
    @data.add_password(entry[0], entry[1], entry[2])
    save_add
  end

  def add_server_entry()
    display_header
    puts "Enter server details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Username?")
    entry << password_prompt()
    entry << @prompt.ask('Ip address?')
    entry << @prompt.ask('Notes?')
    @data.add_server(entry[0], entry[1], entry[2], entry[3], entry[4])
    save_add
  end

  def add_note_entry()
    display_header
    puts "Enter note details:"
    entry = []
    entry << @prompt.ask("Name?")
    entry << @prompt.ask("Note?")
    @data.add_note(entry[0], entry[1])
    save_add
  end

  def save_add
    @data.write_to_disk
    @data = Data.new(@name, @password, load_data)
    @prompt.ok('Entry added!')
    @prompt.keypress('Press key to continue')
    data_menu
  end

  def password_prompt
    input = @prompt.select("Enter or generate password?") do |menu|
      menu.choice "Generate password"
      menu.choice "Enter password"
    end
    password_option(input)
  end

  def password_option(input)
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
    entries = @data.get_entries(category)
    rescue_no_entries(entries)
    display_header
    index = @prompt.select('Pick an entry to edit;') do |entry|
      entries.each_with_index {|name, index| entry.choice name, index}
    end
    puts @data.get_entry(category, index)
    edit(category, index)
  end

  def edit(category, index)
    case category
    when 'passwords'
      edit_password(category, index, edit_pword_prompt)
    when 'servers'
      edit_server(category, index, edit_server_prompt)
    when 'notes'
      edit_note(category, index, edit_note_prompt)
    end
  end

  def edit_pword_prompt
    @prompt.select('Select an option:') do |option|
      option.choice 'Edit name', 1
      option.choice 'Edit username', 2
      option.choice 'Edit password', 3
      option.choice 'Delete entry', 4
      option.choice 'Exit', 5
    end
  end

  def edit_password(category, index, input)
    case input
    when 1
      new_name = @prompt.ask('Enter the new name:')
      @data.edit_entry(category, index, 'name', new_name)
      save_edit
    when 2
      new_username = @prompt.ask('Enter the new username:')
      @data.edit_entry(category, index, 'username', new_username)
      save_edit
    when 3
      new_password = password_prompt
      @data.edit_entry(category, index, 'password', new_password)
      save_edit
    when 4
      @data.delete_entry(category, index)
      save_edit
    when 5
    end
  end

  def edit_server_prompt
    @prompt.select('Select an option:') do |option|
      option.choice 'Edit name', 1
      option.choice 'Edit username', 2
      option.choice 'Edit password', 3
      option.choice 'Edit IP address', 4
      option.choice 'Edit note', 5
      option.choice 'Delete entry', 6
      option.choice 'Exit', 7
    end
  end

  def edit_server(category, index, input)
    case input
    when 1
      new_name = @prompt.ask('Enter new name:')
      @data.edit_entry(category, index, 'name', new_name)
      save_edit
    when 2
      new_username = @prompt.ask('Enter new username:')
      @data.edit_entry(category, index, 'username', new_username)
      save_edit
    when 3
      new_password = password_prompt
      @data.edit_entry(category, index, 'password', new_password)
      save_edit
    when 4
      new_password = @prompt.ask('Enter new ip address:')
      @data.edit_entry(category, index, 'ip_address', new_password)
      save_edit
    when 5
      new_password = @prompt.ask('Enter new note:')
      @data.edit_entry(category, index, 'notes', new_password)
      save_edit
    when 6
      @data.delete_entry(category, index)
      save_edit
    when 5
    end
  end

  def edit_note_prompt
    @prompt.select('Select an option:') do |option|
      option.choice 'Edit name', 1
      option.choice 'Edit note', 2
      option.choice 'Delete entry', 3
      option.choice 'Exit', 4
    end
  end

  def edit_note(category, index, input)
    case input
    when 1
      new_name = @prompt.ask('Enter new name:')
      @data.edit_entry(category, index, 'name', new_name)
      save_edit('edited')
    when 2
      new_username = @prompt.ask('Enter new note:')
      @data.edit_entry(category, index, 'note', new_username)
      save_edit('edited')
    when 3
      @data.delete_entry(category, index)
      save_edit('deleted')
    when 4
    end
  end

  def save_edit(action)
    @data.write_to_disk
    @data = Data.new(@name, @password, load_data)
    @prompt.ok("Entry #{action}!")
    @prompt.keypress('Press key to continue')
    data_menu
  end
end