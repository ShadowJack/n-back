class ProgressEntry < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :result, :nsteps, presence: true
  
  after_save :update_user_score, on: :create
  #result: "s13-10 p7-5 ..."
  protected
    def update_user_score
      logger.debug "After ProgressEntry has been created: " + self.inspect
      results = self.result.split(" ").map{|res| res[1..-1]}
      coeff = self.nsteps * (results.count - 1)
      all = 0
      right = 0
      results.each do |res|
        all += res.split("-")[0].to_i
        right += res.split("-")[1].to_i
      end
      user = self.user
      user.score += coeff * (right * 100 / all ).floor
      user.save
    end
end
