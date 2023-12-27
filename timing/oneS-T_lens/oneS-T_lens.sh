#!/bin/bash

#boost=_boost
boost=
nameout=$1
file=L_${nameout}${boost}

cpu=$(lscpu | grep 'Model name' | cut -f 2 -d ":" | awk '{$1=$1}1')
echo -e "\\n\\n>> [`date`] Running on GW170817 data"
echo "${cpu}" >| ${file}.txt
echo "frame_length,user_time,real_time" >> ${file}.txt

lens=(300 400 600 800 1000 1500 2000 2200)

if [ "$nameout" = "multi_insp" ]; then
  for len in "${lens[@]}"; do
    echo -e "\\n\\n>> [`date`] running with $len,$(($len)) seconds of frame_len"
    /usr/bin/time -p -o T.txt ./mi_core.sh \
	    -input_path /home/sebastian.gomezlopez/performance_multi_insp/multi_insp-common \
	    -ifos H1,L1 \
	    -block_dur $len\
	    -seg_dur $(($len)) \
	    -n_slides 0 \
	    -t_bank T_1.hdf
    
    real_time=$(grep "real" T.txt | awk '{print $2}')
    user_time=$(grep "user" T.txt | awk '{print $2}')

    # Format the output
    formatted_output="$len,${real_time},${user_time}"

    # Append the formatted output to the file
    echo "$formatted_output" >> ${file}.txt

  done

  python /home/sebastian.gomezlopez/performance_multi_insp/translate.py \
        --input ${file}.txt \
        --output ${file}.json \
        --is_cohPTF False 

	
else
  for len in "${lens[@]}"; do
    echo -e "\\n\\n>> [`date`] running with $len,$(($len)) seconds of frame_len"
    /usr/bin/time -p -o T.txt ./coh_core.sh \
          -input_path /home/sebastian.gomezlopez/performance_multi_insp/coh-common \
          -ifos H1,L1 \
	  -block_dur $len \
	  -seg_dur $(($len)) \
	  -t_shift 0 \
	  -t_bank T_1.xml.gz

    real_time=$(grep "real" T.txt | awk '{print $2}')
    user_time=$(grep "user" T.txt | awk '{print $2}')

    # Format the output
    formatted_output="$len,${real_time},${user_time}"

    # Append the formatted output to the file
    echo "$formatted_output" >> ${file}.txt

  done

  python /home/sebastian.gomezlopez/performance_multi_insp/translate.py \
        --input ${file}.txt \
        --output ${file}.json \
        --is_cohPTF False
fi
