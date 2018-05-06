class FileGetter
  require 'date'

  FILE_MATCH = /\d+-\d+-\d+_[[:alnum:]]+\.txt$/
  DATE_MATCH = /\d+-\d+-\d+/

  def self.latest(name)
    files = Dir["#{ ENV["HOME"] }/documents/refactoring2/workspace/*#{name}*.txt"]

    throw RuntimeError if files.empty?

    files.sort_by! do |file|
      file_name_match = FILE_MATCH.match file
      date_match = file_name_match.to_s.match DATE_MATCH
      
      DateTime.parse(date_match.to_s)
    end
    files.last
  end
end
