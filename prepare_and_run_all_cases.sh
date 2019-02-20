#!/bin/bash

for scenario in `seq 1 10`; do
        rm -rf /home/edigley/doutorado_uab/git/spif/test
        cd /home/edigley/doutorado_uab/git/spif/
        mkdir -p test/input
        mkdir test/input test/output test/trace
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/landscape/  test/
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/perimetres/ test/
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/qgis/case_${scenario}_central_point* test/perimetres/
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/aux_files/  test/
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/bases/      test/
        ln -s ~/doutorado_uab/git/fire-scenarios/case_${scenario}/scripts/    test/
        cp ~/doutorado_uab/git/fire-scenarios/case_${scenario}/scenario_template_for_histogram.ini test/scenario_case_${scenario}.ini
        cp ~/doutorado_uab/git/fire-scenarios/case_${scenario}/input/pob_0.txt test/input/
        cd test
        cp ../farsite_individuals.txt .
        #/home/edigley/doutorado_uab/git/spif/fireSimulator scenario_case_${scenario}.ini farsite_individuals.txt run 1
        for i in `seq 1 1000`; do time /home/edigley/doutorado_uab/git/spif/fireSimulator scenario_case_${scenario}.ini farsite_individuals.txt run $i; done
        cd /home/edigley/doutorado_uab/git/spif/
        mv test test_case_${scenario}
done

exit 0;
