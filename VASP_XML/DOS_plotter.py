from unicodedata import name
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.express as px
import xml.etree.ElementTree as et 
import sys 

""""
This is meant to be a catch all parser for the vasp.xml outputs. It should be able to produce DOS plots and fetch pertinent information
"""
# file = '/home/will/Documents/Minis/minis/VASP_XML/vasprun.xml' #will eventually be converted to command line argparse
def dos_dataframe(file):
    xtree = et.parse(file)
    xroot = xtree.getroot()

    list_of_ion_lists = xroot.findall('calculation')[0].findall('dos')[0].findall('partial')[0].findall('array')[0].findall('set')[0].findall('set')
    list_of_names = xroot.findall('calculation')[0].findall('dos')[0].findall('partial')[0].findall('array')[0].findall('field')

    columns = [] 
    for name in list_of_names:
        columns.append(name.text.replace(' ', ''))


    ions = []
    for ion_list in list_of_ion_lists:
        ions.append(ion_list.findall('set')[0].findall('r'))


    number_of_ions = len(ions)

    DOSs = []
    for i in range(number_of_ions):
        ion = ions[i]
        rows = []
        for j in range(len(ion)):
            rows.append(ion[j].text)
        DOSs.append(rows)

    numpy_DOSs = []
    df = pd.DataFrame()


    for ion_ind, DOS in enumerate(DOSs):
        new_DOS = []
        for j in range(len(DOS)):
            new_DOS.append([float(i) for i in DOS[j].split()])
        new_DOS = np.array(new_DOS)
        
        df_temp = pd.DataFrame(new_DOS, columns=columns)
        ind_arr = [ion_ind + 1 for i in range(len(DOS))]
        df_temp["ind"] = ind_arr
        df = pd.concat([df, df_temp])

    return df, columns

def plot_ion(file):
    ion_of_interest = int(input('Ion: '))
    data, names = dos_dataframe(file)
    data = data[data['ind']==ion_of_interest]
    fig = px.line(data, x=names, y='energy')
    fig.show()

# def plot_ion(file):
#     ion_of_interest = int(input('Ion: '))
#     data, names = dos_dataframe(file)
#     energy = data[data['ind']==ion_of_interest]['energy']

#     for orbital in names[1:]:
#         plt.plot(data[data['ind']==ion_of_interest][orbital],energy)

#     plt.legend(names[1:])
#     plt.xlabel('DOS')
#     plt.ylabel('Energy')
#     plt.ylim(-8.00, 4.00)
#     plt.xlim(0,0.5)
#     plt.title('Ion ' + str(ion_of_interest))
#     plt.show()


if __name__ == '__main__':
    globals()[sys.argv[1]](sys.argv[2])

# for name in names[1:]:
#     sns.lineplot(data=data, x=name, y='energy')
# plt.show()



# for orbital in data[data['ind']==1]:
#     plt.plot(orbital,data[data['ind']==1]['energy'])

