# -*- coding: utf-8 -*-
"""
Created on Wed Mar 10 09:00:04 2021

@author: austi
"""

def correct_formatting(infile = "COS_sunf_lett_saff_all.fasta", outfile = "COS_sunf_lett_saff_all_1.fasta"):
    try: 
        in_handle = open(infile)
        out_handle = open(outfile, 'w')
    except:
        return -1 
    
    with in_handle, out_handle:
        for line in in_handle:
            if line[0] == ">":
                line = line.strip("\n")
                new_header = []
                new_header = line[0] + line[10:] + "-" + line[1:9] + "\n"
                out_handle.write(new_header)
            else:
                out_handle.write(line)
    return

correct_formatting()