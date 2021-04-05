require_relative '../lib/app'
require_relative '../lib/locker'

ARGV.clear

RSpec.describe Locker do
  describe 'Create a locker' do

      empty_data = {
      :passwords => [],
      :servers => [],
      :notes => []
      }

      empty_locker = {
      :name => 'empty',
      :password => 'empty',
      :data => empty_data
      }

      user_locker = {
        :name => 'User',
        :password => 'Password',
        :data => empty_data
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

# RSpec.describe App do
#   describe 'Password Testing' do
#     it 'should return false if password is weak' do
      
#     end

#     it 'should return true if password is strong' do
      
#     end

#     it 'should return error if password is weak' do
#     end

#     it 'should return the password if password is strong' do
      
#     end
#   end

  describe 'Login to locker' do
  
    # it 'should read the name of a locker' do
  
    # end
  
    # it 'should match password with saved hash' do
  
    # end
  
    # it 'should throw user an error if password is incorrect' do
  
    # end
  
    # it 'should read contents of secure locker and see categories and entries' do
  
    # end
  
  end
  
  describe 'Add, edit, delete password entries' do
  
    # it 'should read all the saved entry names' do
  
    # end
  
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
  
    # it 'should save password in encrypted format' do
  
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
