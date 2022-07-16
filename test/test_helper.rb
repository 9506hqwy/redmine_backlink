# frozen_string_literal: true

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
require 'test_after_commit' if ActiveRecord::VERSION::MAJOR < 5
ActiveRecord::FixtureSet.create_fixtures(
  File.expand_path('../fixtures', __FILE__),
  [
    'inner_link_relations',
  ]
)

def get_relation(from)
  InnerLinkRelation.where(from_type: from.class.name, from_id: from.id).to_a
end

def save_model(&block)
  if ActiveRecord::VERSION::MAJOR >= 5
    yield
  else
    TestAfterCommit.with_commits(true, &block)
  end
end
