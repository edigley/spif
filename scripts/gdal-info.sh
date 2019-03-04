#!/bin/bash
#case=hinckley; ~/git/spif/scripts/gdal-info.sh ${case}/landscape/${case}.lcp
#for case in `seq 1 10`; do echo "----> Landscape File: Case ${case}"; landscapeFile="2019/case_${case}/landscape/CASE_${case}.lcp"; du -sh ${landscapeFile}; ~/doutorado_uab/git/spif/scripts/gdal-info.sh ${landscapeFile}; done

landscapeFile=$1

du -sh ${landscapeFile}

gdalinfo ${landscapeFile} | egrep "(DESCRIPTION|Pixel Size|Size is|LINEAR_UNIT|FUEL_MODEL_NUM_CLASSES|FUEL_MODEL_VALUES)"

xDim=$(gdalinfo ${landscapeFile} | grep "Size is" | sed "s/Size is//g"| awk -F", " '{print $1}')
yDim=$(gdalinfo ${landscapeFile} | grep "Size is" | sed "s/Size is//g"| awk -F", " '{print $2}')

cellResolution=$(gdalinfo ${landscapeFile} | grep "Pixel Size = (" | sed "s/Pixel Size = (//g"| awk -F"," '{print $1}' | sed "s/.000000000000000//g" | sed "s/.793608575419000//g")

xMapSize=$((${xDim}*${cellResolution}))
yMapSize=$((${yDim}*${cellResolution}))

echo "Map Size (meters): ${xMapSize}x${yMapSize}"

exit 0;
