class EnedisDatum < ApplicationRecord
  belongs_to :housing

  validates :housing_id, presence: true
end
