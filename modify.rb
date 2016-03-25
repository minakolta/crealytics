require File.expand_path('lib/combiner',File.dirname(__FILE__))
require File.expand_path('lib/modifier',File.dirname(__FILE__))


modified = input = latest('project_2012-07-27_2012-10-10_performancedata')
modification_factor = 1
cancellaction_factor = 0.4
modifier = Modifier.new(modification_factor, cancellaction_factor)
modifier.modify(modified, input)

puts "DONE modifying"
	