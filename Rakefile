require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end

task :default => :spec
