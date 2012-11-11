require 'rubygems'
require 'bundler/setup'

require 'eetee'

if ENV['COVERAGE']
  Bacon.allow_focused_run = false
  
  require 'simplecov'
  SimpleCov.start do
    add_filter ".*_spec"
    add_filter "/helpers/"
  end
  
end

# require 'bacon/ext/mocha'
# require 'bacon/ext/em'

Thread.abort_on_exception = true

# examples
require_relative '../examples/extensions/extension'
