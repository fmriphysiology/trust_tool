#!/bin/csh
# calculate T2b and Yv from TRUST acquisition
# Based on script by Alan Stone
# Updated by Nic Blockley to use FSL tools
# Assumes images are 64x64 matrix and single slice
# Must be run in folder where images located

# check the number of inputs
if ( ${#argv} != 2 ) then
echo usage: trust_analysis fname num_eTEs
echo        - fname is the filename TRUST nifti file
echo          File must contain eTE concatenated across time
echo		- num_eTEs is the number of eTE values
exit
endif

# input
set trust_fname = `basename $1` # TRUST filename
set workingdir = `pwd`
echo $workingdir

# calculate pairwise subtracted image (dM)
asl_file --data=$trust_fname --ntis=$2 --iaf=ct --pairs --diff --out=dM.$trust_fname --mean=mean.dM.$trust_fname

# restrict roi for Superior Saggital Sinus
fslroi mean.dM.$trust_fname roi.dM.$trust_fname 22 20 0 20 0 1 0 1
fslroi mean.dM.$trust_fname mean.roi.dM.$trust_fname 22 20 0 20 0 1 0 -1

# get the threshold value for the 4 voxels in sagital sinus the 4th highest voxel
# percentile threshold set based on size of roi i.e. 4 voxels in 400 total voxels
set mask_thresh = `fslstats roi.dM.$trust_fname -p 99`
echo Threshold signal for saggital sinus is $mask_thresh

pwd
# make mask
fslmaths roi.dM.$trust_fname -thr $mask_thresh -bin mask.dM.$trust_fname
fslview_deprecated mean.roi.dM.$trust_fname mask.dM.$trust_fname -l Red

# extract mean timecourse
fslmeants -i mean.roi.dM.$trust_fname -o meantc.dM.$trust_fname -m mask.dM.$trust_fname

# find location of shell script
set rootdir = `dirname $0`
set abs_rootdir = `cd $rootdir && pwd`
echo MATLAB sripts located in $abs_rootdir

# CALC T2b and Yv
set matlabexec = `which matlab`
$matlabexec -nosplash -nodesktop -r "addpath('$abs_rootdir'); trust_analysis('$trust_fname'); exit;"