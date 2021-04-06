require_relative '../lib/app'
require_relative '../lib/locker'
require_relative '../lib/errors'

ARGV.clear

RSpec.describe Locker do
  describe 'Create a locker' do

      empty_data = {
      'passwords' => [],
      'servers' => [],
      'notes' => []
      }

      empty_locker = {
      'name' => 'empty',
      'password' => 'empty',
      'data' => empty_data
      }

      user_locker = {
        'name' => 'User',
        'password' => 'Password',
        'data' => empty_data
      }

    it 'should create an empty data block for locker' do
      new_locker = Locker.new('empty', 'empty')
      expect(new_locker.create_data).to eq empty_data
    end
  
    it 'should create an empty locker' do
      new_locker = Locker.new('empty', 'empty')
      expect(new_locker.create_locker).to eq empty_locker
    end
  
    it 'should add a name and password to a locker' do
      new_locker = Locker.new('User', 'Password')
      expect(new_locker.create_locker).to eq user_locker
    end

  end
end

RSpec.describe App do
  describe 'Password Testing' do
    it 'should raise an error if password is short' do
      app = App.new
      expect{app.test_password('weak')}.to raise_error(ShortPassword)
    end

    it 'should return true if password is strong' do
      app = App.new
      expect(app.test_password('GreatPassword1!')).to be true
    end

    it 'should raise an error if password is weak' do
      app = App.new
      expect{app.test_password('weak1234')}.to raise_error(WeakPassword)
    end

    it 'should a save the password as a hash and be unreadable' do
      app = App.new
      expect(app.hash_password('password')).not_to eql 'password'
    end
  end

  describe 'Login to locker' do
  
    it 'should read the name of a saved locker' do
      app = App.new
      expect(app.get_locker_name).to eq "Chris"
    end
  
    it 'should compare user input with password and return true' do
      app = App.new
      user_input = 'Password'
      expect(app.verify_pword(user_input)).to be true
    end
  
    it 'should throw user an error if password is incorrect' do
      app = App.new
      user_input = 'Something wrong'
      expect{app.verify_pword(user_input)}.to raise_error(WrongPassword)
    end
  
    it 'should read data from secure locker' do
      app = App.new
      data = {
        "passwords" => [
          {'name' => 'google', 'username' => "chris@gmail.com", 'password' => 'password'},
          {'name' => 'apple', 'username' => "chris@me.com", 'password' => 'password'}
          ],
        "servers" => [],
        "notes" => []
      }
      expect(app.get_locker_data).to eq data
    end
  
  end
  
  describe 'Add, edit, delete password entries' do
  
    it 'should read all the saved entry names and output string' do
      app = App.new
      data_array = ['google', 'apple']
      expect(app.get_password_names).to eq data_array

    end
  
    # it 'should add entry to password category' do
  
    # end
  
    # it 'should save password in encrypted format' do
  
    # end
  
    # it 'should edit an entry' do
  
    # end
  
    # it 'should delete an entry' do
  
    # end
  
  end
  
  describe 'Generate strong password' do
  
    # it 'should generate an 8 character long password' do
  
    # end
  
    # it 'should confirm the password is strong' do
  
    # end
  
    # it 'should save password as a hash and be unreadable do
  
    # end
  
    # it 'should copy password to clipboard' do
  
    # end
  
  end
  
  describe 'View contents of locker' do
  
    # it 'should find categories with entries' do
  
    # end
  
    # it 'should display all categories with entries' do
  
    # end
  
    # it 'read all entries in category' do
  
    # end
  
    # it 'should display all entries in category' do
  
    # end
  
    # it 'should save entry to clipboard' do
  
    # end
  
  end
  
  describe 'Add, edit and delete notes' do
  
    # it 'should read the name of the note' do
  
    # end
  
    # it 'add new note entry' do
  
    # end
  
    # it 'edit name of entry' do
  
    # end
  
    # it 'open contents of note in an editor' do
  
    # end
  
  end
end
