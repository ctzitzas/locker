require_relative '../lib/app'
require_relative '../lib/locker'
require_relative '../lib/error'

RSpec.describe Locker do
  describe 'Getting names for entries' do
    before(:each) do
      @test_data = {
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
  
      @locker = Locker.new(@test_data)
    end

    it 'should get an array of names from password category' do
      expect(@locker.get_entry_names('passwords')).to eq ['gmail', 'apple', 'github']
    end

    it 'should get an array of names from server category' do
      expect(@locker.get_entry_names('servers')).to eq ['local', 'work']
    end

    it 'should het an array of names from the notes category' do
      expect(@locker.get_entry_names('notes')).to eq ['list of secret recipes', 'secret phone numbers']
    end
  end

  describe 'Adding entries to categories' do
    before(:each) do
      @empty_data = {
        'passwords' => [],
        'servers' => [],
        'notes' => []
      }
      @locker = Locker.new(@empty_data)
    end
  
    it 'should add a password to password category' do
      expect(@locker.add_password('gmail', 'chris@gmail.com', 'temporary')).to eq (
        [
          {
          'name' => 'gmail',
          'user' => 'chris@gmail.com',
          'pword' => 'temporary'
          }
        ])
    end

    it 'should be able to add a server to server category' do
      expect(@locker.add_server('local', 'admin', 'temporary', '192.168.1.12')).to eq (
        [
          'name' => 'local',
          'user' => 'admin',
          'pword' => 'temporary',
          'ip_address' => '192.168.1.12',
          'ports' => nil,
          'notes' => nil
        ])
    end

    it 'should be able to add a note to note category' do
      expect(@locker.add_note('Secret recipes', 'List of herbs and spices')).to eq (
        [
          'name' => 'Secret recipes',
          'note' => 'List of herbs and spices'
        ])
    end
  end

  describe 'Editing entries' do
    before(:each) do
      @test_data = {
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
  
      @locker = Locker.new(@test_data)
    end

    it 'should edit name entry for password' do
      expect(@locker.edit_entry('passwords', 0, 'name', 'google')).to eq 'google'
    end

    it 'should edit user entry for password' do
      expect(@locker.edit_entry('passwords', 0, 'user', 'changed')).to eq 'changed'
    end

    it 'should edit password entry for password' do
      expect(@locker.edit_entry('passwords', 0, 'pword', 'changed')).to eq 'changed'
    end

    it 'should edit ip_address entry for server' do
      expect(@locker.edit_entry('servers', 0, 'ip_address', 'changed')).to eq 'changed'
    end

  end

  describe 'Deleting entries' do
    before(:each) do
      @test_data = {
        'passwords' => [
          {
          'name' => 'gmail',
          'user' => 'chris@gmail.com',
          'pword' => 'temporary'
         }],
      
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
          }
        ],
        'notes' => [
          {
            'name' => 'secret phone numbers',
            'note' => 'phone numbers for famous people'
          }
        ]
      }

      @locker = Locker.new(@test_data)
    end
    it 'should delete a password entry' do
      @locker.delete_entry('passwords', 0)
      expect(@test_data['passwords'][0]).to eq nil
    end

    it 'should delete a server entry' do
      @locker.delete_entry('servers', 0)
      expect(@test_data['servers'][0]).to eq nil
    end

    it 'should delete a note entry' do
      @locker.delete_entry('notes', 0)
      expect(@test_data['notes'][0]).to eq nil
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

