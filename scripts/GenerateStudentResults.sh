#!/bin/bash

#Remove previous files from other runs. Clearn Final Results if already created. 
if [ -f FinalResults ] ; then
    rm FinalResults

fi

touch FinalResults
touch test.txt

#Loop through n number of files
for file in `ls ../data/Form?.csv`
do
	letter=`echo $file | sed  's/..\/data\/Form//' | sed 's/.csv//'` #Extract only the letter from $file

	#Create data sets
	grep "KEY" $file > answer_key.csv; 
	grep -v 'KEY' $file > student_answers.csv
	sed '1d' ../data/Domains_Form$letter.csv | cut -d, -f1,2 --complement > domains.csv
	#sed '1d' ../data/Domains_Form$letter.csv | cut -d, -f1,4 --complement | sort | uniq > ListOfDomains.csv
	
	#Run R scripts
	Rscript ConvertLetToBinary.R student_answers.csv answer_key.csv ResultsNum.R
	Rscript ConvertWidetoLongFormat.R ResultsNum.R student_results.R
	
	#Data Cleaning the result data set
	sed -i 's/\"//g' student_results.R
	sed -i 's/\,/ /g' domains.csv
	dos2unix -q domains.csv #Convert dos file to unix format 
	awk -f NumSort.awk student_results.R > student_results
	cat student_results >> test.txt 
	awk -f NumSortDomains.awk domains.csv > domains
	
	#Merge domains and student results
	join -1 3 -2 2 -o 1.1,1.2,1.3,2.1,1.4 student_results domains  >> FinalResults 

done

#Remove files that are not needed
rm student_answers.csv 
rm answer_key.csv 
rm domains.csv 
rm domains 
rm student_results 
rm ResultsNum.R 
rm student_results.R
