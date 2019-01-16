class Housing < ApplicationRecord
  has_many :users
  belongs_to :contracts
end
