class Power < ApplicationRecord
  belongs_to :housing

  validates :power_time, :housing, presence: true
  validates :power_time, uniqueness: { scope: :housing_id }
end
