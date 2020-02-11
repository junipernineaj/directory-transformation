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

DATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
MESSAGE=$1
echo $DATETIMESTAMP - "$MESSAGE" | tee -a $LOGFILE
}

debugging () {

DATETIMESTAMP=`date "+%Y%m%d-%H%M%S"`
MESSAGE=$1

if [ $DEBUG == "On" ]
then
	echo $DATETIMESTAMP - "$MESSAGE" | tee -a $LOGFILE
else
	echo $DATETIMESTAMP - "$MESSAGE" >> $LOGFILE
fi
}


cleanUpXMLdir () {

debugging "START cleanUp function"

	if 
	find -- "$XMLDIRECTORY" -prune -type d -empty | grep -q .
	then
	debugging "Original directory: $XMLDIRECTORY: is empty - deleting"
	rm -rf $XMLDIRECTORY
	else
	logging "Original directory: $XMLDIRECTORY: is not empty - this will need attention"
	fi 
}

moveanyXMLs () {

debugging "moveanyXMLs function"

debugging "Bottom Path is: $BOTTOMDIRECTORY"
debugging "New Company directory is: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"


## If there are XML folders under the BOTTOMDIRECTORY, create the NewCompany Folder and move the XMLs into it

ls "$BOTTOMDIRECTORY" | grep 20[0-2][0-9]-[0-9][0-9] &>/dev/null

	if [ $? -eq 0 ]
 	then

	for XMLDIRECTORY in `ls -d $BOTTOMDIRECTORY/* | grep 20[0-2][0-9]-[0-9][0-9]`
	do
		debugging "XMLDIRECTORY is: $XMLDIRECTORY"
		debugging "Moving XMLs from: $XMLDIRECTORY to: $DATASET/$NEWCOUNTRY/$NEWCOMPANY/"

		find "$XMLDIRECTORY" -type f -name "*xml" -print0 | xargs -0 -I {} mv {} "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"/ 

		cleanUpXMLdir
	done

	else
		debugging "There are no XMLs to process"

	fi
}

find_subsubsubcompany () {

##Look for any SubSubSubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY/" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubSubSubCompany(s) found under $SUBSUBCOMPANY"

## Create an array of SubSubSubCompanies
## And iterate through the SubSubSubCompanies within each Company

	SUBSUBSUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY"/"$SUBCOMPANY"/$SUBSUBCOMPANY | grep -v 20[0-9][0-9]-[0-9][0-9] 2>/dev/null`

	for SUBSUBSUBCOMPANY in `echo "$SUBSUBSUBCOMPANIES"`
	do
		FULLSUBSUBSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY/$SUBSUBSUBCOMPANY"
		SUBSUBSUBCOMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY/$SUBSUBSUBCOMPANY"/20[0-2][0-9]-[0-9]0-9]/ -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubSubSubCompany is: $SUBSUBSUBCOMPANY"
		debugging "Full SubSubSubCompany Path is now: $FULLSUBSUBSUBCOMPANYPATH"
		logging "XML count for SubSubSubCompany: $SUBSUBSUBCOMPANY  is: $SUBSUBSUBCOMPANYXMLCOUNT"

	NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}_${SUBSUBCOMPANY}/${SUBSUBSUBCOMPANY}"
	debugging "NewCompany is: $NEWCOMPANY"
	mkdir "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	BOTTOMDIRECTORY="${FULLSUBSUBSUBCOMPANYPATH}"
	moveanyXMLs

	done

else
	debugging "No SubSubCompany(s) found under $SUBCOMPANY"
	NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}_${SUBSUBCOMPANY}"
	debugging "I would create Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	mkdir "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	BOTTOMDIRECTORY="${FULLSUBSUBCOMPANYPATH}"
	moveanyXMLs
fi

##End of --find_subsubsubcompany--
}

find_subsubcompany () {

##Look for any SubSubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubSubCompany(s) found under $SUBCOMPANY"

## Create an array of SubSubCompanies
## And iterate through the SubSubCompanies within each Company

	SUBSUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY"/"$SUBCOMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9] 2>/dev/null`

	for SUBSUBCOMPANY in `echo "$SUBSUBCOMPANIES"`
	do
		FULLSUBSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY"
		SUBSUBCOMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY/$SUBSUBCOMPANY"/20[0-2][0-9]-[0-9][0-9] -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubSubCompany is: $SUBSUBCOMPANY"
		debugging "Full SubSubCompany Path is now: $FULLSUBSUBCOMPANYPATH"
		logging "XML count for SubSubCompany: $SUBSUBCOMPANY  is: $SUBSUBCOMPANYXMLCOUNT"

	find_subsubsubcompany

	done

else
	debugging "No SubSubCompany(s) found under $SUBCOMPANY"
	NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}"
	debugging "I would create Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	mkdir "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	BOTTOMDIRECTORY="${FULLSUBCOMPANYPATH}"
	moveanyXMLs
fi

##End of --find_subsubcompany--
}


find_subcompany () {

##Look for any SubCompanies in a dataset

ls "$DATASET/$COUNTRY/$COMPANY/" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "SubCompany(s) found under $COMPANY"

## Create an array of SubCompanies
## And iterate through the SubCompanies within each Company

	SUBCOMPANIES=`ls $DATASET/"$COUNTRY"/"$COMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9] 2>/dev/null`

	for SUBCOMPANY in `echo "$SUBCOMPANIES"`
	do
		FULLSUBCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY/$SUBCOMPANY"

		SUBCOMPANYXMLCOUNT=`find "$FULLSUBCOMPANYPATH"/20[0-2][0-9]-[0-9][0-9] -type f -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "SubCompany is: $SUBCOMPANY"
		debugging "Full SubCompany Path is now: $FULLSUBCOMPANYPATH"
		logging "XML count for SubCompany: $SUBCOMPANY  is: $SUBCOMPANYXMLCOUNT"

	find_subsubcompany

	done

else	
	debugging "No SubCompany(s) found under $COMPANY"
	NEWCOMPANY="partition_company=${COMPANY}"
	debugging "I would create Company Directory: $DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	mkdir "$DATASET/$NEWCOUNTRY/$NEWCOMPANY"
	BOTTOMDIRECTORY="${FULLCOMPANYPATH}"
	moveanyXMLs
fi

##End of --find_subcompany--
}



find_company () {

##Look for any Companies in a dataset

debugging "START - find_company function"

ls "$DATASET/$COUNTRY/" | grep -v 20[0-9][0-9]-[0-9][0-9] &>/dev/null

if [ $? -eq 0 ]
then
	debugging "First Level Company(s) found under $COUNTRY"

## Create an array of Companies
## And iterate through the Companies within each Country

	COMPANIES=`ls $DATASET/"$COUNTRY" | grep -v 20[0-9][0-9]-[0-9][0-9] 2>/dev/null`

	for COMPANY in `echo "$COMPANIES"`
	do
		FULLCOMPANYPATH="$DATASET/$COUNTRY/$COMPANY"
		COMPANYXMLCOUNT=`find "$DATASET/$COUNTRY/$COMPANY"/20[0-2][0-9]-[0-9][0-9] -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

		debugging "Company is: $COMPANY"
		debugging "Full Company Path is: $FULLCOMPANYPATH"
		logging "XML count for Company: $COMPANY  is: $COMPANYXMLCOUNT"

		if [ $COMPANYXMLCOUNT -gt 0 ]
		then
			if [ ! -d "$DATASET/partition_country=$COUNTRY/partition_company=$COMPANY" ]
			then
			NEWCOMPANY="partition_company=$COMPANY"
			mkdir "$DATASET/partition_country=$COUNTRY/$NEWCOMPANY"
			BOTTOMDIRECTORY="${FULLCOMPANYPATH}"
			moveanyXMLs
			fi
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
