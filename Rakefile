require "rake"
require "hanna/rdoctask"
require "spec/rake/spectask"
require "lib/rrd/version"
require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "rrd-ffi"
  gem.version = RRD::Version::STRING
  gem.summary = %Q{RRDTool gem using librrd and ffi}
  gem.description = %Q{Provides bindings for many RRD functions (using ffi gem and librrd), as well as some DSL for graphic building}
  gem.email = "morellon@gmail.com"
  gem.homepage = "http://github.com/morellon/rrd-ffi"
  gem.authors = ["morellon", "fnando", "rafaelrosafu", "dalcico"]
  gem.add_development_dependency "rspec"
  gem.add_dependency "ffi"
end

Jeweler::GemcutterTasks.new

desc 'Run the specs'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--colour --format specdoc --loadby mtime --reverse']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "RRD"
  rdoc.options += %w[ --line-numbers --inline-source --charset utf-8 ]
  rdoc.rdoc_files.include("README.rdoc", "CHANGELOG.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end