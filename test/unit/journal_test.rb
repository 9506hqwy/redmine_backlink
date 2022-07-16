# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase
  fixtures :enabled_modules,
           :enumerations,
           :issues,
           :issue_categories,
           :issue_statuses,
           :journals,
           :member_roles,
           :members,
           :projects,
           :projects_trackers,
           :roles,
           :trackers,
           :users,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    j = journals(:journals_001)
    assert j.backlink_visible?(u)
  end

  def test_backlink_visible_false_issue
    roles(:roles_001).remove_permission!(:view_issues)
    u = users(:users_002)
    j = journals(:journals_001)
    assert_not j.backlink_visible?(u)
  end

  def test_backlink_visible_false_private_notes
    roles(:roles_001).remove_permission!(:view_private_notes)
    u = users(:users_002)
    j = journals(:journals_001)
    j.private_notes = true
    j.save!
    assert_not j.backlink_visible?(u)
  end

  def test_destroy
    j = journals(:journals_003)
    t = j.links.first
    assert_not_nil t

    j.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Journal.new
      f.journalized = issues(:issues_001)
      f.notes = '1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_empty l
  end

  def test_save_issue_ref1
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Journal.new
      f.journalized = issues(:issues_001)
      f.notes = '#1'
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
      f = Journal.new
      f.journalized = issues(:issues_001)
      f.notes = '#1, #2'
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
