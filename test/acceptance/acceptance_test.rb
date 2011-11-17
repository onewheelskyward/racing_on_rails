ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require "capybara/rails"
require "minitest/autorun"

class AcceptanceTest < ActiveSupport::TestCase
  DOWNLOAD_DIRECTORY = "/tmp/webdriver-downloads"

  include Capybara::DSL
  
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome, :switches => ["--user-data-dir=#{Rails.root}/tmp/chrome-profile"])
  end

  # Selenium tests start the Rails server in a separate process. If test data is wrapped in a
  # transaction, the server won't see it.
  DatabaseCleaner.strategy = :truncation
  setup :set_driver, :clean_database
  teardown :reset_capybara_driver, :report_error_count
  
  def report_error_count
    unless @passed
      save_and_open_page
    end
  end
  
  def assert_page_has_content(text)
    unless page.has_content?(text)
      fail "Expected '#{text}' in \n#{page.source}"
    end
  end
  
  def assert_page_has_no_content(text)
    unless page.has_no_content?(text)
      fail "Did not expect '#{text}' in \n#{page.source}"
    end
  end
  
  def assert_table(table_id, row, column, expected)
    element = find(:xpath, "//table[@id='#{table_id}']//tr[#{row + 1}]//td[#{column + 1}]")
    case expected
    when Regexp
      assert_match expected, element.text, "Row #{row} column #{column} of table #{table_id}. Table:\n #{find_by_id(table_id).text}"
    else
      assert_equal expected.to_s, element.text, "Row #{row} column #{column} of table #{table_id}. Table:\n #{find_by_id(table_id).text}"
    end
  end

  def wait_for_download(glob_pattern)
    raise ArgumentError if glob_pattern.blank? || (glob_pattern.respond_to?(:empty?) && glob_pattern.empty?)
    begin
      Timeout::timeout(10) do
        while Dir.glob("#{DOWNLOAD_DIRECTORY}/#{glob_pattern}").empty?
          sleep 0.25
        end
      end
    rescue Timeout::Error => e
      raise Timeout::Error, "Did not find '#{glob_pattern}' in #{DOWNLOAD_DIRECTORY} within seconds 10 seconds. Found: #{Dir.entries(DOWNLOAD_DIRECTORY).join(", ")}"
    end
  end
  
  def click_ok_on_alert_dialog
    page.evaluate_script "window.alert = function(msg){return true;};"
  end

  # Go to login page and login
  def login_as(person)
    visit "/person_session/new"
    fill_in "person_session_login", :with => person.login
    fill_in "person_session_password", :with => "secret"
    click_button "login_button"
  end
  
  def logout
    visit "/logout"
  end

  def clean_database
    DatabaseCleaner.clean
    Discipline.reset
  end
  
  def remove_download(filename)
    FileUtils.rm_f "#{DOWNLOAD_DIRECTORY}/#{filename}"
  end

  def set_driver
    # if ENV["CAPYBARA_DRIVER"] == "selenium"
      Capybara.current_driver = :selenium
    # end
    FileUtils.rm_rf "#{Rails.root}/tmp/chrome-profile"
    FileUtils.mkdir_p "#{Rails.root}/tmp/chrome-profile"
    FileUtils.cp_r "#{Rails.root}/test/chrome-profile", "#{Rails.root}/tmp"

    FileUtils.rm_rf DOWNLOAD_DIRECTORY
    FileUtils.mkdir_p DOWNLOAD_DIRECTORY
  end
  
  def reset_capybara_driver
    Capybara.use_default_driver
  end
  
  def say_if_verbose(text)
    if ENV["VERBOSE"].present?
      puts text
    end
  end
end
