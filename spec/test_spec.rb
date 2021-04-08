require_relative '../lib/app'
require_relative '../lib/locker'
require_relative '../lib/error'

RSpec.describe Locker do
  describe 'Getting names for entries' do

    test_data = {
      'passwords' => [
        {
        'name' => 'gmail',
        'user' => 'chris@gmail.com',
        'pword' => 'temporary'
       },
        { 
        'name' => 'apple',
        'user' => 'chris@me.com',
        'pword' => 'temporary'
        },
        {
        'name' => 'github',
        'user' => 'chris@me.com',
        'pword' => 'temporary'
        }
      ],
      'servers' => [
        {
        'name' => 'local',
        'user' => 'admin',
        'pword' => 'temporary',
        'IP_address' => '192.168.1.12',
        'ports' => [
          '21 - open',
          '45 - open',
          '65 - open'
          ],
        'notes' => 'This server is currently down'
        },
        {
        'name' => 'work',
        'user' => 'admin',
        'pword' => 'temporary',
        'IP_address' => '192.168.1.12',
        'ports' => [
          '21 - open',
          '45 - open',
          '65 - open'
          ],
        'notes' => 'This server is currently good'
        }
      ],
      'notes' => [
        {
          'name' => 'list of secret recipes',
          'note' => 'Not much here at the moment'
        },
        {
          'name' => 'secret phone numbers',
          'note' => 'phone numbers for famous people'
        }
      ]
    }

    locker = Locker.new(test_data)

    it 'should get an array of names from password category' do
      expect(locker.get_entry_names('passwords')).to eq ['gmail', 'apple', 'github']
    end

    it 'should get an array of names from server category' do
      expect(locker.get_entry_names('servers')).to eq ['local', 'work']
    end

    it 'should het an array of names from the notes category' do
      expect(locker.get_entry_names('notes')).to eq ['list of secret recipes', 'secret phone numbers']
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
  end

  describe 'Authentication' do
  
  
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
end

RSpec.describe Session do

end

