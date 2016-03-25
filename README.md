# Crealytics refactoring #

> After a quick review I got to understand what those modifier and combiner are doing : 

* First the modifier script runs to match  [*]dummy_project_2012-07-27_2012-10-10_performancedata[*].txt files
* Get latest file using the matched date for modification output
* Setting some factors later for data modifications using Modifier initialiser
* Then modify(output, input) is called, data is sorted descending using the Clicks column, and output is saved to file(s) according to it's size if the rows count exceeded 120,000 line it's new file with _(index).txt is created with headers too.

Refactored code does the same, tried to optmise it a bit, I’ve created a CSV file using constant defined for testing, modifications are in the commits

