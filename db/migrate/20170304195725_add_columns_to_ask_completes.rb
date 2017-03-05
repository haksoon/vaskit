class AddColumnsToAskCompletes < ActiveRecord::Migration
  def up
    add_column :ask_completes, :left_vote_count, :integer
    add_column :ask_completes, :right_vote_count, :integer

    ask_completes = AskComplete.all
    ask_completes.each do |ask_complete|
      left_vote_count = ask_complete.ask.left_ask_deal.vote_count
      right_vote_count = ask_complete.ask.right_ask_deal.vote_count
      ask_deal_id = ask_complete.ask_deal_id if ask_complete.ask_deal_id.nil? || ask_complete.ask_deal_id.nonzero?
      reference_date = Date.new(2017, 1, 25)
      star_point = ask_complete.star_point if ask_complete.star_point && ask_complete.created_at < reference_date
      ask_complete.update(ask_deal_id: ask_deal_id,
                          star_point: star_point,
                          left_vote_count: left_vote_count,
                          right_vote_count: right_vote_count)
    end
  end

  def down
    remove_column :ask_completes, :left_vote_count
    remove_column :ask_completes, :right_vote_count
  end
end
