require 'rake/testtask'

namespace :test do
  Rake::TestTask.new("ruby") do |t|
    t.test_files = FileList['test/ruby/**/*_test.rb'].shuffle
    t.verbose = true
  end

  Rake::TestTask.new("competitions") do |t|
    t.test_files = FileList['test/unit/events/competitions/*_test.rb'].shuffle
    t.verbose = true
  end
end
