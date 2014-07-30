class User < ActiveRecord::Base
  has_many :progress_entries, dependent: :destroy
end
