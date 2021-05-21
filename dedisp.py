"""


"""

import os
import sys
import numpy as np

def myexecute(cmd):
    print "'%s'"%cmd
    os.system(cmd)


# dDM steps from DDplan.py                                                                                                                                             
dDMs      = [float(sys.argv[3])]
# downsample factors                                                                                                                                                   
downsamps = [int(sys.argv[4])]
# number of calls per set of subbands                                                                                                                                  
subcalls  = [1]
# The low DM for each set of DMs                                                                                                                                       
startDMs  = [int(sys.argv[2])]
# DMs/call                                                                                                                                                             
dmspercall = int(sys.argv[5])
# The basename of the output files you want to use                                                                                                                     
basename = sys.argv[1]
# mask (put None if no mask)                                                                                                                                           
maskfile="../rfimask_rfifind.mask"
#sampling time (in us)                                                                                                                                                 
tsamp=500.0


# Loop over the DDplan plans                                                                                                                                           
for dDM, downsamp, subcall, startDM in \
        zip(dDMs, downsamps, subcalls, startDMs):
    for i in range(dmspercall):
        DM=i*dDM+startDM

        if maskfile:
            myexecute("prepdata -noclip -mask %s -nobary -dm %s -o topo_DM%s ../%s"%(maskfile,DM,DM,basename))
        else:
            myexecute("prepdata -noclip -nobary -dm %s -o topo_DM%s ../%s"%(DM,DM,basename))

#single pulse search                                                                                                                                                   
maxwidth = np.round(tsamp*1e-6*300.,decimals=2)
myexecute("single_pulse_search.py -p -b -m %s topo_DM*dat"%maxwidth)

#myexecute("echo '# DM      Sigma      Time (s)     Sample    Downfact' > candidates.singlepulse")
#myexecute("tail -n +2 -q *.singlepulse >> candidates.singlepulse")
