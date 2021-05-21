import argparse
import glob
import os
import sys

import pandas as pd
pd.options.mode.chained_assignment = None
import numpy as np
from scipy import special
from astropy.io import fits as pyfits

import C_Funct
from extract_psrfits_subints import extract_subints_from_observation
import filterbank




def parser():
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                  description="The program groups events from single_pulse_search.py in pulses.")
    parser.add_argument('-file_name', help="Filename of raw data file.", default='*.fil')
    parser.add_argument('-FRB_name', help="Name of FRB", default='FRB180916')
    parser.add_argument('-sp_files', help="Filenames of single pulse files", default='./*.singlepulse')
    parser.add_argument('-store_dir', help="Path of the folder to store the output.", default='.')
    parser.add_argument('-db_name', help="Filename of the HDF5 database.", default='SinglePulses.hdf5')
    parser.add_argument('-DM_low', help="DM low that has been searched", default=0, type=float)
    parser.add_argument('-DM_high', help="DM high that has been searched", default=1000, type=float)    
    parser.add_argument('-SN_peak', help="Minimum peak S/N", default=5, type=float)
    parser.add_argument('-SN_min', help="Minimum S/N", default=5, type=float)
    parser.add_argument('-downfact_max', help="Max downfact", default=300, type=float)
    parser.add_argument('-events_dDM', help="Number of DM steps within two events are related to the same pulse.",default=5, type=float)
    parser.add_argument('-events_dt', help="Duration in sec within two events are related to the same pulse.", default=20e-3,type=float)
    parser.add_argument('-DM_step', help="Value of the DM step between timeseries.",default=1., type=float)
    parser.add_argument('-store_events', help="Store events in a HDF5 database.", action='store_true')
    parser.add_argument('-no_RFI', help="Do not select RFI instances.", action='store_false')
    parser.add_argument('-mask', help="To use rfimask_rfifind.mask mask file from rfifind when plotting, default not to mask", action='store_true')
    parser.add_argument('-save_fig', help="Use to save the figures instead of plotting on screen (Default:plot on screen).", action='store_true')
    parser.add_argument('-begin_mask', help="Begin channel for additional masking. If multiple frequency regions list with comma e.g. --begin_mask 60,100,345", default=None)
    parser.add_argument('-end_mask', help="End channel for additional masking", default=None)
    parser.add_argument('-dmtrue', help="Give the known DM of the FRB source to save candidates within +-3 units of the true DM [Default:None]", default=None)
    return parser.parse_args()
    
def main(args):
    if args.file_name.endswith('.fil'):
      header = filterbank.read_header(args.file_name)
      fil=True
      fits=False
    if args.file_name.endswith('.fits'):
      header = fits_header(args.file_name)
      fits=True
      fil=False
    pulses = pulses_database(args, header,fits=fits,fil=fil)

    


def pulses_database(args,header,events=None,fits=False,fil=True):
    #create pulses database                                         
    events = events_database(args, header)
    gb = events.groupby('Pulse',sort=False)
    pulses = events.loc[gb.Sigma.idxmax()]
    pulses.index = pulses.Pulse
    pulses.index.name = None
    pulses = pulses.loc[:,['DM','Sigma','Time','Sample','Downfact']]
    pulses.index.name = 'idx'
                                                               
    if fits==True:
        pulses['IMJD'] = header['STT_IMJD']
        pulses['SMJD'] = header['STT_SMJD'] + header['STT_OFFS'] + header['NSUBOFFS'] * header['NSBLK'] * header['TBIN'] + pulses.Time
        pulses.ix[pulses.SMJD > 86400, 'IMJD'] += 1  #Deal with observations taken over midnight
        pulses['Duration'] = pulses.Downfact * header['TBIN']
        pulses['top_Freq'] = header['OBSFREQ'] + abs(header['OBSBW']) / 2.
        
    if fil == True:
        pulses['IMJD'] = header[0]['tstart']
        pulses['SMJD'] = pulses.Time * (1./(60.*60.*24.))
        pulses['Duration'] = pulses.Downfact * header[0]['tsamp']
        pulses['top_Freq'] = header[0]['fch1'] +( np.abs(header[0]['foff']) /2.)
    
    pulses['Pulse'] = -1
    pulses.Pulse = pulses.Pulse.astype(np.int8)
    pulses['dDM'] = (gb.DM.max() - gb.DM.min()) / 2.
    pulses.dDM=pulses.dDM.astype(np.float32)
    pulses['dTime'] = (gb.Time.max() - gb.Time.min()) / 2.
    pulses.dTime=pulses.dTime.astype(np.float32)
    pulses['N_events'] = gb.DM.count()
    pulses.N_events = pulses.N_events.astype(np.int16)
    pulses['Obs_ID'] = os.path.splitext(args.db_name)[0]

    pulses = pulses[pulses.N_events > 5]

    n_pulses = pulses.shape[0] #zeroth order pulses                                                                                                                   
    print "{} pulses detected".format(n_pulses)

    if n_pulses > 0 and args.no_RFI:
        RFIexcision(events, pulses, args) #1st order                                                                                                                  

        #set search parameter space                                                                                                                                   
        pulses.Pulse[pulses.Sigma <= args.SN_peak] = 9
        pulses.Pulse[pulses.Downfact >= args.downfact_max] = 9
        pulses.Pulse[pulses.DM <= args.DM_low] = 9
        pulses.Pulse[pulses.DM >= args.DM_high] = 9
        pulses.Pulse[pulses.Sigma >= 9.09] =9

        print "{} pulses classified as astrophysical".format(pulses[pulses.Pulse == -1].shape[0])
        print pulses[pulses.Pulse == -1]
    
    pulses.sort_values(['Pulse','Sigma'], ascending=False, inplace=True)
    store = pd.HDFStore(os.path.join(args.store_dir,'Pulses.hdf5'), 'w')
    store.append('pulses',pulses[pulses.Pulse==-1],data_columns=['DM', 'Sigma', 'Time', 'Sample', 'Downfact','IMJD', 'SMJD', 'Duration', 'top_Freq', 'Pulse', 'dDM',
'dTime', 'N_events', 'Obs_ID'])
    store.close()
    
    for index, row in pulses[pulses.Pulse == -1].iterrows():
        timebegin=row['Time']-0.025
        dur = 0.05
        DM=row['DM']
        sigma=row['Sigma']
        boxwidth=row['Downfact']
        
        if args.mask == True:
            if args.save_fig == True:
                if args.begin_mask != None and args.end_mask != None:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s --scaleindep --begin_mask %s --end_mask %s --save_plot  %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s  --scaleindep --begin_mask %s --end_mask %s --save_plot %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name))
                else:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s --scaleindep --save_plot  %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s  --scaleindep --save_plot %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name))



            else: 
                if args.begin_mask != None and args.end_mask !=None:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s --scaleindep --begin_mask %s --end_mask %s  %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s  --scaleindep --begin_mask %s --end_mask %s %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name))
                else:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s --scaleindep %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --maskfile rfimask_rfifind.mask --mask --sigma %s --width %s  --scaleindep %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name))
        else: 
            if args.save_fig == True:
                if args.begin_mask != None and args.end_mask !=None:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s  --sigma %s --width %s --scaleindep --begin_mask %s --end_mask %s --save_plot  %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --sigma %s --width %s  --scaleindep --begin_mask %s --end_mask %s --save_plot %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name))
                else:
                    print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s  --sigma %s --width %s --scaleindep --save_plot  %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name)
                    os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --sigma %s --width %s  --scaleindep --save_plot %s"%(timebegin,dur,DM,sigma,boxwidth,args.file_name))
            else: 
                print "python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s  --sigma %s --width %s --begin_mask %s --end_mask %s --scaleindep  %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name)
                os.system("python ~/plotting/kenz_waterfaller.py -T %s -t %s -d %s --sigma %s --width %s  --scaleindep --begin_mask %s --end_mask %s  %s"%(timebegin,dur,DM,sigma,boxwidth,args.begin_mask,args.end_mask,args.file_name))


    return pulses #2nd (final) order    

def events_database(args,header):
    #create events database                                                                                                                                           

    #make a list of all the sinle pulse files                                                                                                                         
    sp_files = glob.glob(args.sp_files)
    #read the contents of each into a pandas DataFrame                                                                                                                
    events = pd.concat(pd.read_csv(f, delim_whitespace=True, dtype=np.float64) for f in sp_files if os.stat(f).st_size > 0)
    #restructuring                                                                                                                                                    
    events.reset_index(drop=True, inplace=True)
    events.columns = ['DM','Sigma','Time','Sample','Downfact','a','b']
    events = events.ix[:,['DM','Sigma','Time','Sample','Downfact']]
    events.index.name = 'idx'
    #make a 'Pulse' column                                                                                                                                            
    events['Pulse'] = 0
    events.Pulse = events.Pulse.astype(np.int32)
    events.Downfact = events.Downfact.astype(np.int16)
    events.Sample = events.Sample.astype(np.int32)
    events.sort_values(['DM','Time'],inplace=True)

    C_Funct.Get_Group(events.DM.values, events.Sigma.values, events.Time.values, events.Pulse.values,args.events_dDM, args.events_dt, args.DM_step)

    if args.store_events:
        store = pd.HDFStore(os.path.join(args.store_dir,args.db_name), 'w')
        store.append('events',events,data_columns=['Pulse','SAP','BEAM','DM','Time'])
        store.close()

    return events

def RFIexcision(events, pulses, args):
    RFI_code=9
    events = events[events.Pulse.isin(pulses.index)]
    events.sort_values(by='DM',inplace=True)
    gb = events.groupby('Pulse')
    pulses.sort_index(inplace=True)

    #remove flat SNR pulses.                                                                                                                                          
    pulses.Pulse[pulses.Sigma / gb.Sigma.min() <= args.SN_peak / args.SN_min] = RFI_code
    print("flatSNR", len(pulses.Pulse[pulses.Sigma / gb.Sigma.min() <= args.SN_peak / args.SN_min]))
    #remove flat duration pulses                                                                                                                                      
    pulses.Pulse[gb.Downfact.max() / pulses.Downfact < (args.SN_peak / args.SN_min)**2] = RFI_code
    print("flatdur", len(pulses.Pulse[gb.Downfact.max() / pulses.Downfact < (args.SN_peak / args.SN_min)**2]))
    #remove pulses intersecting half the maximum SNR different than 2 or 4 times                                                                                      
    def crosses(sig):
        diff = sig - (sig.max() + sig.min()) / 2.
        count = np.count_nonzero(np.diff(np.sign(diff)))
        return (count != 2) & (count != 4) & (count != 6) & (count != 8)
    pulses.Pulse[gb.apply(lambda x: crosses(x.Sigma))] = RFI_code

    #remove weaker pulses within a temporal window                                                                                                                    
    def only1(l):
        true_found = False
        for v in l:
            if v:
                # a True was found!
                if true_found:
                    # found too many True's
                    return False 
                else:
                    # found the first True
                    true_found = True
        # found zero or one True value
        return true_found

    def simultaneous(p):
        puls = pulses.Pulse[np.abs(pulses.Time-p.Time) < 0.02]

        if puls.shape[0] == 1: return False
        elif only1(puls==-1): return False
        elif p.name == np.argmax(pulses.Sigma[np.abs(pulses.Time-p.Time)<0.02]):
            return False
        else: return True
    pulses.Pulse[pulses.apply(lambda x: simultaneous(x), axis=1)] = RFI_code

    #remove many pulses concentrated in time                                                                                                                             
    def RFI_bursts(p):
        puls = pulses.Pulse[np.abs(pulses.Time-p.Time) < 1.]
        if puls.shape[0] <= 10: return False
        elif p.name == puls.index[0]:
            return False
        else: return True
    #pulses.Pulse[pulses.apply(lambda x: RFI_bursts(x), axis=1)] = RFI_code

    #finally, if the candidate is within +-3 of the known DM, keep the candidate
    if args.dmtrue!=None:
        def corr_DM(p,dmtrue):
            if (dmtrue-2) <= p.DM <= (dmtrue + 2) and p.Sigma>10:
                return True
            else: return False
        pulses.Pulse[pulses.apply(lambda x: corr_DM(x,float(args.dmtrue)), axis=1)] = -1   


        
    return

def fits_header(filename):
    with pyfits.open(filename,memmap=True) as fits:
        header = fits['SUBINT'].header + fits['PRIMARY'].header
    return header

if __name__ == '__main__':
  args = parser()
  main(args)
