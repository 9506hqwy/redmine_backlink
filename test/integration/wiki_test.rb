# frozen_string_literal: true

require File.expand_path('../../test_helper', __FILE__)

class LinkToWikiTest < Redmine::IntegrationTest
  include Redmine::I18n

  fixtures :attachments,
           :boards,
           :documents,
           :email_addresses,
           :enabled_modules,
           :enumerations,
           :issue_statuses,
           :issues,
           :journal_details,
           :journals,
           :member_roles,
           :members,
           :messages,
           :news,
           :projects,
           :projects_trackers,
           :roles,
           :trackers,
           :users,
           :versions,
           :wiki_content_versions,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :inner_link_relations

  def test_show
    log_user('jsmith', 'jsmith')

    get('/projects/ecookbook/wiki/CookBook_documentation')

    assert_response :success
    assert_select 'a[href="/documents/1"]'
    assert_select 'a[href="/issues/2"]'
    assert_select 'a[href="/issues/2#change-3"]'
    assert_select 'a[href="/boards/1/topics/1"]'
    assert_select 'a[href="/news/1"]'
    assert_select 'a[href="/projects/ecookbook/wiki/Another_page"]'
  end

  def test_show_version
    log_user('jsmith', 'jsmith')

    get('/projects/ecookbook/wiki/CookBook_documentation/1')

    assert_response :success
    assert_select 'a[href="/documents/1"]'
    assert_select 'a[href="/issues/2"]'
    assert_select 'a[href="/issues/2#change-3"]'
    assert_select 'a[href="/boards/1/topics/1"]'
    assert_select 'a[href="/news/1"]'
    assert_select 'a[href="/projects/ecookbook/wiki/Another_page"]'
  end
end
