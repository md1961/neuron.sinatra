# vi: set fileencoding=utf-8 :

require 'reverse_line_reader'


LOG_FILENAME = '/home/kumagai/neuron_loggedins.log'


class NeuronLoggedin

  DATE_FORMAT = '%Y-%m-%d'

  # Entry の配列を返す
  def self.all(options={})
    read_log(options)
  end

  def self.max_user_by_hour(options={})
    all_by_hour = all(options).group_by { |entry| entry.timestamp.to_hourly }
    all_by_hour.map { |date_hour, entries| [date_hour, entries.map(&:users).map(&:size).max] }
  end

  def self.max_user_by_date(options={})
    all_by_date = all(options).group_by { |entry| entry.timestamp.to_daily }
    all_by_date.map { |date, entries| [date, entries.map(&:users).map(&:size).max] }
  end

  class Entry
    attr_reader :timestamp, :users

    def initialize(line, users)
      @timestamp = Timestamp.new(line)
      @users = users
    end

    def users_by_division
      users.group_by { |user| user.division }
    end
  end

  class Timestamp
    attr_reader :date, :time

    HOUR_RANGE_FOR_DAYTIME = (7 .. 18)

    # @date は "2012-07-17(Tue)"、@time は "13:25" の形式にする
    def initialize(line)
      @date, @time = line.split
      @date += "(#{Date.parse(@date).strftime('%a')})"
      @time = @time[0, 5]
    end

    def to_hourly
      @time = @time[0, 2] + 'H'
      self
    end

    def to_daily
      @time = ''
      self
    end

    def daytime?
      HOUR_RANGE_FOR_DAYTIME === time.to_i
    end

    def weekend?
      obj_date = Date.parse(date)
      obj_date.saturday? || obj_date.sunday?
    end

    def to_s
      strs = Array.new
      strs << date
      strs << time unless time.empty?
      strs.join(' ')
    end

    def eql?(other)
      return false unless other.respond_to?(:date) && other.respond_to?(:time)
      date == other.date && time == other.time
    end

    def hash
      to_s.hash
    end
  end

  class User
    attr_reader :id, :real_name, :division

    RE_TO_PARSE_LINE = /([^(]+)\(([^@]*)@([^)]*)\)/
    RE_TO_DELETE_FROM_DIVISION = /,勇払共通|勇払共通,/

    def initialize(line)
      unless line =~ RE_TO_PARSE_LINE
        raise "Cannot parse argument line '#{line}'"
      end

      @id        = $1
      @real_name = $2
      @division  = $3
      @division.gsub!(RE_TO_DELETE_FROM_DIVISION, '')
    end

    def to_s
      s = "#{id}"
      unless real_name.empty?
        s += "(#{real_name})"
      end
      s
    end
  end

  private

    def self.read_log(options={})
      date_from = options[:from]

      entries = Array.new
      users   = Array.new
      open(LOG_FILENAME) do |f|
        ReverseLineReader.new(f).each do |line|
          line.force_encoding(Encoding.default_external)
          unless summary?(line)
            users << User.new(line)
          else
            entry = Entry.new(line, users)
            break if date_from && entry.timestamp.date < date_from
            entries << entry

            users = Array.new
          end
        end
      end

      return entries
    end

    RE_SUMMARY = /\A\d/

    def self.summary?(line)
      line =~ RE_SUMMARY
    end
end

