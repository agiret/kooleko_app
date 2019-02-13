class EnedisDatum < ApplicationRecord
  belongs_to :housing

  validates :housing_id, uniqueness: true, presence: true
end
