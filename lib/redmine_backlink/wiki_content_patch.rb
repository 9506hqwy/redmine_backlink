# frozen_string_literal: true

module RedmineBacklink
  module WikiContentPatch
    def self.prepended(base)
      base.class_eval do
        acts_as_linkable(attribute: :text)
      end
    end
  end
end

WikiContent.prepend RedmineBacklink::WikiContentPatch
