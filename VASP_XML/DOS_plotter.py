import matplotlib as plt
import numpy as np
import pandas as pd
import xml.etree.ElementTree as et 


""""
This is meant to be a catch all parser for the vasp.xml outputs. It should be able to produce DOS plots and fetch pertinent information
"""
file = '/home/will/Documents/Minis/minis/VASP_XML/vasprun.xml' #will eventually be converted to command line argparse
xtree = et.parse(file)
xroot = xtree.getroot()
dendrites = [root for root in xroot]

calculations = dendrites[8][21]
print(calculations.getroot())



