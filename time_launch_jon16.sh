#!/bin/bash -x
#SBATCH --partition=p_hpca4se
SBATCH -x robin,huberman,penguin,sandman
#SBATCH -J SPIF
#SBATCH -N 1
###SBATCH -n 9
#SBATCH --time=1200 
#SBATCH --error=SPIF_%J.out 
#SBATCH --output=SPIF_%J.out
#SBATCH --mem-per-cpu=1500
#SBATCH --exclusive
#SBATCH --mail-user=carrillojordan@gmail.com

##export I_MPI_PMI_LIBRARY=/opt/openmpi-1.6.5/lib/libpmi.so
MPIARGS="-n 9 --report-bindings --display-allocation --report-bindings"
##MPIARGS2=""
ulimit -s unlimited
cat $PE_HOSTFILE
echo "--------------------------"
# Module load section
#export I_MPI_PROCESS_MANAGER=mpd
##export I_MPI_PMI_LIBRARY=/opt/openmpi-1.6.4/lib/libpmi.so
source  /opt/Modules/3.2.9/init/Modules4bash.sh
module rm openmpi-x86_64
module load openmpi/1.6.5 
module load windninja/2.1.1
module load geos/3.3.8 proj/4.8.0 netcdf/4.3.0 gdal/1.9.2 
module load windninja/2.1.1
module list
##likwid-topology
#module load boost/1.49.0 windninja/2.1.1 likwid/3.0.0
#module load OpenMPI-1.5.3-x86_64 boost/1.49.0 windninja/2.1.1
##export OMP_NUM_THREADS=8
export CLASSPATH="/home/tartes/Soft/Weka/weka-3-6-10/weka.jar:/scratch/078-hpca4se-comp/tomas/SPIF/Andres/:$CLASSPATH"
echo "--------------------------"
## Compilacio carregant NOMES openmpi, no gcc.
mkdir $SLURM_JOB_ID
cd $SLURM_JOB_ID
mkdir Traces
mkdir Shapes
mkdir TOA
cd .. 
##module load likwid/3.0.0
##hwloc-ps -a &>  ${SLURM_JOB_ID}/Noise_${SLURM_JOB_ID}.txt
##likwid-topology > ${SLURM_JOB_ID}/Noise_${SLURM_JOB_ID}.txt
#likwid-topology -o ${SLURM_JOB_ID}/Noise_${SLURM_JOB_ID}.txt
#lstopo --whole-system -p  $SLURM_JOB_ID/Resources_physical_$SLURM_JOB_ID.pdf
#lstopo --whole-system -l  $SLURM_JOB_ID/Resources_logical_$SLURM_JOB_ID.pdf
##likwid-topology -g -o $SLURM_JOB_ID/Resources_likwidtopo_$SLURM_JOB_ID.txt
#make clean
#make normal
cd /home/ccarrillo/FRAMEWORK/Fases2/FarsiteSIM/ORIGINAL/core
make clean
make normal
cd /home/ccarrillo/genetic/proba5/SPIF
make clean
make normal 
#rm /scratch/078-hpca4se-comp/tomas/SPIF/Trace/*
#export SLURM_HOSTFILE=hostfile
#nodes=`cat nodefile`
#echo $nodes
#export SLURM_NODELIST=$nodes
 
#echo mpirun -np $NSLOTS /home/cbrun/SPIF/genetic /home/cbrun/SPIF/Jonquera/pob0/datos_WF.ini 

#./cleanpob0.sh

#/home/tartes/Fases2/FarsiteSIM/ORIGINAL/core/farsite4P -i /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/output/settings_9_4.txt -l 300 -f 8 -t 1 -g 9 -n 4 -w 2

#s#run -n 8 --ntasks-per-socket=2  mpirun -np 8 /scratch/078-hpca4se-comp/tomas/SPIF/genetic $SLURM_JOB_ID /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/datos.ini 
##export MPI_REQUEST_MAX=100
#srun -c 128 -x huberman,robin --mpi=openmpi mpirun ${MPIARGS} /scratch/078-hpca4se-comp/tomas/SPIF/genetic $SLURM_JOB_ID /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/datos.ini
#cat pobsClass/pob_D.txt | sed -e 's/,/ /g' > pobsClass/temp.txt
#cat pobsClass/temp.txt > pobsClass/pob_D.txt

#cd Trace
#mkdir $SLURM_JOB_ID
#cd ..

##cat Jonquera/pob0/datos$2.ini | sed -e "s|TracePathFiles              =  /scratch/078-hpca4se-comp/tomas/SPIF/Trace/|TracePathFiles              =  /scratch/078-hpca4se-comp/tomas/SPIF/Trace/$SLURM_JOB_ID/|g" > /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/$SLURM_JOB_ID.ini
###ulimit -c unlimited
echo "mpirun ${MPIARGS} /home/ccarrillo/genetic/proba5/SPIF $SLURM_JOB_ID $1"
mpirun ${MPIARGS} /home/ccarrillo/genetic/proba5/SPIF/genetic $SLURM_JOB_ID $1
##srun -n 9 /scratch/078-hpca4se-comp/tomas/SPIF/genetic $SLURM_JOB_ID /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/$SLURM_JOB_ID.ini

##sleep 15
##pids=`cat SPIF_$SLURM_JOB_ID.out | grep "MiPID" | cut -d':' -f2`
##for genera in $pids
##do
##gcore -o core.$pids $genera
##done



InError=`grep "GenAlErroPath" $1 | cut -d'=' -f2 | tr -d " \t\n\r"`

gnuplot -e "filename='$2/Error_$SLURM_JOB_ID.ps'" -e "inputFile='${InError}GenAlError_$SLURM_JOB_ID.dat'" -e "JobID='JOB_$SLURM_JOB_ID'" Utils/gnuExample.gnu

###echo "/home/tartes/Soft/openmpi/bin/mpirun ${MPIARGS} /scratch/078-hpca4se-comp/tomas/SPIF/genetic $SLURM_JOB_ID /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/datos.ini" > temp.txt
##echo srun -n 26 /home/cbrun/SPIF/genetic /home/cbrun/SPIF/Jonquera/pob0/datos_WF.ini 
##srun -n 26 /home/cbrun/SPIF/genetic /home/cbrun/SPIF/Jonquera/pob0/datos_WF.ini 

##cp /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/$SLURM_JOB_ID.ini $SLURM_JOB_ID/
##cp /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/input/pob_* $SLURM_JOB_ID/
##mv genetic.clog2 $SLURM_JOB_ID/$SLURM_JOB_ID.clog2
##mv genetic.otf $SLURM_JOB_ID/$SLURM_JOB_ID.otf
## mv GenAlError_$SLURM_JOB_ID.dat $SLURM_JOB_ID/
cp $1 $2/
cp SPIF_$SLURM_JOB_ID.* $2
cat $2/Trace/*.dat | sort -n -k4 > $2/Trace.txt
cp $InError/GenAlError_$SLURM_JOB_ID.dat $2
##mv /scratch/078-hpca4se-comp/tomas/SPIF/Trace/$SLURM_JOB_ID/* $SLURM_JOB_ID/Traces
#./PlotTrace.sh Trace.txt $SLURM_JOB_ID/$SLURM_JOB_ID
##mv /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/output/shape_* $SLURM_JOB_ID/Shapes
#mv /scratch/078-hpca4se-comp/tomas/SPIF/Jonquera/pob0/output/raster_* $SLURM_JOB_ID/TOA
tar -czf Summary_$SLURM_JOB_ID.tar.gz $2 
#rm -r $SLURM_JOB_ID
killall -u ccarrillo
exit 0
