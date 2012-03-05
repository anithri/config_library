# ConfigLibrary

This Gem provides a mechanism to search multiple hashes(called books) to find a value from either the first
hash in the search order or an array with the results of every book.

ConfigLibrary follows the rules of [Semantic Versioning](http://semver.org/) and uses [YARD](http://yardoc.org/)
for inline documentation.

## Basic Usage
A Little Basic Terminology:
Key:  The identifier used in a hash to look up a value.

Key Chain:  A List of symbols as identifiers used to look up a value in a nested set of hashes,
where each key looks up the hash to be used by the next key in the chain.

Book:  A hash with a name used to store data in.

Search Order:  An Array of book names that determines the order to look things up in.

Book To Assign To:  A placeholder name that indicates which hash values are placed in if allowed.  Defaults to the
first book in the search order.  Have a better (and shorter) name?  Let me know please.

Alternate Keys:  When a book is added, all of the keys are symbolized, and symbols should be used in the key chain.

Books:  When a book is added to a ConfigLibrary, it is recreated as a flat hash that uses an array of symbols as it's
 key with the value.  This makes look ups much faster and more straightforward.  It also means that once a hash has
 been added as a book, further changes to that hash are not reflected.  Finding a way to keep them in sync is a todo
 itiem.

```ruby
#initial hash
test_hash =  {foo: 3, bar: "High", baz: { system: "linux", user: "me"}}
config.add_new_book(:test_hash, test_hash)
config.books[:test_hash].inspect #=> {[:foo]=>3, [:bar]=>"High", [:baz, :system]=>"linux", [:baz, :user]=>"me"}
```

### initialization

```ruby
#start with no books and default settings
#Not sure if I should add a Module method to allow ConfigLibrary.new or not
config = ConfigLibrary::Base.new

#start with 2 initial books and use default settings
config = ConfigLibrary::Base.new({:system => my_system_settings, :user => my_user_settings})
```

```ruby
config = ConfigLibrary::Base.new({:system => my_system_settings, :user => my_user_settings})

#add a new book, return value is the new search order
config.add_new_book(:runtime, {}) #=> [:runtime, :user, :system]

#look at existing books
config.books.keys #=> [:system, :user, :runtime]

#look at search_order
config.search_order #=> [:runtime, :user, :system]

#look at book_to_assign_to
config.book_to_assitn_to #=> :runtime

```

### Lets get some data!
This is the core functionality of ConfigLibrary.  Understanding how ConfigLibrary looks up data is vital to using the
 library with confidence.

 The basic version goes like this.  Given a Key or a Key Chain, ConfigLibrary checks each book in order from the
 search_order, and returns the first value from the first book where that key or key chain is present.

```ruby
#first we'll setup a few hashes to use as books
system_settings = {:tmp_dir => '/tmp', :colors => {:background => 'black', :foreground => 'white'}}
user_settings = {:email => 'batman@batcave.net', :colors => {:background => 'maroon', :warnings => "red"}}
runtime_settings = {:colors=>{:foreground => "white", :comments => "blue"}}

#initialize
config = ConfigLibrary::Base.new({:system_settings => system_settings, :user_settings => user_settings,
:runtime => runtime_settings})

#search_order is [:runtime, :user, :system]
#Basic Lookups and Assigns

#this tells us if the library has the :user_name key.  It doesn't.
#you could also use #has_key_chain?
config.has_key?(:user_name) #=> false
config.has_key?(:colors, :background) #=> true

#this gets the email from the :user_settings book
config.fetch(:email) #=> "batman@batcave.net"

#this gets the background key of the colors hash from the :user_settings book
config.fetch(:colors, :background) #=> "maroon"

#this gets all the values for the foreground key in the colors hash from every book.
#  :runtime and :system_settings in this case.
# fetch_all and fetch_all_chain are interchangable
config.fetch_all(:colors, :foreground) #=>["white","white"]

#this returns an array of books that has a given key chain.
config.books_with(:colors, :foreground) #=> [:runtime, :system_settings]

#this returns all of the keys for a given key chain across all books
#In need of a shorter name AND needs a way to work for top level keys
config.keys_for(:colors) #=> [:foreground, :comments, :background, :warnings]

#this returns a the value given for the implied key_chain.
#If the last element is or is suspected to be a hash then use ! to return the value.
config.email #=> 'batman@batcave.net'
config.colors.foreground #=> 'white'
config.colors #=> A MethodChain object that prolly isn't any good to you
config.colors! #=> the colors hash from :runtime.  Should this be different?  should it be the combined values?

#assign the value to the hash/key of the Key chain
#assigns to the book named in #book_to_assign_to
#these do the same thing
config.assign_to(:colors, :info, "green") #=> runtime_settings[:colors][:info] = "green"
```

## Settings
ConfigLibrary uses 3 settings.

```ruby
config.books # The hash that maps book names to the hash they represent. Read Only
config.search_order # An Array that determines the order to check books in.
config.assign_to_book # A Symbol representing the book that gets assigned to if #assign_to is used.
```


## Problems
Stuff should go here.


## Contributing to config_library

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Scott M Parrish. See LICENSE.txt for
further details.

