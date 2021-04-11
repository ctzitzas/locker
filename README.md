# locker

## About

Version: 0.1.0
Author: Chris Tzitzas

terminal_locker is a password manager for the terminal. terminal_locker saves all data in an encrypted format locally for access from the terminal using the application UI or command line arguments.

## Features

terminal_locker is a password manager for IT professionals to safely and securely save important credentials to your local hardrive. All data and passwords are stored using 256bit encryption. It offers simple password saving as well as saving server credentials and important notes. The program can also autogenerate passwords for you and checks the strength of any password you save in the locker.

## Installation

To install the program simply clone the repository to your local hard drive and run the folowing command in the terminal from the src folder.

`bundle install`

## Dependencies

System requirements:

`Ruby version > 2.7.1`

`bundler`

terminal_locker also needs the following gems installed to run sucessfully:

`"rspec", "~> 3.10"`

`"bcrypt", "~> 3.1"`

`"clipboard", "~> 1.3"`

`"tty-prompt", "~> 0.23.0"`

`"artii", "~> 2.1.2"`

Use bundler to install dependencies.

The application also requires openssl, json and base64 ruby libraries


## Launch

### UI

To launch terminal_locker run the bash script titled terminal_locker.sh. The program uses a text-based UI to create new lockers, login and to add, edit and delete entries within the locker.

### Command line arguments

By using command line arguments a user can copy passwords or the contents of a note to the clipboard without having to access the UI.

Run terminal_locker.sh with 3 arguments: locker name, category name and entry name. The category name can be abbreviated down to the first letter of the category. For example to copy the password for the Google entry in passwords located in My_Locker run the following in the terminal:

`./terminal_locker.sh My_Locker p Google`

or you can write out the whole category:

`./terminal_locker.sh My_Locker passwords Google`

After running the command you will be prompted for the locker password and then the contents will be copied to the clipboard.

The command line can also be used to generate a password by passing generate as an argument like so:

`./terminal_locker.sh generate`

### Deleting lockers

To delete a locker simply delete the folder with the same name as the locker found the data folder of the application root directory.


## Testing

All functions tested in test_spec.rb were sucessfully tested using rspec. However, after the addition of persistant storage and encryption most of the tests broke and were unable to be fixed before the application needed to be deployed.

## To-do

Future features to be built into the application include:

- The ability to show all details of an entry using the command line.

- The ability to open and edit the contents of notes using an external text editor.

- The ability to launch a note in the ditor from the command line.

- The ability to save any file type to the locker in a new 'File' category. The file can then be saved to disk or opened using the command line. 


