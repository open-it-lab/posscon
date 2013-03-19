#!/usr/bin/env python
import os
import sys
import glob
import subprocess
from itertools import izip_longest
import subprocess

def grouper(n, iterable):
    args = [iter(iterable)] * n
    return ([e for e in t if e != None] for t in izip_longest(*args))

def main(*args):
    name = args[1]
    files = sorted(glob.glob('output/'+name+'-*'))
    if not files:
        sys.stderr.write('no files found!\n')
        sys.exit(1)
    outputdir = os.path.join('output',name)
    os.makedirs(outputdir)
    counter = 0
    for g in grouper(3,files):
        subprocess.call(["./multi.sh", 
                         os.path.join(outputdir,str(counter).zfill(2)),
                         ]+list(g))
        counter += 1

if __name__ == '__main__':
    sys.exit(main(*sys.argv))
