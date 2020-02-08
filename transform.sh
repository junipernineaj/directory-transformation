#!/bin/bash
OIFS="$IFS"
IFS=$'\n'

LOGDATETIMESTAMP=`date "+%Y%m%d%H%M%S"`
LOGFILE=./$LOGDATETIMESTAMP-logfile.txt

if [ $2 == "On" ]
then
DEBUG=On
else
DEBUG=Off
fi 

##

echo "Dataset is:" "$1" | tee -a $LOGFILE
echo "----------------" | tee -a $LOGFILE

##Count the total number of XMLs in the dataset before transforming it

PROCESSEDXMLCOUNTER=`expr 0 + 0`
DATASETXMLCOUNT=`find $1 -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`

echo "XMLs in $1 dataset: $DATASETXMLCOUNT" | tee -a $LOGFILE
echo "--------------------------------" | tee -a $LOGFILE



##Iterate through the Countries in a dataset

for COUNTRY in `ls $1`
do

COUNTRYXMLCOUNT=`find "$1/$COUNTRY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
FULLCOUNTRYPATH="$1/$COUNTRY"

	if [ $COUNTRYXMLCOUNT -gt 0 ]
	then
  	echo "XML count for Country: $COUNTRY is:" "$COUNTRYXMLCOUNT" | tee -a $LOGFILE
	echo "Full Country Path is: $FULLCOUNTRYPATH"

	 	if [ ! -d "$1/partition_country=$COUNTRY" ]
		then
		NEWCOUNTRY="partition_country=$COUNTRY"

		if [ $DEBUG == "On" ]
		then
		echo Creating new Country Directory: "$NEWCOUNTRY" | tee -a $LOGFILE
		fi

		mkdir "$1/$NEWCOUNTRY"
		fi
	else

	echo "Country: $COUNTRY has no XMLs - deleting it" | tee -a $LOGFILE		
	rm -rf $FULLCOUNTRYPATH
	
	fi

if [ $DEBUG == "On" ]
then
echo "Country is:" "$COUNTRY" | tee -a $LOGFILE
fi

COMPANIES=`ls $1/"$COUNTRY" 2>/dev/null`

##Iterate through the Companies within each Country

	for COMPANY in `echo "$COMPANIES"`
	do

	if [ $DEBUG == "On" ]
	then
	FULLCOMPANYPATH="$1/$COUNTRY/$COMPANY"
 	COMPANYXMLCOUNT=`find "$1/$COUNTRY/$COMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
	echo "Company is:" "$COMPANY" | tee -a $LOGFILE
	echo "Full Company Path is:" "$FULLCOMPANYPATH" | tee -a $LOGFILE
	echo "XML count for Company: $COMPANY  is:" "$COMPANYXMLCOUNT" | tee -a $LOGFILE
	fi

	SUBCOMPANIES=`ls $1/"$COUNTRY"/"$COMPANY" | grep -v 20[0-9][0-9]-[0-9][0-9]`

##Iterate through the Sub-Companies within each Country/Company combination

		for SUBCOMPANY in `echo "$SUBCOMPANIES"`
		do

		if [ $DEBUG == "On" ]
		then
		echo "Sub-Company is:" "$SUBCOMPANY" | tee -a $LOGFILE
 	 	SUBCOMPANYXMLCOUNT=`find "$1/$COUNTRY/$COMPANY/$SUBCOMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
		echo "XML count for Sub-Company: $SUBCOMPANY is:" "$SUBCOMPANYXMLCOUNT" | tee -a $LOGFILE
		fi


		if [ ! -d "$1/partition_country=$COUNTRY/partition_company=${COMPANY}_${SUBCOMPANY}" ]
		then

		NEWCOMPANY="partition_company=${COMPANY}_${SUBCOMPANY}"

			if [ $DEBUG == "On" ]
			then
			echo Creating new hybrid Company Directory: "$NEWCOMPANY" | tee -a $LOGFILE
			echo New hybrid Full Directory: "$1/$NEWCOUNTRY/$NEWCOMPANY" | tee -a $LOGFILE
			fi

		mkdir "$1/$NEWCOUNTRY/$NEWCOMPANY"
		fi

##Report the full path of Country, Company and Sub-Company

		FULLDIRECTORYPATH="$1/$COUNTRY/$COMPANY/$SUBCOMPANY"

			if [ $DEBUG == "On" ]
			then
			echo "Full Directory path is: $FULLDIRECTORYPATH" | tee -a $LOGFILE
			fi

##List the contents of the Full directory path

			if [ $DEBUG == "On" ]
			then
			echo "Iterating through the directory contents"
			ls -d $FULLDIRECTORYPATH/* 2>/dev/null

				if [ $? -ne 0 ]
				then
				echo "There are no Directories below $FULLDIRECTORYPATH/" | tee -a $LOGFILE
				fi
			fi

			for DIRECTORY in `ls -d $FULLDIRECTORYPATH/* 2>/dev/null`
			do
				if [ $DEBUG == "On" ]
				then
				echo Directory of XMLs is: "$DIRECTORY" | tee -a $LOGFILE
				XMLCOUNT=`ls $DIRECTORY | wc -l | sed s/" "//g`
				echo "Number of XML files in the $DIRECTORY are: $XMLCOUNT" | tee -a $LOGFILE
				echo "." | tee -a $LOGFILE
				fi

## Now we will move the XMLs to the correct directory structure for upload to the Staging Environment

				for XML in `ls $DIRECTORY/*xml`
				do

				FULLDIRECTORYPATH="$1/$COUNTRY/$COMPANY/$SUBCOMPANY"
				NEWDIRECTORYPATH="$1/$NEWCOUNTRY/$NEWCOMPANY"

				PROCESSEDXMLCOUNTER=`expr $PROCESSEDXMLCOUNTER + 1`

					if [ $DEBUG == "On" ]
					then
					echo Moving XML \("$PROCESSEDXMLCOUNTER" of "$DATASETXMLCOUNT"\): "$XML" to "$NEWDIRECTORYPATH" | tee -a $LOGFILE
					fi

				mv -n "$XML" "$NEWDIRECTORYPATH"				
				done
			done
		done

  	if [ $DEBUG == "On" ]
	then
 	NEWCOMPANYXMLCOUNT=`find "$1/$NEWCOUNTRY/$NEWCOMPANY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
	echo "XML count for newly structured company: $NEWCOMPANY  is:" "$NEWCOMPANYXMLCOUNT" | tee -a $LOGFILE
	fi

	done

NEWCOUNTRYXMLCOUNT=`find "$1/$NEWCOUNTRY" -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
echo "XML count for newly structured country: $NEWCOUNTRY  is:" "$NEWCOUNTRYXMLCOUNT" | tee -a $LOGFILE

done

NEWDATASETXMLCOUNT=`find $1 -name "*.xml" -print0 | xargs -0 ls | wc -l | sed s/" "//g`
echo "XMLs in reformatted dataset: $NEWDATASETXMLCOUNT" | tee -a $LOGFILE
echo "--------------------------------" | tee -a $LOGFILE

DELTA=`expr $DATASETXMLCOUNT - $NEWDATASETXMLCOUNT`

if [ $DELTA -eq 0 ]
then
echo "Dataset restructured - no dataloss"
else
echo "Dataset restructured - DATALOSS"
fi
