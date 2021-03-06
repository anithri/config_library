# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "config_library"
  gem.homepage = "http://github.com/anithri/config_library"
  gem.license = "MIT"
  gem.summary = %Q{Experimental Configuration Library}
  gem.description = %Q{ConfigLibrary allows you to load multiple config hashes (books), and then search for keys and chains of keys in each one returning the first found.}
  gem.email = "anithri@gmail.com"
  gem.authors = ["Scott M Parrish"]
  # dependencies defined in Gemfile
  @my_name = gem.name
  @my_version = gem.inspect
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "config_library #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

%w(major minor patch).each do |bump|
  Rake::Task["version:bump:#{bump}"].enhance do
    Rake::Task["version:sync_constant"].invoke
  end
end

namespace :version do
  desc "Write contents of VERSION file into lib/config_file/version.rb"
  task :sync_constant do
    j = Jeweler::VersionHelper.new(Dir.pwd)
    module_name = @my_name.split("_").map(&:capitalize).join("")
    file = "module #{module_name}\n  VERSION = '#{j.to_s}'\nend\n"
    file_name = Dir.pwd + "/lib/#{@my_name}/version.rb"
    File.open(file_name, 'w') {|f| f.write(file)}
  end
end
