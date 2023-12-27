#!/bin/bash
# ./oneT_slides.sh -outpath /home/sebastian.gomezlopez/public_html/pygrb/test -outfile test
while [[ $# -gt 0 ]]; do
    case "$1" in
        -outpath)
            outpath="$2"
            shift 2
            ;;
        -outfile)
	    outfile="$2"
	    shift 2
	    ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

mkdir -p ${outpath}

file=${outpath}/${outfile}
cpu=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')

seg_dur=256
block_dur=5632
tsize=80

# The following python script generates a mapping
# that gives slideshifts and number_of_slides
# this is needed because coh_PTF and multi_inspiral 
# take different inputs and we want to make them comparable
# according to:
# 
python ../../shift_to_slide.py \
                      --ifos 3 \
                      --seg_dur $seg_dur \
		      --points 10

# The following lines take arrays in the json file
# and assign them to bash arrays
json_file="sh_sl-map.json"

readarray -t shifts < <(jq -r '.shifts[]' "$json_file")
readarray -t slides < <(jq -r '.slides[]' "$json_file")

# Number of runs to average over
# this used by the external loop to generate several
# timing results and later use python scripts to average and 
# find the errors. The code will be run n+1 times
n=4

for ((i = 0; i < n; i++)); do

echo -e "\\n\\n>> [`date`] Running on GW170817 data"
echo "${cpu}" >| ${file}_$i.txt
echo "#slides,user_time,real_time" >> ${file}_$i.txt

# NOTE: notice that the input path must contain all
# template banks named according to their size. 

for slide in "${slides[@]}"; do
echo -e "\\n\\n>> [`date`] running with $slides slides"
/usr/bin/time -p -o T.txt ./../../mi_core.sh \
    -input_path /home/sebastian.gomezlopez/performance_multi_insp/multi_insp-common \
    -ifos H1,L1,V1 \
    -block_dur $block_dur\
    -seg_dur $seg_dur \
    -n_slides $slide \
    -t_bank T_${tsize}.hdf

real_time=$(grep "real" T.txt | awk '{print $2}')
user_time=$(grep "user" T.txt | awk '{print $2}')

# Format the output
formatted_output="$slide,${user_time},${real_time}"

# Append the formatted output to the file
echo "$formatted_output" >> ${file}_$i.txt

done
done


# The following python scripts converts to json files and 
# then averages to find mean&std of the timing measurements

python ../../translate.py \
        --ifos H1 L1 V1 \
        --seg_dur ${seg_dur} \
        --input ${outpath} \
        --output ${outpath}/OT_mi_3_${seg_dur}_${block_dur} \
        --is_multi_insp

python ../../average.py \
        --input ${outpath} \
        --output ${outpath}/OT_mi_3_${seg_dur}_${block_dur}
