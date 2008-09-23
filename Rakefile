# Add your own tasks in files placed in lib/tasks ending in .rake,
require 'rake'
require 'rake/rdoctask'

require 'spec/rake/spectask'
require 'rake/gempackagetask'
 
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

namespace :spec do
  desc "Generate code coverage with rcov"
  task :rcov do
    rm_rf "coverage/coverage.data"
    rm_rf "coverage/"
    mkdir "coverage"
    rcov = %(rcov --text-summary -Ilib --html -o coverage spec/*_spec.rb spec/**/*_spec.rb)
    system rcov
    system "firefox coverage/index.html"
  end
end

spec = Gem::Specification.new do |s| 
  s.name = "ramf"
  s.version = "0.0.1"
  s.author = "Neer Friedman"
  s.email = "neerfri@gmail.com"
  s.homepage = "http://ramf.saveanalien.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "An AMF serializer/deserializer for ruby"
  s.files = FileList["{lib}/**/*","Rakefile","LICENSE","README"].to_a
  s.require_path = "lib"
#  s.autorequire = "ramf"
  s.test_files = FileList["{spec}/**/*"].to_a
  s.has_rdoc = true
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ["README"]
#  s.add_dependency("dependency", ">= 0.x.x")
end
 
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end 

