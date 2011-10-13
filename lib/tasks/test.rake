require 'rake/testtask'

namespace :test do
  Rake::TestTask.new("no_rails") do |t|
    t.test_files = FileList['test/no_rails/**/*_test.rb'].shuffle
    t.verbose = true
  end
end
