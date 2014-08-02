class User < ActiveRecord::Base
  has_many :progress_entries, dependent: :destroy
  validates :vk_id, :score, :options, presence: true
end
