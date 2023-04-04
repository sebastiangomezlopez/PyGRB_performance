import numpy as np
import matplotlib.pyplot as plt
import sys,re,textwrap

in_file = sys.argv[1]; out_file = sys.argv[2]

with open(in_file, 'r') as file:
    f = file.readlines()
    u = f[2:]; cpu=textwrap.wrap(f[0].split('\n')[0], width=18)


x, y = np.asarray([re.findall(r'\d+', j) for j in u], dtype=float).T

fig = plt.figure()
ax0 = fig.add_subplot()


ax0.plot(x, y ,'-o', label='\n'.join(cpu))
ax0.set_ylabel('time [sec]', fontsize='large')
ax0.set_xlabel('# slides', fontsize='large')

plt.legend()
plt.tight_layout()
plt.savefig(out_file)
