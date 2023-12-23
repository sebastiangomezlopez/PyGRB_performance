# PyGRB_performance
The current repository contains several performance tests for [`pycbc_multi_inspiral`](https://github.com/gwastro/pycbc/blob/master/bin/pycbc_multi_inspiral).

## Dependencies 
PyCBC
grpof2dot
graphviz
snakeviz
scalene

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
