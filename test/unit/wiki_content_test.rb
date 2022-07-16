# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class WikiContentTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :issues,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    w = wiki_contents(:wiki_contents_001)
    assert w.backlink_visible?(u)
  end

  def test_backlink_visible_false
    roles(:roles_001).remove_permission!(:view_wiki_pages)
    u = users(:users_002)
    w = wiki_contents(:wiki_contents_001)
    assert_not w.backlink_visible?(u)
  end

  def test_destroy
    w = wiki_contents(:wiki_contents_001)
    t = w.links.first
    assert_not_nil t

    w.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = WikiContent.new
      f.page = wiki_pages(:wiki_pages_001)
      f.text = '1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_empty l
  end

  def test_save_issue_ref1
    InnerLinkRelation.destroy_all

    f = save_model do
      f = WikiContent.new
      f.page = wiki_pages(:wiki_pages_001)
      f.text = '#1'
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
      f = WikiContent.new
      f.page = wiki_pages(:wiki_pages_001)
      f.text = '#1, #2'
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
