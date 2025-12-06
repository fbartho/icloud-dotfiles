#!/usr/bin/env python3

# import brotli !
# python3 ~/.bin/ttf2woff2.py Inter.ttf Inter.woff2

from fontTools.ttLib import woff2
import os
import sys

def convertFromWoff2ToOTF(infilename, outfilename):
    with open(infilename , mode='rb') as infile:
        with open(outfilename, mode='wb') as outfile:
            woff2.decompress(infile, outfile)

    return 0

def convertFromTTFToWoff2(infilename, outfilename):
    with open(infilename , mode='rb') as infile:
        with open(outfilename, mode='wb') as outfile:
            woff2.compress(infile, outfile)

    return 0

def main(argv):
    if len(argv) == 1 or len(argv) > 3:
        print("""
setup:
    python3 -m venv fonttools-venv
    . fonttools-venv/bin/activate
    pip install fonttools[woff2]
    pip install brotli

usage:
    python ttf2woff2.py [input.ttf] [output.woff/.woff2]""")
        return

    if argv[1].endswith('.ttf'):
        if len(argv) == 3:
            target_file_name = argv[2]
        else:
            target_file_name = argv[1].rsplit('.', 1)[0] + '.woff2'
        convertFromTTFToWoff2(argv[1], target_file_name)
    else:
        print("Provide one TTF file at a time")
        exit(1)
    
    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))