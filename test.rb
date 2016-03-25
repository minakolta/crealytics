require File.expand_path('lib/combiner',File.dirname(__FILE__))
require 'smarter_csv'
require 'date'

@modification_factor = 1
@cancellaction_factor = 0.4

def latest(name)
  files = Dir["#{ ENV["HOME"] }/workspace/*#{name}*.txt"]

  files.sort_by! do |file|
    last_date = /\d+-\d+-\d+_[[:alpha:]]+\.txt$/.match file
    last_date = last_date.to_s.match /\d+-\d+-\d+/

    date = DateTime.parse(last_date.to_s)
    date
  end

  throw RuntimeError if files.empty?

  files.last
end
def combine(merged)
	result = []
	merged.each do |_, hash|
		result << combine_values(hash)
	end
	result
end
# Combine hashes
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
# Combine values
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
def lazy_read(file)
	Enumerator.new do |yielder|
		CSV.foreach(file) do |row|
			yielder.yield(row)
		end
	end
end	
def sort(file)
	output = "#{file}.sorted"
	content_as_table = CSV.read(file,{ :col_sep => ",", :headers => :first_row })
	headers = content_as_table.headers
	index_of_key = headers.index('Clicks')
	content = content_as_table.sort_by { |a| -a[index_of_key].to_i }
	write(content, headers, output)
	return output
end
def write(content, headers, output)
	Thread.new do
		CSV.open(output, "wb", { :col_sep => ",", :headers => :first_row, :row_sep => "\r\n" }) do |csv|
			csv << headers
			content.each do |row|
				csv << row
			end
		end
	end.join
end

KEYWORD_UNIQUE_ID = 'Keyword Unique ID'

input = latest('project_2012-07-27_2012-10-10_performancedata')
input = sort(input)
input_enumerator = lazy_read(input)
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

start = Time.now
while true
	begin
		merger.next
	rescue StopIteration
		break
	end
end
ends = Time.now
p "Iteration on merger time : #{(ends - start) * 1000} ms"
# smart = SmarterCSV.process(input, {chunk_size: 90})

