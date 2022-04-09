# frozen_string_literal: true

class InnerLinkRelation < ActiveRecord::Base
  belongs_to :from, polymorphic: true
  belongs_to :to, polymorphic: true

  validates :from, presence: true
  validates :to, presence: true
end
