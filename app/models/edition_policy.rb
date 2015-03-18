class EditionPolicy < ActiveRecord::Base
  belongs_to :edition

  validates :edition, :policy_content_id, presence: true
end
