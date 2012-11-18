
# Continuous integration ([![Build Status](https://secure.travis-ci.org/schmurfy/eetee.png)](http://travis-ci.org/schmurfy/eetee))

This gem is tested against these ruby by travis-ci.org:

- MRI 1.9.3
- rubinius (1.9 mode)

# What is this name ?

Finding an unused name is getting hard so I finally settled for E.T. because why not ?  
I did not want to hve a gem with a two letters name so here is eetee !

# What is this gem ?

I used the bacon test framework for quite some time now but I have some issues with it which
are mostly unfixable without rewriting internals, this is what E.T. is !  
From the outside the specs should run the same on both but the changed internals allow better
integration with guard amongst other things.

My goals were:
- as light as possible (like bacon)
- minimal set of helpers, go check rspec if you want more
- specs file should be executable as is, there is no "eetee" binary
- specs can be grouped without changing anything in them (run all the spec folder)
- keep bacon syntax as I am used to it and like it
- a set of extensions I used often (but not required by default)

# Usage

E.T. is using itself for its tests, you can look at the spec_helper.rb file and its tests,
here is a quickstart:

create a test file (I suppose you are using bundler, if not you should !):
```ruby
require 'rubygems'
require 'bundler/setup'
require "eetee"

include EEtee

describe 'Tests' do
  before do
    @a = 3
  end
  
  should 'have access to instance variables' do
    @a.should == 3
  end
  
  should 'wait 1s' do
    sleep 1
    1.should == 1
  end
  
  should 'works 2' do
    (40 + 5).should == 45
  end
  
  should 'fails' do
    "toto".should == 4
  end
end
```

and to run it:
```bash
$ ruby test.rb
```

# Available extensions

## guard
The guard is included inside the gem, just look at the Guardfile for the gem for the syntax (unfortunately guard init excepts the guard to live in a separate gem)

## mocha
Allow mocha expectations to be considered as E.T. expectations.

## rack
Boilet plate around rack-test to test rack applications.

## time
Some time helpers:
  time_block{ ... } => return execution time in milliseconds
  freeze_time => Time.now will return the same time inside the block


# Setting up development environmeent

```bash
# clone the repository and:
$ bundle
$ bundle exec guard
```

the tests will run when a file changed, if only want to run all tests once:

```bash
$ bundle exec rake
```

