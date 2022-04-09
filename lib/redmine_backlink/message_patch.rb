# frozen_string_literal: true

module RedmineBacklink
  module MessagePatch
    def self.prepended(base)
      base.class_eval do
        acts_as_linkable(attribute: :content)
      end
    end
  end
end

Message.prepend RedmineBacklink::MessagePatch
