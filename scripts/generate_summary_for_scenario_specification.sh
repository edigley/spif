#!/bin/bash

scenarioFile=${1} 
outputFile=${2}

tempFile=`mktemp`

today=$(date +'%Y-%m-%d')

echo "# date=${today}" > ${tempFile}
echo "scenarioFile=${scenarioFile}" >> ${tempFile}

#egrep -w "(landscapeFile|ignitionFile|perimeterResolution|distanceResolution|StartMonth|StartDay|StartHour|StartMin|EndMonth|EndDay|EndHour|EndMin)" ${scenarioFile} | tr -s " " | tr -d " " | paste -sd ";" - > ${tempFile}
egrep -w "(landscapeFile|ignitionFile|perimeterResolution|distanceResolution)" ${scenarioFile} | tr -s " " | tr -d " " >> ${tempFile}

StartMonth=$(grep -w StartMonth ${scenarioFile} | awk '{print $3}')
StartDay=$(grep -w StartDay ${scenarioFile} | awk '{print $3}')
StartHour=$(grep -w StartHour ${scenarioFile} | awk '{print $3}' | cut -c1,2)
StartMin=$(grep -w StartMin ${scenarioFile} | awk '{print $3}')
EndMonth=$(grep -w EndMonth ${scenarioFile} | awk '{print $3}')
EndDay=$(grep -w EndDay ${scenarioFile} | awk '{print $3}')
EndHour=$(grep -w EndHour ${scenarioFile} | awk '{print $3}' | cut -c1,2)
EndMin=$(grep -w EndMin ${scenarioFile} | awk '{print $3}')

startDate=$(printf "2019-%02d-%02d %02d:%02d:00" ${StartMonth} ${StartDay} ${StartHour} ${StartMin})
endDate=$(printf "2019-%02d-%02d %02d:%02d:00" ${EndMonth} ${EndDay} ${EndHour} ${EndMin})

hoursOfSimulation=$(($(($(date -d "${endDate}" "+%s") - $(date -d "${startDate}" "+%s"))) / 3600))

echo "StartDate=${startDate=}" >> ${tempFile}
echo "EndDate=${endDate=}" >> ${tempFile}
echo "hoursOfSimulation=${hoursOfSimulation=}" >> ${tempFile}

cat ${tempFile} | paste -sd ";" > ${outputFile}

exit 0;
