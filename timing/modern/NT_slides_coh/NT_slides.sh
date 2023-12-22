#!/bin/bash
# ./NT_slides.sh -outpath /home/sebastian.gomezlopez/public_html/pygrb/test -outfile test
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
block_dur=512

# The following python script computes a map between timeshifts
# and number of slides.
# this is done since we want to compare coh_PTF and multi_inspiral
# both short slide implementations take different inputs,
# but can be mapped acording to:
# From the source code
# -> https://lscsoft.docs.ligo.org/lalsuite/lalapps/coh___p_t_f__option_8c_source.html
# one can get the equation (*)
#     numShortSlides = 1 + numIFO * floor( strideDuration / (shortSlideOffset * (numIFO-1)) )
python /home/sebastian.gomezlopez/performance_multi_insp/shift_to_slide.py \
                                                         --ifos 3 \
                                                         --seg_dur $seg_dur \
							 --points 4

# Then read arrays generated by the python script above
# and assign bash arrays to them, in order to use them
# later on.
json_file="sh_sl-map.json"

readarray -t shifts < <(jq -r '.shifts[]' "$json_file")
readarray -t slides < <(jq -r '.slides[]' "$json_file")
templ=(1 20 50 80 100)

# n controls the number of iterations of the external loop
# the external loop is used to compute this n+1 times and then
# use python scripts to compute means&stds
n=4

for ((i = 0; i < n; i++)); do

echo -e "\\n\\n>> [`date`] Running on GW170817 data"
echo "${cpu}" >| ${file}_$i.txt
echo "#templates,#slides,user_time,real_time" >> ${file}_$i.txt

  for t in "${templ[@]}"; do
  for shift in "${shifts[@]}"; do
    echo -e "\\n\\n>> [`date`] running with $shift seconds of shift"
    /usr/bin/time -p -o T_nt.txt ./../coh_core.sh \
          -input_path /home/sebastian.gomezlopez/performance_multi_insp/coh-common \
          -ifos H1,L1,V1 \
	  -block_dur $block_dur \
	  -seg_dur $seg_dur \
	  -t_shift $shift \
	  -t_bank T_${t}.xml.gz

    real_time=$(grep "real" T_nt.txt | awk '{print $2}')
    user_time=$(grep "user" T_nt.txt | awk '{print $2}')

    # Format the output
    formatted_output="${t},${shift},${user_time},${real_time}"

    # Append the formatted output to the file
    echo "$formatted_output" >> ${file}_$i.txt

  done
  done

done


# The following python scripts converts to json files and
# then averages to find mean&std of the timing measurements
python /home/sebastian.gomezlopez/performance_multi_insp/translate.py \
        --ifos H1 L1 V1 \
        --seg_dur ${seg_dur} \
        --input ${outpath} \
        --output ${outpath}/NT_coh_3_${seg_dur}_${block_dur} \
        --is_cohPTF

python /home/sebastian.gomezlopez/performance_multi_insp/average.py \
        --input ${outpath} \
        --output ${outpath}/NT_coh_3_${seg_dur}_${block_dur}
