# Add your own tasks in files placed in lib/tasks ending in .rake,
require 'rake'

RAKE_BASE = File.dirname(__FILE__)
CURRENT_VERSION = File.open(File.join(RAKE_BASE, "GEM_VERSION")) do |f|
  version = nil
  f.each_line { |l| version = $1 if  l=~/^(\d+\.\d+\.\d+)/ }
  version ? version : raise("could not find gem version in #{File.join(RAKE_BASE, 'GEM_VERSION')}")
end


Dir["#{File.dirname(__FILE__)}/tasks/**/*.rake"].sort.each { |ext| load ext }
 




