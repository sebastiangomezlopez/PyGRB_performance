#!/bin/bash -e

# This script uses pieces of the original GW170817 pycbc_multi_inspiral example which can be found in:
# https://github.com/pannarale/pycbc/tree/master/examples/multi_inspiral/run.sh
# It was modified by Sebastian Gomez Lopez to measure pycbc_multi_inspiral's performance
# when varying the amount of timeslides

# To run it, you must have a conda environment with pycbc.


echo
echo "Remember editing lines 33 & 34"
echo "to properly activate your conda environment"
echo
echo "If you want all results in the current folder, run the following:"
echo "source bench_slides.sh ./"
echo "Otherwise, run:"
echo "source bench_slides.sh <output_path>"
echo


# Needs three arguments to run
if (( $# < 1 )); then
    echo
    echo "Your command line should contain at least 1 arguments!"
    exit
fi

test_folder=$@
env=pygrb-dev-06.03.23
path_env=${HOME}/miniconda3/envs/${env}
cpu=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')

source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate ${path_env}




CONFIG_URL=https://github.com/gwastro/pycbc-config/raw/master/test/multi_inspiral
BANK_FILE=gw170817_single_template.hdf
BANK_VETO_FILE=bank_veto_bank.xml

H1_FRAME=https://www.gw-openscience.org/eventapi/html/GWTC-1-confident/GW170817/v3/H-H1_GWOSC_4KHZ_R1-1187006835-4096.gwf
L1_FRAME=https://dcc.ligo.org/public/0144/T1700406/003/L-L1_CLEANED_HOFT_C02_T1700406_v3-1187008667-4096.gwf
V1_FRAME=https://www.gw-openscience.org/eventapi/html/GWTC-1-confident/GW170817/v3/V-V1_GWOSC_4KHZ_R1-1187006835-4096.gwf


H1_CHANNEL=GWOSC-4KHZ_R1_STRAIN
L1_CHANNEL=DCH-CLEAN_STRAIN_C02_T1700406_v3
V1_CHANNEL=GWOSC-4KHZ_R1_STRAIN


echo -e "\\n\\n>> [`date`] Getting template bank"
wget -nv -nc -P ${test_folder} ${CONFIG_URL}/${BANK_FILE}
echo -e "\\n\\n>> [`date`] Bank veto bank"
wget -nv -nc -P ${test_folder} ${CONFIG_URL}/${BANK_VETO_FILE}

for IFO in H1 L1 V1; do
    echo -e "\\n\\n>> [`date`] Getting ${IFO} frame"
    FRAME=${IFO}_FRAME
    wget -nv -nc -P ${test_folder} ${!FRAME}
done

EVENT=1187008882
PAD=8
START_PAD=111
END_PAD=17
GPS_START=$((EVENT - 192 - PAD))
GPS_END=$((EVENT + 192 + PAD))
TRIG_START=$((GPS_START + START_PAD))
TRIG_END=$((GPS_END - END_PAD))
OUTPUT=GW170817_test_output.hdf

echo -e "\\n\\n>> [`date`] Running pycbc_multi_inspiral on GW170817 data"
echo "${cpu}" >| ${test_folder}/out.txt
echo "# slides, exec_time[seconds]" >> ${test_folder}/out.txt

for slide in {1..200..10}; do
  echo -e "\\n\\n>> [`date`] running with ${slide} slide"
  SECONDS=0
  pycbc_multi_inspiral \
      --verbose \
      --projection left+right \
      --processing-scheme mkl \
      --instruments H1 L1 V1 \
      --trigger-time ${EVENT} \
      --gps-start-time ${GPS_START} \
      --gps-end-time ${GPS_END} \
      --trig-start-time ${TRIG_START} \
      --trig-end-time ${TRIG_END} \
      --ra 3.44527994344 \
      --dec -0.408407044967 \
      --bank-file ${test_folder}/${BANK_FILE} \
      --approximant IMRPhenomD \
      --order -1 \
      --low-frequency-cutoff 30 \
      --snr-threshold 3.0 \
      --chisq-bins "0.9*get_freq('fSEOBNRv4Peak',params.mass1,params.mass2,params.spin1z,params.spin2z)**(2./3.)" \
      --pad-data 8 \
      --strain-high-pass 25 \
      --sample-rate 4096 \
      --channel-name H1:${H1_CHANNEL} L1:${L1_CHANNEL} V1:${V1_CHANNEL} \
      --frame-files \
          H1:${test_folder}/`basename ${H1_FRAME}` \
          L1:${test_folder}/`basename ${L1_FRAME}` \
          V1:${test_folder}/`basename ${V1_FRAME}` \
      --cluster-method window \
      --cluster-window 0.1 \
      --segment-length 256 \
      --segment-start-pad ${START_PAD} \
      --segment-end-pad ${END_PAD} \
      --psd-estimation median \
      --psd-segment-length 32 \
      --psd-segment-stride 8 \
      --psd-num-segments 29 \
      --num-slides ${slide} \
      --slide-shift 1 \
      --output ${test_folder}/${OUTPUT}
    echo -e "\\n\\n>> [`date`] time ${SECONDS} seconds"
    echo "${slide}, ${SECONDS}" >> ${test_folder}/out.txt

done


for slide in {200..5000..300}; do
  echo -e "\\n\\n>> [`date`] running with ${slide} slide"
  SECONDS=0
  pycbc_multi_inspiral \
      --verbose \
      --projection left+right \
      --processing-scheme mkl \
      --instruments H1 L1 V1 \
      --trigger-time ${EVENT} \
      --gps-start-time ${GPS_START} \
      --gps-end-time ${GPS_END} \
      --trig-start-time ${TRIG_START} \
      --trig-end-time ${TRIG_END} \
      --ra 3.44527994344 \
      --dec -0.408407044967 \
      --bank-file ${test_folder}/${BANK_FILE} \
      --approximant IMRPhenomD \
      --order -1 \
      --low-frequency-cutoff 30 \
      --snr-threshold 3.0 \
      --chisq-bins "0.9*get_freq('fSEOBNRv4Peak',params.mass1,params.mass2,params.spin1z,params.spin2z)**(2./3.)" \
      --pad-data 8 \
      --strain-high-pass 25 \
      --sample-rate 4096 \
      --channel-name H1:${H1_CHANNEL} L1:${L1_CHANNEL} V1:${V1_CHANNEL} \
      --frame-files \
          H1:${test_folder}/`basename ${H1_FRAME}` \
          L1:${test_folder}/`basename ${L1_FRAME}` \
          V1:${test_folder}/`basename ${V1_FRAME}` \
      --cluster-method window \
      --cluster-window 0.1 \
      --segment-length 256 \
      --segment-start-pad ${START_PAD} \
      --segment-end-pad ${END_PAD} \
      --psd-estimation median \
      --psd-segment-length 32 \
      --psd-segment-stride 8 \
      --psd-num-segments 29 \
      --num-slides ${slide} \
      --slide-shift 1 \
      --output ${test_folder}/${OUTPUT}
    echo -e "\\n\\n>> [`date`] time ${SECONDS} seconds"
    echo "${slide}, ${SECONDS}" >> ${test_folder}/out.txt

done

python plot_perf.py ${test_folder}/out.txt ${test_folder}/out.png
