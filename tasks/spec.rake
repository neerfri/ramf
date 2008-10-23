require 'spec/rake/spectask'

desc 'Test the RAMF project using RSpec.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
end

namespace :spec do
  
  desc 'Test using only the classes specs'
  Spec::Rake::SpecTask.new(:classes) do |t|
    t.libs << 'lib'
    t.spec_files = FileList["{spec}/*_spec.rb"] + FileList["{spec}/**/*_spec.rb"] - FileList["{spec}/examples/**/*_spec.rb"]
    t.rcov = true
    t.rcov_opts = ["--text-summary", "-Ilib", "--html", "-o coverage"]#, "spec/*_spec.rb spec/**/*_spec.rb"]
  end
  
  desc 'Test using only the examples specs'
  Spec::Rake::SpecTask.new(:examples) do |t|
    t.libs << 'lib'
    t.spec_files = FileList["{spec}/examples/**/*_spec.rb"]
    t.rcov = true
    t.rcov_opts = ["--text-summary", "-Ilib", "--html", "-o coverage", "spec/*_spec.rb spec/**/*_spec.rb"]
  end
  
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