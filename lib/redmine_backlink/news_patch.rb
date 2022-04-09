# frozen_string_literal: true

module RedmineBacklink
  module NewsPatch
    def self.prepended(base)
      base.class_eval do
        acts_as_linkable(attribute: :description)
      end
    end
  end
end

News.prepend RedmineBacklink::NewsPatch
