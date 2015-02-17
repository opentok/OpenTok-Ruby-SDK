require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r opentok.rb"
end

task :default => :spec
