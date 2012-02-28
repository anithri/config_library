# ConfigLibrary

This Gem provides a mechanism to search multiple hashes(called books) to find a value from either the first
hash in the search order or an array with the results of every book.

ConfigLibrary follows the rules of [Semantic Versioning](http://semver.org/) and uses [YARD](http://yardoc.org/)
for inline documentation.

## Basic Usage
A Little Basic Terminology:
Key:  The identifier used in a hash to look up a value.

Key Chain:  A List of identifiers used to look up a value in a nested set of hashes,
where each key looks up the hash to be used by the next key in the chain.

Book:  A hash with a name used to store data in.

Search Order:  An Array of book names that determines the order to look things up in.

Search Order Strategy:  Determines the new search_order after a book is added.  There are 3 built in strategied:
LIFO, FIFO, Manual.  LIFO(Last In, First Out) is the default.  See Settings section for more information.

Book To Assign To:  A placeholder name that indicates which hash values are placed in if allowed.  Defaults to the
first book in the search order.  Have a better (and shorter) name?  Let me know please.

Alternate Keys:  variations of the given key to also check.  By default it includes a stringified version of a given
symbol or a symbolized version of a given string.  HERE BE DRAGONS.


### initialization

```ruby
#start with no books and default settings
#Not sure if I should add a Module method to allow ConfigLibrary.new or not
config = ConfigLibrary::Base.new

#start with no books and use default settings except for :search_order_strategy
config = ConfigLibrary::Base.new({},{:search_order_strategy => :fifo})

#start with 2 initial books and use default settings
config = ConfigLibrary::Base.new({:system => my_system_settings, :user => my_user_settings})
```

### basic settings and data
See Settings section for detailed information on settings and strategies.

```ruby
config = ConfigLibrary::Base.new({:system => my_system_settings, :user => my_user_settings})

#add a new book, return value is the new search order
config.add_book(:runtime, {}) #=> [:runtime, :user, :system]

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

#this gets the email from the :user_settings book
config.fetch(:email) #=> "batman@batcave.net"

#this gets the background key of the colors hash from the :user_settings book
#fetch is just an alias for fetch_chain
config.fetch_chain(:colors, :background) #=> "maroon"

#this gets all the values for the foreground key in the colors hash from every book.
#  :runtime and :system_settings in this case.
# fetch_all and fetch_all_chain are interchangable
config.fetch_all(:colors, :foreground) #=>["white","white"]

#this returns an array of books that has a given key chain.
config.books_with_key_chain(:colors, :foreground) #=> [:runtime, :system_settings]

#this returns all of the keys for a given key chain across all books
#In need of a shorter name AND needs a way to work for top level keys
config.all_keys_for_key_chain(:colors) #=> [:foreground, :comments, :background, :warnings]

#this returns a the value given for the implied key_chain.
#If the last element is or is suspected to be a hash then use ! to return the value.
#NOT WORKING AS INTENDED YET
config.email #=> 'batman@batcave.net'
config.colors.foreground #=> 'white'
config.colors #=> A MethodChain object that prolly isn't any good to you
config.colors! #=> the colors hash from :runtime.  Should this be different?  should it be the combined values?

#assign the value to the hash/key of the Key chain
#assigns to the book named in #book_to_assign_to
#these do the same thing
config.assign_to(:colors, :info, "green")
runtime_settings[:colors][:info] = "green"
```

## Settings
Settings can be initialized in a ConfigLibrary::Settings object or as a hash that will be merged with defaults and
used to generate the same.

* :assign_ok
  * default: `true`
  * It's ok to assign values.  Switching to false will raise errors when #assign_to is used
* :assign_over_hash
  * default: `false`
  * It's ok to assign a value that will mask or replace a hash
* :assign_over_any
  * default: `true`
  * It's ok to assign to a keychain that already exists.
* :method_missing_ok
  * default: `true`
  * OK to use method missing for short cuts to #fetch_chain
* :method_missing_top_level_keys_only
  * default: `true`
  * Extra check for a method_missing to make sure that the first key in the chain exists before attempting to fetch
  the whole chain.  It needs to be renamed.
* :search_order_strategy
  * default: `:lifo`
  * Determines the search order when books are added.  See section below for more details
* :alternate_key_strategy
  * default: `lambda{|key| key.is_a?(Symbol) ? [key, key.to_s] : [key, key.intern] }`
  * generates alternate keys to try and look things up with.  if you don't want any alternates try `lambda {|key|
  [key]}`
* :new_book_strategy
  * default: `lambda { {} }`
  * when new books or sub hashes are needed, use this strategy to generate.  Meant to be used to substitute alternate
   Hash implementations (HashWithIndifferentAccess, OrderedHash...)
* :assign_to_book_strategy
  * default: `lambda {|search_order| search_order.first}`
  * Used if no explicit book_to_assign_to is given to determine it's value.

### Search Order Strategy
There are 3 built in strategies to choose from.
  * :lifo
    * Last In First Out
    * new books are placed at the beginning of the search_order array
  * :fifo
    * First In First Out
    * new books are placed at the end of the search_order array
  * :manual
    * New books are not placed in the search_order array

You can also open `ConfigLibrary::SearchOrderStrategies` and define new methods.  The method should take 2 arguments:
 the search_order array and the new value, and should return the new array.

```ruby
module ConfigLibrary
  module SearchOrderStrategies
    #example only, might be a reason to use this but I can't think what it could be.
    def random(container, new_value)
      container << new_value
      container.shuffle
    end
  end
end

#later in your code
#If assigned a symbol, ConfigLibrary will use the method named from the ConfigLibrary::SearchOrderStrategies module
config.search_order_strategy = :random
```

You can also just set a lambda with the same two paramaters and use it's results.
```ruby
#this will replace the current first element with the new_one
config.search_order_strategy = lambda {|container, new_value| container[0] = new_value; container }
```

Why so many?  Well I'm still playing with ideas and so have several different ways of implementing things in the code
.  By the 1.0.0 release, there should be a lot more consistency

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

