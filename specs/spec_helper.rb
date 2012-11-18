require 'rubygems'
require 'bundler/setup'

require 'eetee'

require 'eetee/ext/mocha'

Thread.abort_on_exception = true

# examples
require_relative '../examples/extensions/extension'
