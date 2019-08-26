#!/usr/bin/env python
# coding: utf-8
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("file")
args = parser.parse_args()
filename = args.file
with open(filename,"r+") as f:
    lines = f.read().splitlines()
    best_struct = lines[1]
    best_struct_name,best_struct_score = best_struct.split(" ")[0:2]
print(best_struct_name,best_struct_score)

