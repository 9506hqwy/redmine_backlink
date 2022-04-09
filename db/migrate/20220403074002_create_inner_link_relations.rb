# frozen_string_literal: true

class CreateInnerLinkRelations < RedmineBacklink::Utils::Migration
  def change
    create_table :inner_link_relations do |t|
      t.references :from, null: false, polymorphic: true
      t.references :to, null: false, polymorphic: true
    end
  end
end
