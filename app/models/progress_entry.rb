class ProgressEntry < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :opt, :accuracy, presence: true
  
  after_save :update_user_score, on: :create
  
  protected
    def update_user_score
      logger.debug "After ProgressEntry has been created: " + self.inspect
      opts = self.opt.split("")
      coeff = opts[0].to_i * (opts.count - 1)
      self.user.score += coeff * self.accuracy
      self.user.save
    end
end
