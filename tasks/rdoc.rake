require 'rake/rdoctask'
namespace :rdoc do
  Rake::RDocTask.new do |rd|
    rd.main = "README"
    rd.rdoc_dir = "doc"
    rd.rdoc_files.include("README", "lib/**/*.rb")
  end
end

desc "alias to rdoc:rdoc"
task :rdoc=>"rdoc:rdoc"