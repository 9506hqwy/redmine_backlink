# frozen_string_literal: true

module RedmineBacklink
  module Linkable
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def acts_as_linkable(options = {})
        class_attribute :linkable_attribute
        self.linkable_attribute = options[:attribute]

        has_many(:back_links, class_name: :InnerLinkRelation, as: :to, dependent: :destroy)
        has_many(:links, class_name: :InnerLinkRelation, as: :from, dependent: :destroy)

        include InstanceMethods

        after_save(:backlink_parse_inner_link)
      end
    end

    module InstanceMethods
      def backlink_by_type(type)
        back_links.where(from_type: type).select { |l| l.from.backlink_visible? }.map(&:from)
      end

      def backlink_parent
        case self.class.name
        when 'Journal'
          issue
        when 'Message'
          board
        else
          nil
        end
      end

      def backlink_parse_inner_link
        links.destroy_all

        content = send(linkable_attribute)
        return unless content

        content = content.gsub(%r{\r\n(\>\s)+(.*?)\r\n}m, '')

        case Setting.text_formatting
        when 'textile'
          content = content.gsub(%r{<pre>(.*?)</pre>}m, '')
        when 'markdown', 'common_mark', 'commonmark'
          content = content.gsub(%r{(~~~|```)(.*?)(~~~|```)}m, '')
        end

        backlink_references(content) do |to_object|
          next unless to_object

          from_object = self
          next if from_object == to_object

          link = links.where(to_type: to_object.class.name, to_id: to_object.id).first
          next if link

          link = InnerLinkRelation.new
          link.from = from_object
          link.to = to_object
          link.save
        end
      end

      def backlink_references(text, &block)
        return unless text

        text.scan(LINKS_RE) do |_|
          next if $~[:esc]

          prefix = $~[:prefix]
          sep = $~[:sep1] || $~[:sep2]
          identifier = $~[:identifier1] || $~[:identifier2]
          comment = $~[:comment]
          wiki = $~[:identifier3]

          if wiki
            yield WikiPage.find_by(title: wiki)&.content
          elsif sep.present? && identifier.present?
            case prefix
            when nil
              next if comment

              case sep
              when '#', '##'
                yield Issue.find_by(id: identifier)
              end
            when 'document'
              case sep
              when '#'
                yield Document.find_by(id: identifier)
              when ':'
                title = identifier.gsub(/^"(.*)"$/, "\\1")
                yield Document.find_by(title: title)
              end
            when 'message'
              case sep
              when '#'
                yield Message.find_by(id: identifier)
              end
            when 'news'
              case sep
              when '#'
                yield News.find_by(id: identifier)
              when ':'
                title = identifier.gsub(/^"(.*)"$/, "\\1")
                yield News.find_by(title: title)
              end
            end
          end
        end
      end

      def backlink_visible?(user=User.current)
        return visible?(user) if respond_to?(:visible?)

        if self.instance_of?(Journal)
          return false unless issue.visible?(user)

          return !private_notes? || user.allowed_to?(:view_private_notes, project)
        end

        true
      end

      LINKS_RE =
        %r{
            (?<esc>!)?
            (?:
              (?:
                (?:(?<project_identifier>[a-z0-9\-_]+):)?
                (?<prefix>document|message|news)?
                (?:
                  (?:
                    (?<sep1>\#\#?)
                     (?<identifier1>\d+)
                    (?<comment>(?:\#note)?-\d+)?
                  )
                  |
                  (?:
                    (?<sep2>:)
                    (?<identifier2>[^"\s<>][^\s<>]*?|"[^"]+?")
                  )
                )
              )
              |
              (?:
                \[\[
                  (?<identifier3>[^,\./\?\;\|\s]+)(?:\|[^\]]+)?
                \]\]
              )
            )
          }x
    end
  end
end

ActiveRecord::Base.include RedmineBacklink::Linkable
