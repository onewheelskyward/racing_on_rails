# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class MailingListMailerTest < ActionMailer::TestCase
  def test_post
    post = FactoryGirl.create(:mailing_list).posts.create!(
      :from_name => "Molly",
      :from_email_address => "molly@veloshop.com",
      :subject => "For Sale",
      :body => "Lots of singlespeeds for sale."
    )

    post_email = MailingListMailer.post(post)
    assert_equal ["molly@veloshop.com"], post_email.from
    assert_equal "For Sale", post_email.subject
  end
  
  def test_post_private_reply
    post = FactoryGirl.create(:mailing_list).posts.create!(
      :from_name => "Molly",
      :from_email_address => "molly@veloshop.com",
      :subject => "For Sale",
      :body => "Lots of singlespeeds for sale."
    )
    
    post_email = MailingListMailer.private_reply(post, "Scout <scout@butlerpress.com>")
    assert_equal ["molly@veloshop.com"], post_email.from
    assert_equal "For Sale", post_email.subject
    assert_equal ["scout@butlerpress.com"], post_email.to
  end
  
  def test_receive_simple
    assert_difference "Post.count", 1 do
      subject = "Test Email"
      from = "scott@yahoo.com"
      date = Time.zone.now
      body = "Some message for the mailing list"
      email = Mail.new
      email.content_type = "text/plain"
      email.subject = subject
      email.from = from
      email.date = date
      email.body = body
      obra_chat = FactoryGirl.create(:mailing_list)
      email.to = obra_chat.name

      MailingListMailer.receive(email.encoded)

      posts = Post.all( :order => "date")
      post_from_db = posts.last
      assert_equal(subject, post_from_db.subject, "Subject")
      assert_equal(from, post_from_db.sender, "from")
      assert_equal_dates(date, post_from_db.date, "date")
      assert_equal("Some message for the mailing list", post_from_db.body, "body")
      assert_equal(obra_chat, post_from_db.mailing_list, "mailing_list")
    end
  end
  
  def test_receive
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    assert_difference "Post.count", 1 do
      MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/to_archive.eml"))

      posts = Post.all(:order => "date")
      post_from_db = posts.last
      assert_equal("[Fwd: For the Archives]", post_from_db.subject, "Subject")
      assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
      assert_equal_dates("Mon Jan 23 15:52:25 PST 2006", post_from_db.date, "Post date", "%a %b %d %H:%M:%S PST %Y")
      assert_equal(mailing_list, post_from_db.mailing_list, "mailing_list")
      assert(post_from_db.body["Too bad it doesn't work"], "body")
    end
  end
  
  def test_receive_no_list_matches
    assert_difference "Post.count", 0 do
      MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/to_archive.eml"))
    end
  end
  
  def test_receive_invalid_byte_sequence
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/invalid_byte_sequence.eml"))
  end

  def test_receive_rich_text
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    assert_difference "Post.count", 1 do
      MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/rich.eml"))

      posts = Post.all( :order => "date")
      post_from_db = posts.last
      assert_equal("Rich Text", post_from_db.subject, "Subject")
      assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
      assert_equal("Sat Jan 28 07:02:18 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
      assert_equal(mailing_list, post_from_db.mailing_list, "mailing_list")
      assert post_from_db.body["Rich text message with some formatting and a small attachment"], "body"
    end
  end
  
  def test_receive_bad_part_encoding
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    assert_difference "Post.count", 1 do
      MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/bad_encoding.eml"))

      posts = Post.all(:order => "date")
      post_from_db = posts.last
      assert_equal("Fwd: cyclist missing-- Mark Bosworth", post_from_db.subject, "Subject")
      assert(post_from_db.body["Thanks in advance for your help Kenji"], "body")
    end
  end
  
  def test_receive_outlook
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    assert_difference "Post.count", 1 do
      MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/outlook.eml"))

      posts = Post.all( :order => "date")
      post_from_db = posts.last
      assert_equal("Stinky Outlook Email", post_from_db.subject, "Subject")
      assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
      assert_equal("Sat Jan 28 07:28:31 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
      assert_equal(mailing_list, post_from_db.mailing_list, "mailing_list")
      expected_body = File.read("#{File.dirname(__FILE__)}/../../files/email/outlook_expected.eml")
      assert_equal(expected_body, post_from_db.body, "body")
    end
  end
  
  def test_receive_html
    mailing_list = FactoryGirl.create(:mailing_list, :name => "obra", :friendly_name => "OBRA Chat", :subject_line_prefix => "OBRA Chat")
    assert_difference "Post.count", 1 do
          MailingListMailer.receive(File.read("#{File.dirname(__FILE__)}/../../files/email/html.eml"))

          posts = Post.all(:order => "date")
          post_from_db = posts.last
          assert_equal("Thunderbird HTML", post_from_db.subject, "Subject")
          assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
          assert_equal("Sat Jan 28 10:19:04 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
          assert_equal(mailing_list, post_from_db.mailing_list, "mailing_list")
          expected_body = %Q{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
<h3>Race Results</h3>
<table border="1" cellpadding="2" cellspacing="2" width="100%">
  <tbody>
    <tr>
      <td valign="top"><b>Place<br>
      </b></td>
      <td valign="top"><b>Person<br>
      </b></td>
    </tr>
    <tr>
      <td valign="top">1<br>
      </td>
      <td valign="top">Ian Leitheiser<br>
      </td>
    </tr>
    <tr>
      <td valign="top">2<br>
      </td>
      <td valign="top">Kevin Condron<br>
      </td>
    </tr>
  </tbody>
</table>
<br>
</body>
</html>}
          assert_equal(expected_body, post_from_db.body, "body")
    end
  end
end
