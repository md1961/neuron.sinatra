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
    all_by_hour = all(options).group_by { |entry| "#{entry.date} #{entry.time[0, 2]}H" }
    all_by_hour.map { |date_hour, entries| [date_hour, entries.map(&:users).map(&:size).max] }
  end

  def self.max_user_by_date(options={})
    all_by_date = all(options).group_by { |entry| "#{entry.date}" }
    all_by_date.map { |date, entries| [date, entries.map(&:users).map(&:size).max] }
  end

  class Entry
    attr_reader :date, :time, :users

    def initialize(line, users)
      @date, @time = line.split
      @date += "(#{Date.parse(@date).strftime('%a')})"
      @time = @time[0, 5]
      @users = users
    end

    def users_by_division
      users.group_by { |user| user.division }
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
            break if date_from && entry.date < date_from
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

