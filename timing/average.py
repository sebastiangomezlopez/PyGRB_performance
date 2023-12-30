import numpy as np
import matplotlib.pyplot as plt
import argparse,re,textwrap
import json
from distutils.util import strtobool
import time
import os
import glob


parser = argparse.ArgumentParser(
        description='python average.py --input /home/sebastian.gomezlopez/public_html/pygrb/test3 --output hola')

parser.add_argument('--input')
parser.add_argument('--output')

args = parser.parse_args()



in_path = str(args.input)
out_file = str(args.output)


json_files = glob.glob(os.path.join(in_path, '*.json'))

for run,output_File in enumerate(json_files):
    print(output_File)
    with open(output_File, 'r') as f:
        data = json.load(f)
        if run==0:
            new = data.copy()
            us_t = np.zeros(shape=(len(data['user_time']), len(json_files)))
            re_t = np.zeros(shape=(len(data['real_time']), len(json_files)))
        us_t[:,run] = data['user_time']
        re_t[:,run] = data['real_time']

new['user_time'], new['user_time_std'], new['real_time'], new['real_time_std']=[np.mean(us_t, axis=1).tolist(),
                                                                            np.std(us_t, axis=1).tolist(),
                                                                            np.mean(re_t, axis=1).tolist(),
                                                                            np.std(re_t, axis=1).tolist()
                                                                           ]

# Replacing f-string for python 2.x compatibility
#out = os.path.join(os.path.dirname(output_File),
#        f'avg_{os.path.basename(out_file)}.json')
out = os.path.join(os.path.dirname(output_File), 
        'avg_{}.json'.format(os.path.basename(out_file)))
with open(out,'w') as f:
    json.dump(new, f, indent=4)
