#!/usr/bin/python3

import pandas as pd
import glob, os
os.chdir("files/")
extension = '*'
all_filenames = [i for i in glob.glob('*.{}'.format(extension))]
combined_csv = pd.concat([pd.read_csv(f,delimiter='\t',header=0,na_values='-') for f in all_filenames ]).fillna('-')
combined_csv.to_csv("../merged_intel.dat",index=False,sep='\t',na_rep='-')
