require_relative 'lib/combiner'
require_relative 'lib/file_getter'
require_relative 'lib/sorter'
require_relative 'lib/string'
require_relative 'lib/string'
require_relative 'lib/float'

class Modifier
  
  KEYWORD_UNIQUE_ID = 'Keyword Unique ID'
  LAST_VALUE_WINS = ['Account ID', 'Account Name', 'Campaign', 'Ad Group', 'Keyword', 'Keyword Type', 'Subid', 'Paused', 'Max CPC', 'Keyword Unique ID', 'ACCOUNT', 'CAMPAIGN', 'BRAND', 'BRAND+CATEGORY', 'ADGROUP', 'KEYWORD']
  LAST_REAL_VALUE_WINS = ['Last Avg CPC', 'Last Avg Pos']
  INT_VALUES = ['Clicks', 'Impressions', 'ACCOUNT - Clicks', 'CAMPAIGN - Clicks', 'BRAND - Clicks', 'BRAND+CATEGORY - Clicks', 'ADGROUP - Clicks', 'KEYWORD - Clicks']
  FLOAT_VALUES = ['Avg CPC', 'CTR', 'Est EPC', 'newBid', 'Costs', 'Avg Pos']

  def initialize(saleamount_factor, cancellation_factor)
    @saleamount_factor = saleamount_factor
    @cancellation_factor = cancellation_factor
  end

  def modify(input)
    input = Sorter.new(input)
    input = input.sort

    input_enumerator = CsvManager.lazy_read(input)

    combiner = Combiner.new do |value|
      value[KEYWORD_UNIQUE_ID]
    end.combine(input_enumerator)

    merger = Enumerator.new do |yielder|
      while true
        begin
          list_of_rows = combiner.next
          merged = combine_hashes(list_of_rows)
          yielder.yield(combine_values(merged))
        rescue StopIteration
          break
        end
      end
    end

    done = false
    file_index = 0
    file_name = input.gsub('.txt', '')
    while not done do
      CsvManager.open(file_name, file_index, merger)
    end
  end

  private

  def combine(merged)
    result = []
    merged.each do |_, hash|
      result << combine_values(hash)
    end
    result
  end

  def combine_values(hash)
    LAST_VALUE_WINS.each do |key|
      hash[key] = hash[key].last
    end
    LAST_REAL_VALUE_WINS.each do |key|
      hash[key] = hash[key].select {|v| not (v.nil? or v == 0 or v == '0' or v == '')}.last
    end
    INT_VALUES.each do |key|
      hash[key] = hash[key][0].to_s
    end
    FLOAT_VALUES.each do |key|
      hash[key] = hash[key][0].from_german_to_f.to_german_s
    end
    ['number of commissions'].each do |key|
      hash[key] = (@cancellation_factor * hash[key][0].from_german_to_f).to_german_s
    end
    ['Commission Value', 'ACCOUNT - Commission Value', 'CAMPAIGN - Commission Value', 'BRAND - Commission Value', 'BRAND+CATEGORY - Commission Value', 'ADGROUP - Commission Value', 'KEYWORD - Commission Value'].each do |key|
      hash[key] = (@cancellation_factor * @saleamount_factor * hash[key][0].from_german_to_f).to_german_s
    end
    hash
  end

  def combine_hashes(list_of_rows)
    keys = []
    list_of_rows.each do |row|
      next if row.nil?
      row.headers.each do |key|
        keys << key
      end
    end
    result = {}
    keys.each do |key|
      result[key] = []
      list_of_rows.each do |row|
        result[key] << (row.nil? ? nil : row[key])
      end
    end
    result
  end
end

input = FileGetter.latest('project_2012-07-27_2012-10-10_performancedata')
modification_factor = 1
cancellaction_factor = 0.4
modifier = Modifier.new(modification_factor, cancellaction_factor)
modifier.modify(input)

puts "DONE modifying"
