#!/bin/bash
#PBS -N testOF
#PBS -q gpu
#PBS -k eo
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=48:mpiprocs=48
#PBS -exclusive
cd $PBS_O_WORKDIR
echo 'PBS work dir is' $PBS_O_WORKDIR
module load openfoam/v2006/GccOpt
version=v2006
echo "module loaded are the following"
module li
env > env.log.$PBS_JOBID
#solver=rhoEnergyFoamOR
solver=test.sh

cat <<EOF > test.sh
#!/bin/bash
module load openfoam/v2006/GccOpt
rhoEnergyFoamOR -parallel
EOF
chmod a+x test.sh
jobid=`echo $PBS_JOBID | sed 's/[.].*//'`
echo "joid is" $jobid
echo "PBS_JOBID is" $PBS_JOBID
echo "Running on " `hostname`
echo Available resource are `cat $PBS_NODEFILE`
echo "Job started at `date` on nodes: `cat $PBS_NODEFILE` "
echo "PBS_TASKNUM is" $PBS_TASKNUM
export NCPUS=`wc -l < $PBS_NODEFILE`
uniq $PBS_NODEFILE >> host_list.$PBS_JOBID.txt
#echo "np is" $np
echo "number of  CPUS is" $NCPUS
#mpirun --use-hwthread-cpus -np $NCPUS $solver -parallel > output.$version.$PBS_JOBID
#mpirun -bind-to none -np $NCPUS --map-by ppr:48:node --hostfile myhosts $solver -parallel > output.$version.$PBS_JOBID


##mpirun -bind-to none -np $NCPUS --map-by ppr:48:node --hostfile host_list.$PBS_JOBID.txt $solver > output.$version.$PBS_JOBID
#very slow versus Intel 3 sec.  
#[spissoi@dvlogin02 cavity_test]$ tail output.v2112.904989.davinci-mgt01
#smoothSolver:  Solving for Uy, Initial residual = 5.53805e-07, Final residual = 5.53805e-07, No Iterations 0
#DICPCG:  Solving for p, Initial residual = 9.30485e-07, Final residual = 9.30485e-07, No Iterations 0
#time step continuity errors : sum local = 9.88875e-09, global = -1.95016e-18, cumulative = -2.74029e-16
#DICPCG:  Solving for p, Initial residual = 1.05055e-06, Final residual = 9.04248e-07, No Iterations 3
#time step continuity errors : sum local = 9.4184e-09, global = -1.37171e-18, cumulative = -2.75401e-16
#ExecutionTime = 89.36 s  ClockTime = 90 s


mpirun -np $NCPUS --map-by ppr:48:node --report-bindings --hostfile host_list.$PBS_JOBID.txt $solver > output.$version.$PBS_JOBID

#mpirun -np $NCPUS $solver -parallel > output.$version.$PBS_JOBID
#mpirun -genv MPI_PIN_PROCESSOR_LIST=all:map=bunch  -np $NCPUS $solver -parallel > output.$PBS_JOBID
echo "$PBS_JOBNAME.$e$PBS_JOBID is" $PBS_JOBNAME.$e$PBS_JOBID
cp $HOME/$PBS_JOBNAME.e$jobid $PBS_O_WORKDIR
cp $HOME/$PBS_JOBNAME.o$jobid $PBS_O_WORKDIR

