namespace :git do

  # A prerequisites task that all other tasks depend upon
  task :prereqs

  desc 'Show tags from the Git repository'
  task :tags => 'git:prereqs' do |t|
    puts %x{git tag}
  end

  desc 'Create a new tag in the Git repository'
  task :create_tag => 'git:prereqs' do |t|
    v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
    abort "Versions don't match #{v} vs #{CURRENT_VERSION}" if v != CURRENT_VERSION

    tag = "ramf-#{CURRENT_VERSION}"
    msg = "Creating tag for RAMF. Version: #{CURRENT_VERSION}"

    puts "Creating Git tag '#{tag}'"
    unless system "git tag -a -m '#{msg}' #{tag}"
      abort "Tag creation failed"
    end

    if %x{git remote} =~ %r{^origin\s*$}
      unless system "git push origin #{tag}"
        abort "Could not push tag to remote Git repository"
      end
    end
  end

end  # namespace :git

task 'gem:release' => 'git:create_tag'