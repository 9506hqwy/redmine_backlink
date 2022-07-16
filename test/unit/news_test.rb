# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class NewsTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :issues,
           :member_roles,
           :members,
           :news,
           :projects,
           :roles,
           :users,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    n = news(:news_001)
    assert n.backlink_visible?(u)
  end

  def test_backlink_visible_false
    roles(:roles_001).remove_permission!(:view_news)
    u = users(:users_002)
    n = news(:news_001)
    assert_not n.backlink_visible?(u)
  end

  def test_destroy
    n = news(:news_001)
    t = n.links.first
    assert_not_nil t

    n.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = News.new
      f.project = projects(:projects_001)
      f.title = 'test'
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
      f = News.new
      f.project = projects(:projects_001)
      f.title = 'test'
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
      f = News.new
      f.project = projects(:projects_001)
      f.title = 'test'
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
end
