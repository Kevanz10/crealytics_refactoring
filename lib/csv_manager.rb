class CsvManager
  require 'csv'
  require 'byebug'

  DEFAULT_CSV_OPTIONS = { :col_sep => "\t", :headers => :first_row }

  LINES_PER_FILE = 120000
  
  def self.read_csv(file)
    CSV.read(file, DEFAULT_CSV_OPTIONS)
  end

  def self.write_sorted(content, headers, output)
    CSV.open(output, "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
      csv << headers
      content.each do |row|
        csv << row
      end
    end
  end

  def self.open(file_name, file_index,merger)
    CSV.open(file_name + "#{file_index}.txt", "wb", { :col_sep => "\t", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
      headers_written = false
      line_count = 0
      while line_count < LINES_PER_FILE
        begin
          merged = merger.next
          if not headers_written
            csv << merged.keys
            headers_written = true
            line_count +=1
          end
          csv << merged
          line_count +=1
        rescue StopIteration
          done = true
          break
        end
      end
      file_index += 1
    end
  end
end