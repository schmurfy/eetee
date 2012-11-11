# -*- encoding: utf-8 -*-
require File.expand_path('../lib/eetee/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Julien Ammous"]
  gem.email         = ["schmurfy@gmail.com"]
  gem.description   = %q{Test framework inspired by Bacon}
  gem.summary       = %q{Another test framework}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.name          = "eetee"
  gem.require_paths = ["lib"]
  gem.version       = EEtee::VERSION
end
