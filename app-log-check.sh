#!/bin/bash
@ Linux script to check application status using adb

if [ "$#" -ne 1 ]; then echo "Illegal number of parameters"; exit 1; fi
echo "Lof for package name: $1"
PROCESSES=`adb shell ps | grep "$1" | cut -c10-15`
NUM_OF_PROCESSES=`echo "$PROCESSES" | wc -l`
if [ $NUM_OF_PROCESSES -eq 0 ]; then echo "The application is not running!"; exit 1; fi
COUNTER=1
for process in $PROCESSES; do
        if [ $COUNTER -eq 1 ]; then GREP_TEXT="("; fi
        GREP_TEXT+=$process
        if [ $COUNTER -eq $NUM_OF_PROCESSES ]; then GREP_TEXT+=")"; else GREP_TEXT+="|"; fi
        let COUNTER=COUNTER+1 
        if [ $COUNTER -gt $NUM_OF_PROCESSES ]; then break; fi  
done
adb logcat | grep -E "$GREP_TEXT"
