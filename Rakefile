require 'jeweler'
require 'rubygems'
require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :spec => :check_dependencies
task :default => :spec

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "discover-unused-partials #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "discover-unused-partials"
  gemspec.summary = "Discover your unused partials"
  gemspec.description = "A script to help you finding out unused partials. Good for big projects or projects under heavy refactoring"
  gemspec.email = "vinibaggio@gmail.com"
  gemspec.homepage = "http://github.com/vinibaggio/discover-unused-partials"
  gemspec.authors = ["Vinicius Baggio", "Willian Molinari (a.k.a PotHix)"]
end
