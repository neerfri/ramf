require 'rake/gempackagetask'

GEM_SPEC = Gem::Specification.new do |s| 
  s.name = "ramf"
  s.version = CURRENT_VERSION
  s.author = "Neer Friedman"
  s.email = "neerfri@gmail.com"
  s.homepage = "http://ramf.saveanalien.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "An AMF serializer/deserializer for ruby"
  s.files = FileList["{lib}/**/*","Rakefile","LICENSE","README"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{spec}/**/*"].to_a
  s.has_rdoc = true
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.extra_rdoc_files = ["README"]
end
 

namespace :gem do
  
  # A prerequisites task that all other tasks depend upon
  task :prereqs
  
  desc 'Print gem spec'
  task :debug => 'gem:prereqs' do
    puts GEM_SPEC.to_ruby
  end
  
  desc 'Create or update ramf.gemspec file'
  task :spec do
    File.open(File.join(RAKE_BASE,"ramf.gemspec"),"w+") do |f|
      spec = GEM_SPEC.to_ruby.gsub(/%q\{([^}]*)\}/){"\"#{$1}\""}.
              gsub(/^.*s.required_rubygems_version.*$/,"").
              gsub(/^(\s*)if s.*\n(.*\n)*?\1end/,"").gsub(/^\s*#.*$/,"")
      f.write(spec)
    end
  end
  
  Rake::GemPackageTask.new(GEM_SPEC) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
end
desc 'alias to gem:package'
task :gem => 'gem:package'