class Housing < ApplicationRecord
  has_many :users
  # belongs_to :contracts
  validates :enedis_usage_point_id, presence: true
  validates :enedis_usage_point_id, uniqueness: true
end
