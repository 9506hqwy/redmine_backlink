# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class MessageTest < ActiveSupport::TestCase
  fixtures :boards,
           :issues,
           :member_roles,
           :members,
           :messages,
           :projects,
           :roles,
           :users,
           :inner_link_relations

  def test_backlink_visible_true
    u = users(:users_002)
    m = messages(:messages_001)
    assert m.backlink_visible?(u)
  end

  def test_backlink_visible_false
    roles(:roles_001).remove_permission!(:view_messages)
    u = users(:users_002)
    m = messages(:messages_001)
    assert_not m.backlink_visible?(u)
  end

  def test_destroy
    m = messages(:messages_001)
    t = m.links.first
    assert_not_nil t

    m.destroy!
    assert_nil InnerLinkRelation.find_by(id: t.id)
  end

  def test_save_issue_ref0
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Message.new
      f.board = boards(:boards_001)
      f.subject = 'test'
      f.content = '1'
      f.save!
      f
    end

    l = get_relation(f)
    assert_empty l
  end

  def test_save_issue_ref1
    InnerLinkRelation.destroy_all

    f = save_model do
      f = Message.new
      f.board = boards(:boards_001)
      f.subject = 'test'
      f.content = '#1'
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
      f = Message.new
      f.board = boards(:boards_001)
      f.subject = 'test'
      f.content = '#1, #2'
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
