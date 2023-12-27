#!/bin/bash

# This script executes pycbc_multi_inspiral, but leaving the following parameters free:
# Template bank size
# segment duration
# block duration

# Usage:
# ./coh_core.sh -input_path /home/sebastian.gomezlopez/performance_multi_insp/coh-common -ifos H1,L1,V1 -block_dur 512 -seg_dur 256 -t_shift 1 -t_bank T_1.xml.gz

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
        -t_shift)
	    # Amount of time the data will be shifted to do short-slides
	    # This can be mapped to number of slides via:
	    # From the source code 
            # -> https://lscsoft.docs.ligo.org/lalsuite/lalapps/coh___p_t_f__option_8c_source.html
            # one can get the equation (*)
            #     numShortSlides = 1 + numIFO * floor( strideDuration / (shortSlideOffset * (numIFO-1)) )
            t_shift="$2"
            shift 2
            ;;
        -t_bank)
	    # template bank basename
	    # NOT the path!
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
echo "Flag -t_shift set with value: $t_shift"
echo "Flag -t_bank set with value: $t_bank"
echo

n_ifos=${#ifos[@]}

#channel_h=GWOSC-4KHZ_R1_STRAIN
#channel_l=DCH-CLEAN_STRAIN_C02_T1700406_v3
#channel_v=GWOSC-4KHZ_R1_STRAIN

#h_cache=${input_path}/H1.lcf
#l_cache=${input_path}/L1.lcf
#v_cache=${input_path}/V1.lcf

channel_h=DCH-CLEAN_STRAIN_C02
channel_l=DCH-CLEAN_STRAIN_C02
channel_v=Hrec_hoft_V1O2Repro2A_16384Hz

h_cache=${input_path}/H1_5648.lcf
l_cache=${input_path}/L1_5648.lcf
v_cache=${input_path}/V1_5648.lcf


T_t=1187008882
offset=$(($block_dur/2))

# GPS start time
gst=$((T_t-$offset))
# GPS end time
get=$((T_t+$offset))
# Trigger start time
tst=$((T_t-89))
# Trigger end time
tet=$((T_t+183))

echo 
echo "BLOCK_DUR $(($get-$gst))"
echo

if [ "$(echo "$t_shift == 0" | bc -l)" -eq 1 ]; then
  echo "Running with no slides"
  lalapps_coh_PTF_inspiral\
                --verbose \
                --h1-data \
                --l1-data \
		--v1-data \
                --ligo-calibrated-data real_8 \
                --highpass-frequency 25 \
                --snr-threshold 3.0 \
                --trig-time-window 1 \
                --low-template-freq 29 \
                --low-filter-freq 30 \
                --high-filter-freq 1000 \
                --strain-data \
                --sample-rate 4096 \
                --segment-duration ${seg_dur} \
                --block-duration ${block_dur} \
                --do-trace-snr  \
                --do-bank-veto  \
                --do-auto-veto  \
                --do-chi-square \
                --num-auto-chisq-points 40 \
                --auto-veto-time-step 0.001 \
                --num-chi-square-bins 16 \
                --chi-square-threshold 6 \
                --approximant IMRPhenomD \
                --order pseudoFourPN \
                --sngl-snr-threshold 3.0 \
                --psd-segment-duration 32 \
                --do-clustering  \
                --cluster-window 0.1 \
                --inverse-spec-length 32 \
                --analyse-segment-end  \
                --pad-data 0 \
                --right-ascension 206.62533008380078 \
                --declination 22.219238201696275 \
                --sky-error 0.0 \
                --trigger-time ${T_t} \
                --face-on-analysis  \
                --face-away-analysis  \
                --h1-channel-name H1:${channel_h}\
                --l1-channel-name L1:${channel_l} \
		--v1-channel-name V1:${channel_v} \
                --bank-veto-templates ${input_path}/bank_veto_bank.xml \
                --gps-start-time ${gst} \
                --gps-end-time ${get} \
                --trig-start-time ${tst} \
                --trig-end-time ${tet} \
                --output-file out.xml.gz \
                --non-spin-bank ${t_bank} \
                --h1-frame-cache ${h_cache} \
                --l1-frame-cache ${l_cache} \
	        --v1-frame-cache ${v_cache}

else
  echo "Running with slides, timeshift $t_shift seconds"
  lalapps_coh_PTF_inspiral\
                --verbose \
                --h1-data \
                --l1-data \
                --v1-data \
                --ligo-calibrated-data real_8 \
                --highpass-frequency 25 \
                --snr-threshold 3.0 \
                --trig-time-window 1 \
                --low-template-freq 29 \
                --low-filter-freq 30 \
                --high-filter-freq 1000 \
                --strain-data \
                --sample-rate 4096 \
                --segment-duration ${seg_dur} \
                --block-duration ${block_dur} \
                --do-trace-snr  \
                --do-bank-veto  \
                --do-auto-veto  \
                --do-chi-square \
                --num-auto-chisq-points 40 \
                --auto-veto-time-step 0.001 \
                --num-chi-square-bins 16 \
                --chi-square-threshold 6 \
                --approximant IMRPhenomD \
                --order pseudoFourPN \
                --sngl-snr-threshold 3.0 \
                --psd-segment-duration 32 \
                --do-clustering  \
                --cluster-window 0.1 \
                --inverse-spec-length 32 \
                --analyse-segment-end  \
                --pad-data 0 \
                --right-ascension 206.62533008380078 \
                --declination 22.219238201696275 \
                --sky-error 0.0 \
                --trigger-time ${T_t} \
                --do-short-slides  \
                --short-slide-offset ${t_shift} \
                --face-on-analysis  \
                --face-away-analysis  \
                --h1-channel-name H1:${channel_h}\
                --l1-channel-name L1:${channel_l} \
                --v1-channel-name V1:${channel_v} \
		--bank-veto-templates ${input_path}/bank_veto_bank.xml \
                --gps-start-time ${gst} \
                --gps-end-time ${get} \
                --trig-start-time ${tst} \
                --trig-end-time ${tet} \
                --output-file out.xml.gz \
                --non-spin-bank ${t_bank} \
                --h1-frame-cache ${h_cache} \
                --l1-frame-cache ${l_cache} \
		--v1-frame-cache ${v_cache}
fi
