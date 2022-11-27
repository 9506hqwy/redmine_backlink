# frozen_string_literal: true

module RedmineBacklink
  module ApplicationHelperPatch
    def backlink_each(links, sublinks, &block)
      parents = links
      parents |= sublinks.map(&:backlink_parent).compact if sublinks.any?

      parents.sort_by(&:id).each do |parent|
        children = sublinks.select { |s| s.backlink_parent&.id == parent.id }
        yield parent, links.include?(parent), children
      end
    end

    def backlink_link_to(object, short=false, html=true)
      case object.class.name
      when 'Board'
        backlink_link_to_board(object, html)
      when 'Document'
        backlink_link_to_document(object, html)
      when 'Issue'
        backlink_link_to_issue(object, short, html)
      when 'Journal'
        backlink_link_to_journal(object, html)
      when 'Message'
        backlink_link_to_message(object, html)
      when 'News'
        backlink_link_to_news(object, html)
      when 'WikiContent'
        backlink_link_to_wiki_content(object, html)
      end
    end

    def backlink_link_to_author(object)
      case object.class.name
      when 'Issue', 'Message', 'News', 'WikiContent'
        link_to_user(object.author)
      when 'Journal'
        link_to_user(object.user)
      else # Document
        nil
      end
    end

    def backlink_link_to_board(board, html=true)
      return board.name unless html

      link_to(board.name,
              project_board_url(board.project, board, only_path: true),
              class: 'board')
    end

    def backlink_link_to_document(document, html=true)
      title = "#{document.category.name}: #{document.title}"
      return title unless html

      link_to(title,
              document_path(document),
              class: 'document')
    end

    def backlink_link_to_issue(issue, short=false, html=true)
      text = "#{issue.tracker} ##{issue.id}"
      text += ": #{issue.subject}" unless short
      return text unless html

      link_to_issue(issue, subject: !short)
    end

    def backlink_link_to_journal(journal, html=true)
      text = "change-#{journal.id}"
      return text unless html

      link_to(text,
              issue_url(journal.issue, only_path: true, anchor: "change-#{journal.id}"),
              class: journal.issue.css_classes)
    end

    def backlink_link_to_message(message, html=true)
      return message.subject.truncate(60) unless html

      link_to_message(message, {only_path: true}, class: 'mesasge')
    end

    def backlink_link_to_news(news, html=true)
      return news.title unless html

      link_to(news.title,
              news_url(news, only_path: true),
              class: 'news')
    end

    def backlink_link_to_wiki_content(wiki_content, html=true)
      page = wiki_content.page
      project = page.project
      title = "#{page.pretty_title} (#{l(:label_version)}#{wiki_content.version})"
      return title unless html

      link_to(title,
              project_wiki_page_path(project, page.title))
    end
  end
end

Rails.application.config.after_initialize do
  DocumentsController.send(:helper, RedmineBacklink::ApplicationHelperPatch)
  IssuesController.send(:helper, RedmineBacklink::ApplicationHelperPatch)
  MessagesController.send(:helper, RedmineBacklink::ApplicationHelperPatch)
  NewsController.send(:helper, RedmineBacklink::ApplicationHelperPatch)
  WikiController.send(:helper, RedmineBacklink::ApplicationHelperPatch)
end
