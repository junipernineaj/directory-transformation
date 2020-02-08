#!/bin/bash
OIFS="$IFS"
IFS=$'\n'

LOGDATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
LOGFILE=./$LOGDATETIMESTAMP-logfile.txt
DATASET=$1

if [ ! $2 == "Off" ]
then
DEBUG=On
else
DEBUG=Off
fi 



logging () {

MESSAGE=$1
echo $LOGDATETIMESTAMP - "$MESSAGE" | tee -a $LOGFILE
}

debugging () {

MESSAGE=$1

if [ $DEBUG == "On" ]
then
	echo $LOGDATETIMESTAMP - "$MESSAGE" | tee -a $LOGFILE
else
	echo $LOGDATETIMESTAMP - "$MESSAGE" >> $LOGFILE
fi
}

find_subsubsubcompany () {

##Look for any SubSubSubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubSubSubCompany(s) found under $SUBSUBCOMPANY"

## Create an array of SubSubSubCompanies
## And iterate through the SubSubSubCompanies within each Company

	SUBSUBSUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY"/"$SUBCOMPANY"/$SUBSUBCOMPANY 2>/dev/null`

	for SUBSUBSUBCOMPANY in `echo "$SUBSUBSUBCOMPANIES"`
	do
		FULLSUBSUBSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY/$SUBSUBSUBCOMPANY"
		SUBSUBSUBCOMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY"/$SUBSUBSUBCOMPANY -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubSubSubCompany is: $SUBSUBSUBCOMPANY"
		debugging "Full SubSubSubCompany Path is now: $FULLSUBSUBSUBCOMPANYPATH"
		logging "XML count for SubSubSubCompany: $SUBSUBSUBCOMPANY  is: $SUBSUBSUBCOMPANYXMLCOUNT"

	NEWCOMPANY="partition_company=$COMPANY_$SUBCOMPANY_$SUBSUBCOMPANY/$SUBSUBSUBCOMPANY"
	debugging "NewCompany is: $NEWCOMPANY"
	echo "WILL WE EVER GET HERE!!!"
	sleep 10

	done

else
	debugging "No SubSubCompany(s) found under $SUBCOMPANY"
	NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}_${SUBSUBCOMPANY}"
	debugging "Creating new Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
fi

##End of --find_subsubsubcompany--
}

find_subsubcompany () {

##Look for any SubSubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubSubCompany(s) found under $SUBCOMPANY"

## Create an array of SubSubCompanies
## And iterate through the SubSubCompanies within each Company

	SUBSUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY"/"$SUBCOMPANY" 2>/dev/null`

	for SUBSUBCOMPANY in `echo "$SUBSUBCOMPANIES"`
	do
		FULLSUBSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY"
		SUBSUBCOMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubSubCompany is: $SUBSUBCOMPANY"
		debugging "Full SubSubCompany Path is now: $FULLSUBSUBCOMPANYPATH"
		logging "XML count for SubSubCompany: $SUBSUBCOMPANY  is: $SUBSUBCOMPANYXMLCOUNT"

	find_subsubsubcompany

	done

else
	debugging "No SubSubCompany(s) found under $SUBCOMPANY"
	NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}"
	debugging "Creating new Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
fi

##End of --find_subsubcompany--
}


find_subcompany () {

##Look for any SubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubCompany(s) found under $COMPANY"

## Create an array of SubCompanies
## And iterate through the SubCompanies within each Company

	SUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY" 2>/dev/null`

	for SUBCOMPANY in `echo "$SUBCOMPANIES"`
	do
		FULLSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY"
		SUBCOMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubCompany is: $SUBCOMPANY"
		debugging "Full SubCompany Path is now: $FULLSUBCOMPANYPATH"
		logging "XML count for SubCompany: $SUBCOMPANY  is: $SUBCOMPANYXMLCOUNT"

	find_subsubcompany

	done

else	
	debugging "No SubCompany(s) found under $COMPANY"
	NEWCOMPANY="partition_company=${COMPANY}"
	debugging "Creating new Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
fi

##End of --find_subcompany--
}



find_company () {

##Look for any Companies in a dataset

ls "$DATASET/$COUNTRY" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "First Level Company(s) found under $COUNTRY"

## Create an array of Companies
## And iterate through the Companies within each Country

	COMPANIES=`ls $DATASET/"$COUNTRY" 2>/dev/null`

	for COMPANY in `echo "$COMPANIES"`
	do
		FULLCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY"
		COMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "Company is: $COMPANY"
		debugging "Full Company Path is: $FULLCOMPANYPATH"
		debugging "XML count for Company: $COMPANY  is: $COMPANYXMLCOUNT"

	 	if [ ! -d "$DATASET/partition_country=$COUNTRY/partition_company=$COMPANY" ]
		then
		NEWCOMPANY="partition_company=$COMPANY"


		mkdir "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"
		fi

	find_subcompany

	done

else	
	debugging "No Company(s) found under $COUNTRY"
fi

##End of --find_company--
}

find_country () {

##Look for any Countries in a dataset

for COUNTRY in `ls $DATASET`
do
	debugging "Country is: $COUNTRY"

	COUNTRYXMLCOUNT=`find "$DATASET/$COUNTRY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
	FULLCOUNTRYPATH="$DATASET/$COUNTRY"

	if [ $COUNTRYXMLCOUNT -gt 0 ]
	then
  		logging "XML count for Country: $COUNTRY is: $COUNTRYXMLCOUNT"
		debugging "Full Country Path is: $FULLCOUNTRYPATH"

	 	if [ ! -d "$1/partition_country=$COUNTRY" ]
		then
		NEWCOUNTRY="partition_country=$COUNTRY"

		debugging "Creating new Country Directory: $DATASET/$NEWCOUNTRY"

		mkdir "$DATASET/$NEWCOUNTRY"

		find_company
		fi
	else

		logging "Country: $COUNTRY has no XMLs - deleting it"
		rm -rf $FULLCOUNTRYPATH
	fi
done

##End of --find_country--
}

##

logging "Dataset is: $DATASET"
logging "------------------------"

##Count the total number of XMLs in the dataset before transforming it

PROCESSEDXMLCOUNTER=`expr 0 + 0`
DATASETXMLCOUNT=`find $DATASET -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

logging "XMLs in $DATASET dataset: $DATASETXMLCOUNT"
logging "------------------------------------------"


find_country
