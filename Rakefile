require "rake"
require "spec/rake/spectask"
require "lib/rrd/version"
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "rrd-ffi"
  gem.version = RRD::Version::STRING
  gem.summary = %Q{RRDTool gem using librrd and ffi}
  gem.description = %Q{Provides bindings for many RRD functions (using librrd), as well as some DSL for graphic building}
  gem.email = "morellon@gmail.com"
  gem.homepage = "http://github.com/morellon/r2d2"
  gem.authors = ["morellon", "fnando", "rafaelrosafu", "dalcico"]
  gem.add_development_dependency "rspec"
end

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format specdoc --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end