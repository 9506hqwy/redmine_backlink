# frozen_string_literal: true

class InnerLinkRelation < RedmineBacklink::Utils::ModelBase
  belongs_to :from, polymorphic: true
  belongs_to :to, polymorphic: true

  validates :from, presence: true
  validates :to, presence: true
end
