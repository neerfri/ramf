# Add your own tasks in files placed in lib/tasks ending in .rake,
require 'rake'
require 'rake/rdoctask'

require 'spec/rake/spectask'
 
desc 'Test the RAMF project using RSpec.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
#  t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_dir = "doc"
  rd.rdoc_files.include("README", "lib/**/*.rb")
end
