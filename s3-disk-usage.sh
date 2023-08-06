#!/bin/sh 

#aws s3 ls s3://BUCKETNAME/ | \
#grep -v -E "(Bucket: |Prefix: |LastWriteTime|^$|--)" | \
#awk 'BEGIN {total=0}{total+=$3}END{print total/1024/1024" MB"}'
# Before AWS had a way to tell you how much disk space was being used on the console
ARRAY=()
SUM=0
printf "account number, usage in MB"
for i in `aws s3 ls s3://BUCKETNAME | sed 's/PRE//' | sed 's/.$//'| grep -v -E "(Bucket: |Prefix: |LastWriteTime|^$|--|sampleData|Samples)"`; do
  DU=`aws s3 ls --recursive s3://BUCKETNAME/$i | awk 'BEGIN {total=0}{total+=$3}END{print total/1024/1024}'`
  SUM=$(echo "$SUM + $DU" | bc)
  printf "$i,$DU\n"
done
#TOTAL=`aws s3 ls s3://BUCKETNAME | sed 's/PRE//' | sed 's/.$//'| grep -v -E "(Bucket: |Prefix: |LastWriteTime|^$|--|sampleData|Samples)" | awk 'BEGIN {total=0}{total+=$3}END{print total/1024/1024" MB"}'`
#printf "$TOTAL"
