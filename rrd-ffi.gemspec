# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rrd/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thiago Morello"]
  gem.email         = ["morellon@gmail.com"]
  gem.description   = %q{Provides bindings for many RRD functions (using ffi gem and librrd), as well as DSLs for graphic and rrd building. You must have librrd in your system!}
  gem.summary       = %q{DSL + Bindings for librrd using FFI}
  gem.homepage      = "http://github.com/morellon/rrd-ffi"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rrd-ffi"
  gem.require_paths = ["lib"]
  gem.version       = RRD::Version::STRING
end
