class Dashboard
  DEFAULT_DUE_DATE = Time.now + (60 * 60 * 24 * 30)
  attr_reader :upcoming, :working, :deployed

  def initialize
    puts "Getting upcoming"
    @upcoming = cards.select{ |c| upcoming_lists.collect(&:id).include?(c.list_id) && !c.due.nil? }.sort_by(&:due)

    puts "Getting working"
    @working  = cards.select{ |c| c.list_id == working_list.id }.sort_by{|c| c.due || DEFAULT_DUE_DATE }

    puts "Getting deployed"
    @deployed = cards.select{ |c| c.list_id == deployed_list.id }

    puts "Done"

    self
  end

  private
  def board
    @board ||= Trello::Board.find(ENV['BOARD_ID'])
  end

  def lists
    @lists ||= board.lists
  end

  def cards
    @cards ||= board.cards
  end

  def upcoming_lists
    lists.select{ |l| ['Staged', 'Approved'].include?(l.name) }
  end

  def working_list
    lists.find{ |l| l.name == 'In Progress' }
  end

  def next_list
    lists.find{ |l| l.name == 'Next' }
  end

  def deployed_list
    lists.select{ |l| l.name =~ /Live\sthis\sweek$/i }.first
  end
end
