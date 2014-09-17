# class: model that repreents data about each game played by player
# Consists of:
#       user_id - player that this result belongs to
#       nsteps - current game level
#       result - "s13-10 p7-5 ..." - type, all occurences,
#       right guessed occurences
class ProgressEntry < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :result, :nsteps, presence: true

  after_save :update_user_score, on: :create

  protected

  def update_user_score
    results = result.split(' ').map { |res| res[1..-1] }
    coeff = 1 + nsteps * (results.count - 1)
    all = 0
    right = 0
    results.each do |res|
      all += res.split('-')[0].to_i
      right += res.split('-')[1].to_i
    end

    user = self.user
    accuracy = (right * 100 / all).floor
    user.score += coeff * accuracy
    if accuracy >= 80 && nsteps < 6 # automatically level up
      user.options = (nsteps + 1).to_s + user.options[1..-1]
    elsif accuracy <= 30 && nsteps > 2
      user.options = (nsteps - 1).to_s + user.options[1..-1]
    end
    user.save
  end
end
