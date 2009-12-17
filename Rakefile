require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "discover-unused-partials"
    gem.summary = %Q{A script to help you finding out unused partials. Good for big projects or projects under}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "pothix@pothix.com and vinibaggio@gmail.com"
    gem.homepage = "http://github.com/vinibaggio/discover-unused-partials"
    gem.authors = ["PotHix and ViniBaggio"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
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
