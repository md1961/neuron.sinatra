
LOG_FILENAME = '/home/kumagai/neuron_loggedins.log'

class NeuronLoggedin

  # Entry の配列を返す
  def self.all
    read_log
  end

  def self.max_user_by_hour
    all_by_hour = all.group_by { |entry| "#{entry.date} #{entry.time[0, 2]}H" }
    all_by_hour.map { |date_hour, entries| [date_hour, entries.map(&:users).map(&:size).max] }
  end

  class Entry
    attr_reader :date, :time, :users

    def initialize(line)
      @date, @time = line.split
      @time = @time[0, 5]
      @users = Array.new
    end
  end

  class User
    attr_reader :description

    def initialize(line)
      @description = line
    end
  end

  private

    def self.read_log
      entries = Array.new

      entry = nil
      open(LOG_FILENAME) do |f|
        f.each do |line|
          unless summary?(line)
            entry.users << User.new(line)
          else
            entries << entry if entry
            entry = Entry.new(line)
          end
        end
      end
      entries << entry if entry

      return entries
    end

    RE_SUMMARY = /\A\d/

    def self.summary?(line)
      line =~ RE_SUMMARY
    end
end

