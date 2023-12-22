import numpy as np
import matplotlib.pyplot as plt
import argparse,re,textwrap
import json
from distutils.util import strtobool
import time
import os
import glob


parser = argparse.ArgumentParser(
        description='python translate.py --ifos H1 L1 V1 --seg_dur 256 --input /home/sebastian.gomezlopez/public_html/pygrb/test3 --output hola --is_cohPTF'        
                                    )

parser.add_argument('--ifos', nargs='*', default=None)
parser.add_argument('--seg_dur', default=None)
parser.add_argument('--is_cohPTF', action='store_true')
parser.add_argument('--is_multi_insp', action='store_true')

parser.add_argument('--input')
parser.add_argument('--output')

args = parser.parse_args()

if args.ifos is None:
    args.ifos=['H1', 'L1', 'V1']
if args.seg_dur is None:
    seg_dur=256


n_ifos=len(args.ifos)
seg_dur=np.float64(args.seg_dur)

in_path = str(args.input)
out_file = str(args.output)
coh = args.is_cohPTF
mi = args.is_multi_insp

print(vars(args))

#time.sleep(30)

def n_slides(shift, ifos=None, seg_dur=None):
    if ifos is None:
        ifos=3
    if seg_dur is None:
        seg_dur=256
    
    if shift != 0:
        return 1 + ifos * np.floor(0.5*seg_dur/(shift*(ifos-1)))
    else:
        return shift

def func(row):
    return [np.float64(elem.split('\n')[0]) for elem in row.split(',') ]

txt_files = glob.glob(os.path.join(in_path, '*.txt'))

for j,in_file in enumerate(txt_files):
    with open(in_file, 'r') as file0:
        f = file0.readlines()
        u = f[2:]; cpu=textwrap.wrap(f[0].split('\n')[0])

    A = np.array([func(elem) for elem in u ]).T.tolist()
    out = {elem.split('\n')[0]:A[j] for j,elem in enumerate(f[1].split(',')) }

    out['cpu'] = cpu[0]

    if coh:
        out['#slides']=[ int(n_slides(elem)) for elem in out['#slides'] ]
    elif mi:
        pass

    with open(f'{out_file}_{j}.json', 'w') as output:
        output.write(json.dumps(out, indent=4))
