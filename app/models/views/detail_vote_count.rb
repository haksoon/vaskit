 # This is a report from a SQL View
class Views::DetailVoteCount < ActiveRecord::Base
  self.table_name = 'view_ask_details'

  def self.average_vote_count(ask_id)
    ask = self.where(:ask_id => ask_id)

    if ask.length == 2 && ask[0].gender == nil && ask[0].age == nil && ask[1].gender == nil && ask[1].age == nil
      total_vote_count = 0
      vote_gender_average = 0
      vote_age_average = 0
    else
      total_vote_count = ask.count
      vote_gender_average = ask.average(:gender).round
      vote_age_average = ask.average(:age).round
    end

    average_vote_count = {
      :total_vote_count => total_vote_count,
      :vote_gender_average => vote_gender_average,
      :vote_age_average => vote_age_average
    }
  end

  protected

  def readonly?
    true
  end
end
