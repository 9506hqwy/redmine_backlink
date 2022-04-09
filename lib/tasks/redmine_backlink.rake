namespace :redmine_backlink do
  desc "Drop and create inner_link_relation table"
  task relink: :environment do
    InnerLinkRelation.destroy_all

    Document.all.map(&:backlink_parse_inner_link)
    Issue.all.map(&:backlink_parse_inner_link)
    Journal.all.map(&:backlink_parse_inner_link)
    Message.all.map(&:backlink_parse_inner_link)
    News.all.map(&:backlink_parse_inner_link)
    WikiPage.all.map(&:content).map(&:backlink_parse_inner_link)
  end
end
