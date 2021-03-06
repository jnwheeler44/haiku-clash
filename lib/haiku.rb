require 'ruby_rhymes'
require 'swearjar'
require 'mongoid'

class Haiku
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :lines, :type => Array
  field :record, :type => Hash, :default => {:win => 0, :loss => 0}

  embeds_many :votes

  validate :proper_number_of_syllables, :only_3_lines

  def proper_number_of_syllables
    unless syllables == [5, 7, 5]
      errors[:base] = "Sorry, your syllable counts are wrong! We were expecting 5,7,5."
    end
  end

  def only_3_lines
    unless lines.length == 3 
      errors[:base] = "A haiku must have exactly 3 lines. No more, No Less."
    end
  end

  def syllables
    lines.map { |l| l.to_phrase.syllables }
  end

  def wins
    votes.select { |v| v.type == :win }
  end

  def losses
    votes.select { |v| v.type == :loss }
  end

  def on_fire?
    wins = votes.all.order(:created_at, :desc).take(5).reject { |v| v.type == :loss }
    wins.length == 5
  end

  def update_record!(sym)
    record[sym.to_s] += 1
    self
  end

end

class Vote
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  embedded_in :haiku

  field :type, :type => Symbol
end
