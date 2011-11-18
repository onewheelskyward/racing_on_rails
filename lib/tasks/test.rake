require 'rake/testtask'

namespace :test do
  Rake::TestTask.new("ruby") do |t|
    t.test_files = FileList['test/ruby/**/*_test.rb'].shuffle
    t.verbose = true
  end

  Rake::TestTask.new("competitions") do |t|
    t.test_files = FileList['test/unit/competitions/*_test.rb', "test/unit/competition_test.rb"].shuffle
  end
  
  Rake::TestTask.new("no_rails") do |t|
    t.test_files = FileList['test/no_rails/**/*_test.rb'].shuffle
    t.verbose = true
  end
end
