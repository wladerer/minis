import numpy as np
import pandas as pd
import plotly.express as px
import xml.etree.ElementTree as et 
import sys 


file = '/home/will/Documents/Minis/minis/VASP_XML/vasprun.xml' 
xtree = et.parse(file)
xroot = xtree.getroot()
print(xroot.findall('calculation')[0][0])

