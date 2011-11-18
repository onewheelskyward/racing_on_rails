require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ArticleTest < ActiveSupport::TestCase
  test "move in list" do
    article = FactoryGirl.create(:article)
    article_2 = FactoryGirl.create(:article)
    
    article.move_to_bottom
    assert_equal [ article_2, article ], Article.all, "Should be sorted"
    
    article_2.move_to_bottom
    assert_equal [ article, article_2 ], Article.all, "Should be sorted"
  end
end
