require 'rubygems'
require 'bundler/setup'

require "eetee"

include EEtee


Runner.new.run_files("file*.rb")

