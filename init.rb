# frozen_string_literal: true

basedir = File.expand_path('../lib', __FILE__)
libraries =
  [
    'redmine_backlink/linkable',
    'redmine_backlink/application_helper_patch',
    'redmine_backlink/document_patch',
    'redmine_backlink/issue_patch',
    'redmine_backlink/journal_patch',
    'redmine_backlink/message_patch',
    'redmine_backlink/news_patch',
    'redmine_backlink/utils',
    'redmine_backlink/view_listener',
    'redmine_backlink/wiki_content_patch',
  ]

libraries.each do |library|
  require_dependency File.expand_path(library, basedir)
end

Redmine::Plugin.register :redmine_backlink do
  name 'Redmine Backlink plugin'
  author '9506hqwy'
  description 'This is a back link plugin for Redmine'
  version '0.1.0'
  url 'https://github.com/9506hqwy/redmine_backlink'
  author_url 'https://github.com/9506hqwy'
end
