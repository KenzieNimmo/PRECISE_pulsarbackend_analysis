#!/usr/bin/env python

from filterbank import read_header, get_dtype, FilterbankFile, create_filterbank_file
import sys
import os 
import numpy as np
import re 

def chop_filterbank(infile,beginchan=None,endchan=None):
    
    fil = infile
    h, h_size = read_header(fil)
    out_header = h.copy()
    nchan = h['nchans']
    nbits = h['nbits']
    fch1 = h['fch1']
    foff = np.abs(h['foff'])
    dtype = get_dtype(nbits)
    bytes_per_spectrum = nchan * nbits / 8
    data_size = os.path.getsize(infile) - h_size
    nspec = data_size / bytes_per_spectrum
    
    with open(fil, 'rb') as f:
        print("Opening {0}".format(fil))
        f.seek(h_size, os.SEEK_SET)
        data = np.fromfile(f, dtype=dtype, count=nspec*nchan).reshape(nspec, nchan)
    
    if beginchan!=None:
        end=nchan-beginchan
        begin = nchan-endchan
        lowestfreq=fch1+(foff/2.)-(nchan*foff)
        newfch1 = lowestfreq+((nchan-begin-1)*foff)+(0.5*foff)
        newnchan = end-begin

        out_header['fch1']=newfch1                                                                                                                         
        out_header['nchans']=newnchan 

        data_chopped = data[:,begin:end]

        return data_chopped, out_header
    else: return data, out_header

filename =sys.argv[1]
base = re.sub('.fil','',filename)
data, out_header = chop_filterbank(filename,70,600)

outfilename = "%s_ch70-600.fil"%base
create_filterbank_file(outfilename, out_header, spectra=data.flatten(),mode='write', nbits=out_header['nbits'])

