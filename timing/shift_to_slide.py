import json
import numpy as np
import argparse

'''
python shift_to_slide.py --ifos 3 --seg_dur 256
'''

parser = argparse.ArgumentParser(
        description='hola'
                                    )

parser.add_argument('--ifos', nargs="*")
parser.add_argument('--seg_dur', nargs="*")
parser.add_argument('--points')

args = parser.parse_args()

ifos=np.intc(args.ifos)
seg_dur = np.float64(args.seg_dur)
N = np.intc(args.points)

def n_slides(shift, ifos=None, seg_dur=None):
    shift = np.array(shift)
    if np.all(ifos == None):
        ifos=2
    if np.all(seg_dur == None):
        seg_dur=400
    return 1 + ifos * np.floor(0.5*seg_dur/(shift*(ifos-1)))

top, bottom = (np.log(seg_dur)/np.log(2)), 1e-10
x = np.logspace(top, bottom, num=N, base=2).flatten()
y = np.int64(n_slides(x, ifos=3, seg_dur=seg_dur)).flatten()
_, ind = np.unique(y, return_index=True)

u, v = np.concatenate(([0], x[ind])).tolist(), np.concatenate(([0],y[ind])).tolist()
D = {'shifts':u, 'slides':v}
with open('sh_sl-map.json', 'w') as f:
    json.dump(D,f) 
