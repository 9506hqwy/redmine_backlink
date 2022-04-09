# frozen_string_literal: true

module RedmineBacklink
  module IssuePatch
    def self.prepended(base)
      base.class_eval do
        acts_as_linkable(attribute: :description)
      end
    end
  end
end

Issue.prepend RedmineBacklink::IssuePatch
