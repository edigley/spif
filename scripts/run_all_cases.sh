#!/bin/bash

for scenario in `seq 1 10`; do
        cd /home/edigley/doutorado_uab/git/spif/test_case_${scenario}
        for i in `seq 3001 4000`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator scenario_case_${scenario}.ini farsite_10000_individuals.txt run $i; done
        rm -rf output/*
        cd /home/edigley/doutorado_uab/git/spif/
done

exit 0;
