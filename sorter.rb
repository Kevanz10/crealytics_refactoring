require_relative './csv_manager'

class Sorter
  def initialize(file)
    @file = file
    @content = CsvManager.read_csv(file)
  end
  def sort
    output = "#{@file}.sorted"
    
    content = sorter_by_column('Clicks')
    CsvManager.write_sorted(content, @content.headers, output)
    output
  end

  def sorter_by_column(column)
    index_of_key = @content.headers.index(column)
    @content.sort_by { |a| -a[index_of_key].to_i }
  end
end