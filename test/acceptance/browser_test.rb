ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require "capybara/rails"
require "minitest/autorun"

class BrowserTest < ActiveSupport::TestCase
  include Capybara::DSL
  
  # Selenium tests start the Rails server in a separate process. If test data is wrapped in a
  # transaction, the server won't see it.
  DatabaseCleaner.strategy = :truncation
  setup :set_driver, :clean_database
  teardown :reset_capybara_driver, :report_error_count
  
  def report_error_count
    unless @passed
      puts page.source
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

  def clean_database
    DatabaseCleaner.clean
  end
  
  def set_driver
    if ENV["CAPYBARA_DRIVER"] == "selenium"
      Capybara.current_driver = :selenium
    end
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
