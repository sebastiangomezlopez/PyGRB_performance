# PyGRB_performance
The current repository contains several performance tests for [`pycbc_multi_inspiral`](https://github.com/gwastro/pycbc/blob/master/bin/pycbc_multi_inspiral).

## Dependencies 
PyCBC,grpof2dot,graphviz,snakeviz,scalene.

Moreover, To reproduce the results present in. 

- `pycbc_multi_inspiral`: create a conda environment witht the latest version of `pycbc`
- `lalapps_coh_PTF_inspiral`: only possible using michael patel's `pygrb_o3b` environment on CIT.

## Description
This repository contains different types of python and shell scripts to identify bottlenecks in `pycbc_multi_inspiral` and  compare it to `lalapps_coh_PTF_inspiral` by timing both of their performances.

- gprof2dot scripts. to identify bottlenecks for a given set of inputs
- During these studies, we aimed at quantifying performance differences of `pycbc_multi_inspiral` vs `lalapps_coh_PTF_inspiral`. To do so, we fixed many parameters set in the [`pycbc_multi_inspiral` example](https://github.com/gwastro/pycbc/blob/master/bin/pycbc_multi_inspiral), and let as free parameters `block_duration` `segment_duration` `number of short slides` & `template bank size`. Timing scripts are of three types:
    - oneT_slides scripts. "one template with varying slides".
      - for `pycbc_multi_inspiral` it lives in: `timing/modern/oneT_slides_mi`  
      - for `lalapps_coh_PTF_inspiral` it lives in: `timing/modern/oneT_slides_coh` 
    - NT_slides scripts. "N templates with varying slides".
      - for `pycbc_multi_inspiral` it lives in: `timing/modern/NT_slides_mi`  
      - for `lalapps_coh_PTF_inspiral` it lives in: `timing/modern/NT_slides_coh`
    - oneS-T_lens scripts. "No slides, one template with varying lenght(`block_duration`)"
      - This is broken at the moment 

NOTE: most of this scripts are refactored versions of the run.sh [example](https://github.com/gwastro/pycbc/blob/master/examples/multi_inspiral/run.sh) that analyzes GW170817.

## Usage:
Activate your conda environment with `pycbc` `graphviz` `gprof2dot`

- gprof2dot scripts:
  
Modify lines [path_to_frames](https://github.com/sebastiangomezlopez/PyGRB_performance/blob/b0850f3a950828ecc6b7feb4fb5e11ce927809c2/mi_gprof/mi_profile.sh#L7C1-L8C80), [common_path](https://github.com/sebastiangomezlopez/PyGRB_performance/blob/b0850f3a950828ecc6b7feb4fb5e11ce927809c2/mi_gprof/mi_profile.sh#L8) & [out](https://github.com/sebastiangomezlopez/PyGRB_performance/blob/992b79e1e18e5feafdad56b4c135e7862a0b80e7/mi_gprof/mi_profile.sh#L112) in `/timing/mi_gprof/mi_profile.sh`
  - path_to_frames -> this has to point where your frame files are
  - common_path  -> this has to point where your template bank and veto banks are.  
  - out -> this has to point where the .png output will go.
  ```
  - execute `./mi_profile.sh` 
  ```
- Timing scripts:

Modify this [line](https://github.com/sebastiangomezlopez/PyGRB_performance/blob/b0850f3a950828ecc6b7feb4fb5e11ce927809c2/timing/modern/mi_core.sh#L60) in     `timing/modern/mi_core.sh` to point where your frame files are.
  - oneT_slides scripts
  ```
  ./oneT_slides.sh -outpath /home/sebastian.gomezlopez/public_html/pygrb/test -outfile test
  ```
  - NT_slides scripts
  ```
  ./NT_slides.sh -outpath /home/sebastian.gomezlopez/public_html/pygrb/test -outfile test
  ```
