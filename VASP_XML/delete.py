import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.express as px
import xml.etree.ElementTree as et 
import sys 

file = '/home/will/Downloads/spin.xml' #will eventually be converted to command line argparse

'''
Takes a vasp xml file and extracts the density of states data for each ion -- output formatted as a tuple that contains the pandas dataframe and the list of orbitals within the ion's DOS plot
'''
xtree = et.parse(file)
xroot = xtree.getroot()

list_of_ion_lists = xroot.iter('set') #path to ion DOS data, in rows
# list_of_names = xroot.findall('calculation')[0].findall('dos')[0].findall('partial')[0].findall('array')[0].findall('field') #path to names of each column of the DOS data
# list_of_ion_types = xroot.find('atominfo').findall('array')[0].findall('set')[0].findall('rc')
# efermi = float(xroot.findall('calculation')[0].findall('dos')[0].findall('i')[0].text.split()[0])

print(list_of_ion_lists)
