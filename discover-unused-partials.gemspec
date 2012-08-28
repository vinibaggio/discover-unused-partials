# -*- encoding: utf-8 -*-
require File.expand_path('../lib/discover-unused-partials/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Willian Molinari (a.k.a PotHix)", "Vinicius Baggio"]
  gem.email         = ["pothix@pothix.com", "vinibaggio@gmail.com"]
  gem.description   = %q{A script to help you finding out unused partials. Good for big projects or projects under heavy refactoring}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/vinibaggio/discover-unused-partials"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "discover-unused-partials"
  gem.require_paths = ["lib"]
  gem.version       = DiscoverUnusedPartials::VERSION
end
