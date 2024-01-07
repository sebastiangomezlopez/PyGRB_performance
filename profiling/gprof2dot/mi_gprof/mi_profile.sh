#!/bin/bash -e


# set the absolute paths that point to where the .gwf files, template banks and
# veto banks are. 

path_to_frames=/home/sebastian.gomezlopez/REPOS_caltech/pycbc/examples/multi_inspiral
common_path=/home/sebastian.gomezlopez/performance_multi_insp/multi_insp-common

# Set the template bank size and the amount of short-slides
BANK_SIZE=20
slides=200

# Setting path to files, assuming they live somewhere in this cluster
BANK_FILE=${common_path}/banks/T_${BANK_SIZE}.hdf
BANK_VETO_FILE=${common_path}/bank_veto_bank.xml


# Set the .gwf file channel and path to files around GW170817

# first case(commented) are files publicly available in GWOSC
#channel_h=GWOSC-4KHZ_R1_STRAIN
#channel_l=DCH-CLEAN_STRAIN_C02_T1700406_v3
#channel_v=GWOSC-4KHZ_R1_STRAIN

#h_frame=${path_to_frames}/H-H1_GWOSC_4KHZ_R1-1187006835-4096.gwf
#l_frame=${path_to_frames}/L-L1_CLEANED_HOFT_C02_T1700406_v3-1187008667-4096.gwf
#v_frame=${path_to_frames}/V-V1_GWOSC_4KHZ_R1-1187006835-4096.gwf

# Second case 5000+ second files used in Dorrington's tests
channel_h=DCH-CLEAN_STRAIN_C02
channel_l=DCH-CLEAN_STRAIN_C02
channel_v=Hrec_hoft_V1O2Repro2A_16384Hz

h_frame=${path_to_frames}/H1-GATED-1187006058-5648.gwf
l_frame=${path_to_frames}/L1-GATED-1187006058-5648.gwf
v_frame=${path_to_frames}/V1-GATED-1187006058-5648.gwf


# Choosing the following input params can impact the performance
# block_dur: end_gps_time - start_gps time. 
# seg_dur: decides how many segments is the data divided into:
#	 segment_num = block_dur/seg_dur
# WARNING: setting segment_num higher than the available amount of
# threads per CPU, can result in overhead.

block_dur=5632
seg_dur=256

# Symmetrically defining the analizable data arround the event
# WARNING: one can easily go outside the frame file using this.

offset=$(($block_dur/2))

# GPS time for GW170817 
EVENT=1187008882
GPS_START=$((EVENT - $offset))
GPS_END=$((EVENT + $offset))

# onsource window (pycbc_multi_insp is not using this at the moment)
TRIG_START=$((EVENT - 89))
TRIG_END=$((EVENT + 183))

# output file used for postprocessing 
OUTPUT=GW170817_test_output.hdf

# Absolute path to pycbc_multi_inspiral executable
path=/home/sebastian.gomezlopez/.conda/envs/l_pycbc/bin


echo -e "\\n\\n>> [`date`] Running pycbc_multi_inspiral on GW170817 data"
python -m cProfile -o mi_profile_t${BANK_SIZE}_s${slides}.out ${path}/pycbc_multi_inspiral \
    --verbose \
    --processing-scheme mkl:1 \
    --projection left+right \
    --instruments H1 L1 V1 \
    --trigger-time ${EVENT} \
    --gps-start-time ${GPS_START} \
    --gps-end-time ${GPS_END} \
    --trig-start-time ${TRIG_START} \
    --trig-end-time ${TRIG_END} \
    --ra 3.44527994344 \
    --dec -0.408407044967 \
    --bank-file ${BANK_FILE} \
    --approximant IMRPhenomD \
    --order -1 \
    --low-frequency-cutoff 30 \
    --snr-threshold 3.0 \
    --chisq-bins "0.9*get_freq('fSEOBNRv4Peak',params.mass1,params.mass2,params.spin1z,params.spin2z)**(2./3.)" \
    --pad-data 8 \
    --strain-high-pass 25 \
    --sample-rate 4096 \
    --channel-name H1:${channel_h} L1:${channel_l} V1:${channel_v} \
    --frame-files \
        H1:${h_frame} \
        L1:${l_frame} \
        V1:${v_frame} \
    --cluster-method window \
    --cluster-window 0.1 \
    --segment-length ${seg_dur} \
    --segment-start-pad 0 \
    --segment-end-pad 0 \
    --psd-estimation median \
    --psd-segment-length 32 \
    --psd-segment-stride 8 \
    --psd-num-segments 29 \
    --num-slides ${slides} \
    --slide-shift 1 \
    --output ${OUTPUT}

# Absolute output path for gprof2dot results, accessible via external browser
out=/home/sebastian.gomezlopez/public_html/pygrb

python -m gprof2dot -f pstats mi_profile_t${BANK_SIZE}_s${slides}.out | dot -Tpng > ${out}/mi_profile_t${BANK_SIZE}_s${slides}.png
