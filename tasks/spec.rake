require 'spec/rake/spectask'

desc 'Test the RAMF project using RSpec.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
#  t.verbose = true
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