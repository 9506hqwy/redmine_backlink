# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class DocumentTest < ActiveSupport::TestCase
  fixtures :documents,
           :issues,
           :member_roles,
           :members,
           :projects,
           :roles,
           :users,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    d = documents(:documents_001)
    assert d.backlink_visible?(u)
  end

  def test_backlink_visible_false
    roles(:roles_001).remove_permission!(:view_documents)
    u = users(:users_002)
    d = documents(:documents_001)
    assert_not d.backlink_visible?(u)
  end

  def test_destroy
    d = documents(:documents_001)
    t = d.links.first
    assert_not_nil t

    d.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Document.new
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
      f = Document.new
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
      f = Document.new
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
