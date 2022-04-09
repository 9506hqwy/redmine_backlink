# frozen_string_literal: true

module RedmineBacklink
  module JournalPatch
    def self.prepended(base)
      base.class_eval do
        acts_as_linkable(attribute: :notes)
      end
    end
  end
end

Journal.prepend RedmineBacklink::JournalPatch
