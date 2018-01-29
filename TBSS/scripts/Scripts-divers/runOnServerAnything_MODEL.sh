#!/bin/bash
#De Almeida Luis 22/04/2015

VERSION="0.0.0"

# trap keyboard interrupt (control-c)
trap control_c SIGINT

function setPath 
{
    cat <<SETPATH

--------------------------------------------------------------------------------------
Error locating ANTS
--------------------------------------------------------------------------------------
It seems that the ANTSPATH environment variable is not set. Please add the ANTSPATH
variable. This can be achieved by editing the .bash_profile in the home directory.
Add:

ANTSPATH=/home/yourname/bin/ants/

Or the correct location of the ANTS binaries.

Alternatively, edit this script ( `basename $0` ) to set up this parameter correctly.

SETPATH
    exit 1
}

# Uncomment the line below in case you have not set the ANTSPATH variable in your environment.
export ANTSPATH=${ANTSPATH:="/shares/commun/antsbin/bin"} # EDIT THIS

if [[ ${#ANTSPATH} -le 3 ]];
  then
    setPath >&2
  fi

# Test availability of helper scripts.
# No need to test this more than once. Can reside outside of the main loop.
ANTS=${ANTSPATH}/antsRegistration
WARP=${ANTSPATH}/antsApplyTransforms
N4=${ANTSPATH}/N4BiasFieldCorrection
KK=${ANTSPATH}/KellyKapowski
Atropos=${ANTSPATH}/Atropos
PEXEC=${ANTSPATH}/ANTSpexec.sh
SGE=${ANTSPATH}/waitForSGEQJobs.pl
PBS=${ANTSPATH}/waitForPBSQJobs.pl
XGRID=${ANTSPATH}/waitForXGridJobs.pl

fle_error=0
for FLE in $ANTS $WARP $N4 $PEXEC $SGE $XGRID $PBS $KK $Atropos
  do
    if [[ ! -x $FLE ]];
      then
        echo
        echo "-----------------------------------------------------------------------------"
        echo " FILE $FLE DOES NOT EXIST -- OR -- IS NOT EXECUTABLE !!! $0 will terminate."
        echo "-----------------------------------------------------------------------------"
        echo " if the file is not executable, please change its permissions. "
        fle_error=1
      fi
  done

if [[ $fle_error = 1 ]];
  then
    echo "missing helper script"
    exit 1
  fi

function Usage {
    cat <<USAGE

Usage:

`basename $0` -d ImageDimension -o OutputPrefix <other options> <images>

Compulsory arguments (minimal command line requires SGE/PBS cluster, otherwise use -c and
  -j options):

     -d:  ImageDimension: 2 or 3 (for 2 or 3 dimensional registration of single volume)
   ImageDimension: 4 (for template generation of time-series data)

     -o:  OutputPrefix; A prefix that is prepended to all output files.

<images>  List of images in the current directory, eg *_t1.nii.gz. Should be at the end
          of the command.  Optionally, one can specify a .csv or .txt file where each
          line is the location of the input image.  One can also specify more than
          one file for each image for multi-modal template construction (e.g. t1 and t2).
          For the multi-modal case, the templates will be consecutively numbered (e.g.
          ${OutputPrefix}template0.nii.gz, ${OutputPrefix}template1.nii.gz, ...).

NB: All images to be processed should be in the same directory, and this
    script should be invoked from that directory.


GOOD OPTIONS
	#use only -c 1 -- this default is now set 
	-c:  Control for parallel computation (default 1):
          0 = run serially
          1 = SGE qsub
          2 = use PEXEC (localhost)
          3 = Apple XGrid
          4 = PBS qsub

Example:
Note the -o and -r options are unused but must still be put in
./call_antsReg.sh -d 3 -r 1 m*.gz

call(['KellyKapowski -d 3 -t 1 -s [Atro_'+name+',2,1] -o [KK_'+name+',WWM_'+name+'] > output_cortical_thickness'+name+'.txt'],shell=True)


`basename $0` -d 3 -i 3 -k 1 -f 4x2x1 -s 2x1x0vox -q 30x20x4 -t SyN  -m CC -c 0 -o MY sub*avg.nii.gz

--------------------------------------------------------------------------------------
ANTS was created by:
--------------------------------------------------------------------------------------
Brian B. Avants, Nick Tustison and Gang Song
Penn Image Computing And Science Laboratory
University of Pennsylvania

Please reference http://www.ncbi.nlm.nih.gov/pubmed/20851191 when employing this script
in your studies. A reproducible evaluation of ANTs similarity metric performance in
brain image registration:

* Avants BB, Tustison NJ, Song G, Cook PA, Klein A, Gee JC. Neuroimage, 2011.

Also see http://www.ncbi.nlm.nih.gov/pubmed/19818860 for more details.

The script has been updated and improved since this publication.

--------------------------------------------------------------------------------------
Script by Nick Tustison
--------------------------------------------------------------------------------------
Apple XGrid support by Craig Stark
--------------------------------------------------------------------------------------

USAGE
    exit 1
}

function summarizeimageset() {

  local dim=$1
  shift
  local output=$1
  shift
  local method=$1
  shift
  local images=( "${@}" "" )

  case $method in
    0) #mean
      AverageImages $dim $output 0 ${images[*]}
      ;;
    1) #mean of normalized images
      AverageImages $dim $output 1 ${images[*]}
      ;;
    2) #median
      for i in "${images[@]}";
        do
          echo $i >> ${output}_list.txt
        done

      ImageSetStatistics $dim ${output}_list.txt ${output} 1
      rm ${output}_list.txt
      ;;
  esac

  }

function jobfnamepadding {
    echo "jobname_here"
    outdir=`dirname ${TEMPLATES[0]}`
    if [[ ${#outdir} -eq 0 ]]
        then
        outdir=`pwd`
    fi

    files=`ls ${outdir}/job*.sh`
    BASENAME1=`echo $files[1] | cut -d 'b' -f 1`

    for file in ${files}
      do

      if [[ "${#file}" -eq "9" ]];
       then
         BASENAME2=`echo $file | cut -d 'b' -f 2 `
         mv "$file" "${BASENAME1}b_000${BASENAME2}"

      elif [[ "${#file}" -eq "10" ]];
        then
          BASENAME2=`echo $file | cut -d 'b' -f 2 `
          mv "$file" "${BASENAME1}b_00${BASENAME2}"

      elif [[ "${#file}" -eq "11" ]];
        then
          BASENAME2=`echo $file | cut -d 'b' -f 2 `
          mv "$file" "${BASENAME1}b_0${BASENAME2}"
      fi
    done
}


cleanup()
# example cleanup function
{

  cd ${currentdir}/

  echo "\n*** Performing cleanup, please wait ***\n"

# 1st attempt to kill all remaining processes
# put all related processes in array
runningANTSpids=( `ps -C antsRegistration -C N4BiasFieldCorrection -C ImageMath| awk '{ printf "%s\n", $1 ; }'` )

# debug only
  #echo list 1: ${runningANTSpids[@]}

# kill these processes, skip the first since it is text and not a PID
for ((i = 1; i < ${#runningANTSpids[@]} ; i++))
  do
  echo "killing:  ${runningANTSpids[${i}]}"
  kill ${runningANTSpids[${i}]}
done

  return $?
}

control_c()
# run if user hits control-c
{
  echo -en "\n*** User pressed CTRL + C ***\n"
  cleanup
  exit $?
  echo -en "\n*** Script cancelled by user ***\n"
}

#initializing variables with global scope
time_start=`date +%s`
currentdir=`pwd`
nargs=$#

STATSMETHOD=1
USEFLOAT=1
BACKUPEACHITERATION=0
MAXITERATIONS=100x100x70x20
SMOOTHINGFACTORS=3x2x1x0
SHRINKFACTORS=6x4x2x1
METRICTYPE=()
TRANSFORMATIONTYPE="SyN"
NUMBEROFMODALITIES=1
MODALITYWEIGHTSTRING=""
N4CORRECT=1
DOLINEAR=1
NOWARP=0
DOQSUB=1
GRADIENTSTEP=0.25
ITERATIONLIMIT=4
CORES=2
TDIM=0
RIGID=0
range=0
REGTEMPLATES=()
TEMPLATES=()
CURRENTIMAGESET=()
XGRIDOPTS=""
SCRIPTPREPEND=""
PBSWALLTIME="20:00:00"
PBSMEMORY="8gb"
# System specific queue options, eg "-q name" to submit to a specific queue
# It can be set to an empty string if you do not need any special cluster options
QSUBOPTS="" # EDIT THIS
OUTPUTNAME=antsBTP


##Getting system info from linux can be done with these variables.
# RAM=`cat /proc/meminfo | sed -n -e '/MemTotal/p' | awk '{ printf "%s %s\n", $2, $3 ; }' | cut -d " " -f 1`
# RAMfree=`cat /proc/meminfo | sed -n -e '/MemFree/p' | awk '{ printf "%s %s\n", $2, $3 ; }' | cut -d " " -f 1`
# cpu_free_ram=$((${RAMfree}/${cpu_count}))

if [[ ${OSTYPE:0:6} == 'darwin' ]];
  then
    cpu_count=`sysctl -n hw.physicalcpu`
  else
    cpu_count=`cat /proc/cpuinfo | grep processor | wc -l`
  fi

# Provide output for Help
if [[ "$1" == "-h" ]];
  then
    Usage >&2
  fi

# reading command line arguments
while getopts "a:b:c:d:e:f:g:h:i:j:k:l:m:n:o:p:q:s:r:t:u:v:w:x:z:" OPT
  #echo "WHILE"
  do
  case $OPT in
      h) #help
      Usage >&2
      exit 0
   ;;
      a) # summarizing statisitic
      STATSMETHOD=$OPTARG
   ;;
      b) #backup each iteration
   BACKUPEACHITERATION=$OPTARG
   ;;
      e) #float boolean
   USEFLOAT=$OPTARG
   ;;
      c) #use SGE cluster
   DOQSUB=$OPTARG
   if [[ $DOQSUB -gt 4 ]];
     then
       echo " DOQSUB must be an integer value (0=serial, 1=SGE qsub, 2=try pexec, 3=XGrid, 4=PBS qsub ) you passed  -c $DOQSUB "
       exit 1
     fi
   ;;
      d) #dimensions
   DIM=$OPTARG
   if [[ ${DIM} -eq 4 ]];
     then
       DIM=3
       TDIM=4
     fi
   ;;
      g) #gradient stepsize (default = 0.25)
   GRADIENTSTEP=$OPTARG
   ;;
      i) #iteration limit (default = 3)
   ITERATIONLIMIT=$OPTARG
   ;;
      j) #number of cpu cores to use (default = 2)
   CORES=$OPTARG
   ;;
      k) #number of modalities used to construct the template (default = 1)
   NUMBEROFMODALITIES=$OPTARG
   ;;
      l) #do linear (rigid + affine) for deformable registration
   DOLINEAR=$OPTARG
   ;;
      w) #modality weights (default = 1)
   MODALITYWEIGHTSTRING=$OPTARG
   ;;
      q) #max iterations other than default
   MAXITERATIONS=$OPTARG
   ;;
      f) #shrink factors
   SHRINKFACTORS=$OPTARG
   ;;
      s) #smoothing factors
   SMOOTHINGFACTORS=$OPTARG
   ;;
      n) #apply bias field correction
   N4CORRECT=$OPTARG
   ;;
      o) #output name prefix
   OUTPUTNAME=$OPTARG
   TEMPLATENAME=${OUTPUTNAME}template
   ;;
      p) #Script prepend
   SCRIPTPREPEND=$OPTARG
   ;;
      m) #similarity model
	  METRICTYPE[${#METRICTYPE[@]}]=$OPTARG
   ;;
      r) #start with rigid-body registration
   RIGID=$OPTARG
   ;;
      t) #transformation model
   TRANSFORMATIONTYPE=$OPTARG
   ;;
      u)
   PBSWALLTIME=$OPTARG
   ;;
      v)
   PBSMEMORY=$OPTARG
   ;;
      x) #initialization template
   XGRIDOPTS=$XGRIDOPTS
   ;;
      z) #initialization template
   REGTEMPLATES[${#REGTEMPLATES[@]}]=$OPTARG
   ;;
      \?) # getopts issues an error message
      echo "$USAGE" >&2
      exit 1
      ;;
  esac
done

# Provide different output for Usage and Help
if [[ ${TDIM} -eq 4 && $nargs -lt 5 ]];
  then
    Usage >&2
elif [[ ${TDIM} -eq 4 && $nargs -eq 5 ]];
  then
    echo ""
    # This option is required to run 4D template creation on SGE with a minimal command line
elif [[ $nargs -lt 6 ]]
  then
    Usage >&2
fi

if [[ $DOQSUB -eq 1 || $DOQSUB -eq 4 ]];
  then
    qq=`which  qsub`
    if [[  ${#qq} -lt 1 ]];
      then
        echo "do you have qsub?  if not, then choose another c option ... if so, then check where the qsub alias points ..."
        exit
      fi
  fi

if [[ $STATSMETHOD -gt 2 ]];
  then
  echo "Invalid stats type: using median (2)"
  STATSMETHOD=2
fi


# Creating the file list of images to make a template from.
# Shiftsize is calculated because a variable amount of arguments can be used on the command line.
# The shiftsize variable will give the correct number of arguments to skip. Issuing shift $shiftsize will
# result in skipping that number of arguments on the command line, so that only the input images remain.
shiftsize=$(($OPTIND - 1))
shift $shiftsize
# The invocation of $* will now read all remaining arguments into the variable IMAGESETVARIABLE
IMAGESETVARIABLE=$*
NINFILES=$(($nargs - $shiftsize))
IMAGESETARRAY=()

echo "Getting images..."
if [[ ${NINFILES} -eq 0 ]];
    then
    echo "Please provide at least 2 filenames for the template inputs."
    echo "Use `basename $0` -h for help"
    exit 1
elif [[ ${NINFILES} -eq 1 ]];
    then
    extension=`echo ${IMAGESETVARIABLE#*.}`
    if [[ $extension = 'csv' || $extension = 'txt' ]];
        then
        echo "Getting files from csv or txt file..."
        IMAGESFILE=$IMAGESETVARIABLE
        IMAGECOUNT=0
        echo $IMAGESFILE
        while read line
            do
            files=(`echo $line | tr ',' ' '`)
            if [[ ${#files[@]} -ne $NUMBEROFMODALITIES ]];
                then
                echo "The number of files in the csv file does not match the specified number of modalities."
                echo "See the -k option."
                exit 1
            fi
            for (( i = 0; i < ${#files[@]}; i++ ));
                do
                IMAGESETARRAY[$IMAGECOUNT]=${files[$i]}
                ((IMAGECOUNT++))
            done
         done < $IMAGESFILE
    fi
 else
    #echo $IMAGESETVARIABLE
    IMAGESETARRAY=()
    for IMG in $IMAGESETVARIABLE
      do
        IMAGESETARRAY[${#IMAGESETARRAY[@]}]=$IMG
      done
fi
echo "${#IMAGESETARRAY[@]} images found"
# remove old job bash scripts
outdir=`pwd`
rm -f ${outdir}/job*.sh

##########################################################################
#
# perform Function
#
##########################################################################


count=0
jobIDs=""

#EDIT BASECALL HERE - LUIS
for (( i = 0; i < ${#IMAGESETARRAY[@]}; i+=1 ))
  do
echo ${IMAGESETARRAY[$i]} $i | cut -d '/' -f 4 >> correspondanceTable.txt
basecall=" date >> testoutput.txt; sleep 60"

    #utilité à verifier------------------
    IMAGEMETRICSET=""
    for (( j = 0; j < $NUMBEROFMODALITIES; j++ ))
      do
        k=0
        let k=$i+$j
        IMAGEMETRICSET="$IMAGEMETRICSET -m MI[${TEMPLATES[$j]},${IMAGESETARRAY[$k]},${MODALITYWEIGHTS[$j]},32,Regular,0.25]"
      done
    #-------------------------------

    #stage1=""
    #stage1="-t Rigid[0.1] ${IMAGEMETRICSET} -c [10x10x10x10,1e-8,10] -f 8x4x2x1 -s 4x2x1x0 -o ${outdir}/rigid${i}_"
    exe="${basecall}" #${stage1}

    qscript="${outdir}/job_${count}_qsub.sh"
    echo "$SCRIPTPREPEND" > $qscript

    IMGbase=`basename ${IMAGESETARRAY[$i]}`
    BASENAME=` echo ${IMGbase} | cut -d '.' -f 1 `
    RIGID="${outdir}/rigid${i}_0_${IMGbase}"

    echo "$exe" > $qscript


    if [[ $DOQSUB -eq 1 ]];
      then
        id=`qsub -cwd -S /bin/bash -N do_ANTS -v ANTSPATH=$ANTSPATH $QSUBOPTS $qscript | awk '{print $3}'`
        jobIDs="$jobIDs $id"
        sleep 0.5
    fi
    ((count++))
done

if [[ $DOQSUB -eq 1 ]];
  then
    # Run jobs on SGE and wait to finish
    echo
    echo "--------------------------------------------------------------------------------------"
    echo " Lauching basecall on SGE cluster. Submitted $count jobs "
    echo "--------------------------------------------------------------------------------------"
    # now wait for the jobs to finish. Rigid registration is quick, so poll queue every 60 seconds
    ${ANTSPATH}/waitForSGEQJobs.pl 1 60 $jobIDs
    # Returns 1 if there are errors
    if [[ ! $? -eq 0 ]];
      then
        echo "qsub submission failed - jobs went into error state"
        exit 1;
      fi
  fi

for (( j = 0; j < $NUMBEROFMODALITIES; j++ ))
  do
    IMAGERIGIDSET=()
    for (( i = $j; i < ${#IMAGESETARRAY[@]}; i+=$NUMBEROFMODALITIES ))
      do
        k=0
        let k=$i-$j
        IMGbase=`basename ${IMAGESETARRAY[$i]}`
        BASENAME=` echo ${IMGbase} | cut -d '.' -f 1 `
        RIGID="${outdir}/rigid${k}_${j}_${IMGbase}"

        IMAGERIGIDSET[${#IMAGERIGIDSET[@]}]=$RIGID
      done
    echo
    echo  "${ANTSPATH}AverageImages $DIM ${TEMPLATES[$j]} 1 ${IMAGERIGIDSET[@]}"

  summarizeimageset $DIM ${TEMPLATES[$j]} $STATSMETHOD ${IMAGERIGIDSET[@]}
  #${ANTSPATH}AverageImages $DIM ${TEMPLATES[$j]} 1 ${IMAGERIGIDSET[@]}
 done

# cleanup and save output in seperate folder
#if [[ BACKUPEACHITERATION -eq 1 ]];
#  then
#    echo
#    echo "--------------------------------------------------------------------------------------"
#    echo " Backing up results from rigid iteration"
#    echo "--------------------------------------------------------------------------------------"
#
#    mkdir ${outdir}/rigid
#    mv ${outdir}/rigid*.nii.gz ${outdir}/*GenericAffine.mat ${outdir}/rigid/
#    # backup logs
#    if [[ $DOQSUB -eq 1 ]];
#      then
#        mv ${outdir}/do_KellyKapowski* ${outdir}/rigid/
#        # Remove qsub scripts
#        rm -f ${outdir}/job_${count}_qsub.sh
#    elif [[ $DOQSUB -eq 4 ]];
#      then
#        mv ${outdir}/antsrigid* ${outdir}/job* ${outdir}/rigid/
#    elif [[ $DOQSUB -eq 2 ]];
#      then
#        mv ${outdir}/job*.txt ${outdir}/rigid/
#    elif [[ $DOQSUB -eq 3 ]];
#      then
#        rm -f ${outdir}/job_*_qsub.sh
#    fi
#  else
#    rm -f  ${outdir}/rigid*.* ${outdir}/job*.txt
#fi

##########################
rm -f job*.sh
rm -f ${outdir}/job_${count}_qsub.sh
rm -f do*

time_end=`date +%s`
time_elapsed=$((time_end - time_start))
echo
echo "--------------------------------------------------------------------------------------"
echo " Execution finished"
echo " Script executed in $time_elapsed seconds"
echo " $(( time_elapsed / 3600 ))h $(( time_elapsed %3600 / 60 ))m $(( time_elapsed % 60 ))s"
echo "--------------------------------------------------------------------------------------"
exit 0