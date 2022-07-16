# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :documents,
           :enabled_modules,
           :enumerations,
           :issue_categories,
           :issue_statuses,
           :issues,
           :member_roles,
           :members,
           :messages,
           :news,
           :projects,
           :projects_trackers,
           :roles,
           :trackers,
           :users,
           :wiki_contents,
           :wiki_pages,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    i = issues(:issues_001)
    assert i.backlink_visible?(u)
  end

  def test_backlink_visible_false
    roles(:roles_001).remove_permission!(:view_issues)
    u = users(:users_002)
    i = issues(:issues_001)
    assert_not i.backlink_visible?(u)
  end

  def test_destroy_from
    i = issues(:issues_001)
    f = i.back_links.first
    assert_not_nil f

    i.destroy!
    assert_nil InnerLinkRelation.find_by(id: f.id)
  end

  def test_destroy_to
    i = issues(:issues_002)
    t = i.links.first
    assert_not_nil t

    i.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_document_id
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = 'document#1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = documents(:documents_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_document_title
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = 'document:"Test document"'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = documents(:documents_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_esc
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '!#1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_empty l
  end

  def test_save_issue_quoted
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = "\r\n> #1 \r\n#2"
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = issues(:issues_002)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_textile
    Setting.text_formatting = 'textile'
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '<pre>#1</pre>#2'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = issues(:issues_002)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_markdown
    Setting.text_formatting = 'markdown'
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '~~~#1~~~#2'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = issues(:issues_002)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_commonmark
    Setting.text_formatting = 'common_mark'
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '```#1```#2'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = issues(:issues_002)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_empty l
  end

  def test_save_issue_ref1
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '#1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = issues(:issues_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_issue_ref2
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '#1, #2'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 2, l.length

    t = issues(:issues_001)
    assert l.any? { |r| r.to == t }

    t = issues(:issues_002)
    assert l.any? { |r| r.to == t }
  end

  def test_save_message_id
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = 'message#1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = messages(:messages_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_news_id
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = 'news#1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = news(:news_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_news_title
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = 'news:"eCookbook first release !"'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = news(:news_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_wiki_title
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '[[CookBook_documentation]]'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = wiki_contents(:wiki_contents_001)
    assert l.any? { |r| r.to == t }
  end

  def test_save_wiki_title_alias
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Issue.new
      f.author = users(:users_001)
      f.project = projects(:projects_001)
      f.tracker = trackers(:trackers_001)
      f.subject = 'test'
      f.description = '[[CookBook_documentation|Test]]'
      f.save!
      f
    end

    l = get_relation(f)
    assert_equal 1, l.length

    t = wiki_contents(:wiki_contents_001)
    assert l.any? { |r| r.to == t }
  end
end
