#! /bin/bash

if [ $# -ne 1 ];
then
 echo "one argument expected.";
 exit -1;
fi

filename="$1"

if [ -e "$filename" ]
then
  echo $filename
else
  echo "file $filename not found";
  exit -1;
fi

cnt=`wc -l $filename` 
echo "The number of row is $cnt"
cat $filename | while read myline
do
   echo ${myline}
   `ruby selector.rb ${myline} `
done

echo "Well done."

exit 0;
