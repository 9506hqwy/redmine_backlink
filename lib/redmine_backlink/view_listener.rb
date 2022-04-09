# frozen_string_literal: true

module RedmineBacklink
  class ViewListener < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_queries_bottom, partial: 'backlink/issues_sidebar_queries_bottom'
    render_on :view_layouts_base_body_bottom, partial: 'backlink/base_body_bottom'
    render_on :view_wiki_show_sidebar_bottom, partial: 'backlink/wiki_show_sidebar_bottom'
  end
end
