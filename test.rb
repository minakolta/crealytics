require File.expand_path('lib/combiner',File.dirname(__FILE__))
require 'smarter_csv'
require 'date'
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
def lazy_read(file)
	Enumerator.new do |yielder|
		CSV.foreach(file) do |row|
			yielder.yield(row)
		end
	end
end	
KEYWORD_UNIQUE_ID = 'Keyword Unique ID'

combiner = Combiner.new do |value|
	value[KEYWORD_UNIQUE_ID]
end

input = latest('project_2012-07-27_2012-10-10_performancedata')

puts combiner.combine(lazy_read(input))
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

# smart = SmarterCSV.process(input, {chunk_size: 90})

