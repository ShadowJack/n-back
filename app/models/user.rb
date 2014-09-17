# Model that consists of data about player
# vk_id - id user in vk.com
# score - current game score
# options - current game options such as difficulty level and types
class User < ActiveRecord::Base
  has_many :progress_entries, dependent: :destroy
  validates :vk_id, :score, :options, presence: true
end
