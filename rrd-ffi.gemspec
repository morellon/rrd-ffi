# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |gem|
  gem.authors       = ["Thiago Morello"]
  gem.email         = ["morellon@gmail.com"]
  gem.description   = %q{Provides bindings for many RRD functions (using ffi gem and librrd), as well as DSLs for graphic and rrd building. You must have librrd in your system!}
  gem.summary       = %q{DSL + Bindings for librrd using FFI}
  gem.homepage      = "http://github.com/morellon/rrd-ffi"

  gem.files         = ["lib/rrd.rb"] + Dir['lib/rrd/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rrd-ffi"
  gem.require_paths = ["lib"]
  gem.version       = version
  gem.license       = 'MIT'

  gem.add_dependency 'activesupport', '~> 7.1.1'
  gem.add_dependency 'ffi', '~> 1.15'

  ## development dependencies

  gem.add_development_dependency 'rspec', '~> 3.10'
end
