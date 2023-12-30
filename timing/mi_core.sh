#!/bin/bash

# This script executes pycbc_multi_inspiral, but leaving the following parameters free:
# Template bank size
# segment duration
# block duration

# usage: 
# ./mi_core.sh -input_path /home/sebastian.gomezlopez/performance_multi_insp/multi_insp-common -ifos H1,L1,V1 -block_dur 400 -seg_dur 256 -n_slides 1 -t_bank T_1.hdf

while [[ $# -gt 0 ]]; do
    case "$1" in
        -input_path)
	    # path where the template bank, and veto banks are
	    input_path=$(echo "$2" | sed 's:/*$::')
            shift 2
            ;;
	-ifos)
	    # Tuple of IFOS, e.g. H1,L1,V1
            IFS=',' read -ra ifos <<< "$2"
            shift 2
            ;;
        -block_dur)
	    # Amount of seconds around GW170817
	    block_dur="$2"
	    shift 2
	    ;;
        -seg_dur)
	    # segment duration
            seg_dur="$2"
            shift 2
            ;;
        -n_slides)
	    # number of short slides
            n_slides="$2"
            shift 2
            ;;
        -t_bank)
	    # template bank path, only provide de basename as input
            t_bank=${input_path}/banks/"$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo
echo "Flag -ifos set with values: ${ifos[@]}"
echo "Flag -block_dur set with value: $block_dur"
echo "Flag -seg_dur set with value: $seg_dur"
echo "Flag -n_slides set with value: $n_slides"
echo "Flag -t_bank set with value: $t_bank"
echo

n_ifos=${#ifos[@]}

# Path to downloaded frames
path_to_frames=${input_path}/..

# Setting data channel names, and path to frames

# Public ones around GW170817 
#channel_h=GWOSC-4KHZ_R1_STRAIN
#channel_l=DCH-CLEAN_STRAIN_C02_T1700406_v3
#channel_v=GWOSC-4KHZ_R1_STRAIN

#h_frame=${path_to_frames}/H-H1_GWOSC_4KHZ_R1-1187006835-4096.gwf
#l_frame=${path_to_frames}/L-L1_CLEANED_HOFT_C02_T1700406_v3-1187008667-4096.gwf
#v_frame=${path_to_frames}/V-V1_GWOSC_4KHZ_R1-1187006835-4096.gwf

# channels and frames used by Dorrington
channel_h=DCH-CLEAN_STRAIN_C02
channel_l=DCH-CLEAN_STRAIN_C02
channel_v=Hrec_hoft_V1O2Repro2A_16384Hz

echo "here ${PWD}"

h_frame=${path_to_frames}/H1-GATED-1187006058-5648.gwf
l_frame=${path_to_frames}/L1-GATED-1187006058-5648.gwf
v_frame=${path_to_frames}/V1-GATED-1187006058-5648.gwf

echo "$h_frame"
echo "$l_frame"
echo "$v_frame"

# GPS time for GW170817
T_t=1187008882

# Symmetric offset times around trigger
# This wont work if the trigger is near the ends of the frame file
offset=$(($block_dur/2))


# GPS start time
gst=$((T_t-$offset))
# GPS end time
get=$((T_t+$offset))
# Trigger start time
tst=$((T_t-89))
# Trigger end time
tet=$((T_t+183))



OUTPUT=out.hdf


echo "running pycbc_multi_inspiral"
pycbc_multi_inspiral \
        --verbose \
        --projection left+right \
        --processing-scheme mkl:1 \
        --instruments H1 L1 V1 \
        --trigger-time ${T_t} \
        --gps-start-time ${gst} \
        --gps-end-time ${get} \
        --trig-start-time ${tst} \
        --trig-end-time ${tet} \
        --ra 3.44527994344 \
        --dec -0.408407044967 \
        --bank-file $t_bank \
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
          H1:$h_frame \
          L1:$l_frame \
	  V1:$v_frame \
        --cluster-method window \
        --cluster-window 0.1 \
        --segment-length $seg_dur \
        --segment-start-pad 0 \
        --segment-end-pad 0 \
        --psd-estimation median \
        --psd-segment-length 32 \
        --psd-segment-stride 8 \
        --psd-num-segments 29 \
        --num-slides $n_slides \
        --slide-shift 1 \
        --output ${OUTPUT}

