$:.unshift(File.dirname(__FILE__) + "/lib")

require "rake"
require "rspec/core/rake_task"
require "rrd/version"

begin
  require "hanna/rdoctask"
rescue LoadError => e
  require "rake/rdoctask"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "rrd-ffi"
    gem.version = RRD::Version::STRING
    gem.summary = %Q{RRDTool gem using librrd and ffi}
    gem.description = %Q{Provides bindings for many RRD functions (using ffi gem and librrd), as well as DSLs for graphic and rrd building. You must have librrd in your system!}
    gem.email = "morellon@gmail.com"
    gem.homepage = "http://github.com/morellon/rrd-ffi"
    gem.authors = ["morellon"]
    gem.add_development_dependency "rspec"
    gem.add_dependency "ffi"
    gem.add_dependency "activesupport"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc 'Run the specs'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Rspec : run all with RCov"
RSpec::Core::RakeTask.new('spec:rcov') do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'gems', '--exclude', 'spec']
end

Rake::RDocTask.new do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "doc"
  rdoc.title = "RRD"
  rdoc.options += %w[ --line-numbers --inline-source --charset utf-8 ]
  rdoc.rdoc_files.include("README.rdoc", "CHANGELOG.rdoc")
  rdoc.rdoc_files.include("lib/**/*.rb")
end

task :default => :spec
