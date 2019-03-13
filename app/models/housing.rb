class Housing < ApplicationRecord
  has_many :users
  has_many :powers, dependent: :destroy
  has_one :enedis_datum
  # belongs_to :contracts
  validates :enedis_usage_point_id, presence: true
  validates :enedis_usage_point_id, uniqueness: true
end
