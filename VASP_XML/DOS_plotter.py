import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import plotly.express as px
import xml.etree.ElementTree as et 
import sys 

def dos_dataframe(file):
    '''
    Takes a vasp xml file and extracts the density of states data for each ion -- output formatted as a tuple that contains the pandas dataframe and the list of orbitals within the ion's DOS plot
    '''
    xtree = et.parse(file)
    xroot = xtree.getroot()

    list_of_ion_lists = xroot.findall('calculation')[0].findall('dos')[0].findall('partial')[0].findall('array')[0].findall('set')[0].findall('set') #path to ion DOS data, in rows 
    list_of_names = xroot.findall('calculation')[0].findall('dos')[0].findall('partial')[0].findall('array')[0].findall('field') #path to names of each column of the DOS data
    list_of_ion_types = xroot.find('atominfo').findall('array')[0].findall('set')[0].findall('rc')
    efermi = float(xroot.findall('calculation')[0].findall('dos')[0].findall('i')[0].text.split()[0])
    ion_types = [item.findall('c')[0].text.split()[:][0] for item in list_of_ion_types]
    columns = [name.text.replace(' ', '') for name in list_of_names] #contains the names of the orbitals being plotted, removes whitespace from titles
    ions = [ion_list.findall('set')[0].findall('r') for ion_list in list_of_ion_lists] #takes DOS information per ion and adds it to the ions 
    number_of_ions = len(ions) #makes sure we are separating the DOS data by ion properly 

    DOSs = []
    for i in range(number_of_ions):
        ion = ions[i]
        rows = []
        for j in range(len(ion)):
            rows.append(ion[j].text) #extracts the text from each row for each ion and creates a temporary array to store all the information
        DOSs.append(rows) #appends all the rows per ion to the list of DOSs

    df = pd.DataFrame() # initializes a df to be concatenated later with DOS info and ion indices


    for ion_ind, DOS in enumerate(DOSs):
        new_DOS = []
        for j in range(len(DOS)):
            new_DOS.append([float(i) for i in DOS[j].split()]) #converts the values in the rows from strings to floats
        new_DOS = np.array(new_DOS)
        
        df_temp = pd.DataFrame(new_DOS, columns=columns)
        ind_arr = [ion_ind + 1 for i in range(len(DOS))] #creates proper indices for atoms according to VASP convention
        df_temp["ind"] = ind_arr
        df = pd.concat([df, df_temp])
    
    df['energy'] = df['energy'] - efermi #corrects Fermi Level

    return df, columns, ion_types, efermi
    

def plotDOS(file, xrange=[0,1], yrange=[-4,6]):
    ion_of_interest = int(input('Ion: '))
    data, names, ion_types, efermi = dos_dataframe(file)
    data = data[data['ind']==ion_of_interest]
    fig = px.line(data, x=names, y='energy',color_discrete_sequence=px.colors.qualitative.Vivid)
    fig.update_layout(
    font={
    'family': 'Copmuter Modern',
    'size': 16
    },
    title={
        'text': 'Density of states for ' + ion_types[ion_of_interest-1] + ' (Ion ' + str(ion_of_interest) + ')',
        'y':0.99,
        'x':0.5,
        'xanchor': 'center',
        'yanchor': 'top',
    },
    yaxis=dict(showgrid=False, title=r'$E - E_{Fermi}$ [eV]',range=yrange),
    xaxis=dict(showgrid=False, title= 'Density (states/eV)',range=xrange),
    legend_title_text='Orbital',
    )

    fig.show()

def plotDOS_sepl(file):
    '''
    Plots density of states of a specific ion, with each orbtial type summed together
    '''
    ion_of_interest = int(input('Ion: '))
    data, names, ion_types = dos_dataframe(file)
    data = data[data['ind']==ion_of_interest]

    for i,name in enumerate(names):
        if i == 0: #gets rid of energy
            continue
        if i == len(names) - 1:
            break
        if names[i+1].split()[0][0] in name[0]:
            data[names[i+1]] = data[name] + data[names[i+1]]
        if names[i+1].split()[0][0] == 'x':
            data[names[i+1]] = data[name] + data[names[i+1]]


    possible_cols = ['s','p','d','f']
    data = data[['energy','s','pz','x2-y2','ind']]
    data.rename(columns={'pz': 'p','x2-y2':'d'}, inplace=True)
    

    names = ['energy', 's', 'p', 'd']
    fig = px.line(data, x=names, y='energy', color_discrete_sequence =px.colors.qualitative.Dark24)
    fig.update_layout(
    font={
    'family': 'Copmuter Modern',
    'size': 16
    },
    title={
        'text': 'Density of states for ' + ion_types[ion_of_interest-1] + ' (Ion ' + str(ion_of_interest) + ')',
        'y':0.99,
        'x':0.5,
        'xanchor': 'center',
        'yanchor': 'top',
    },
    yaxis_title = r'$E - E_{Fermi}$ [eV]',
    xaxis_title = 'Density (states/eV)',
    legend_title_text='Total Density per Orbital',
    )
    fig.show()

def matplotlib_plot_ion(file):
    '''
    Same as plotDOS and related functions, but uses matplotlib 
    '''
    ion_of_interest = int(input('Ion: '))
    data, names = dos_dataframe(file)
    energy = data[data['ind']==ion_of_interest]['energy']

    for orbital in names[1:]:
        plt.plot(data[data['ind']==ion_of_interest][orbital],energy)

    plt.legend(names[1:])
    plt.xlabel('DOS')
    plt.ylabel('Energy')
    plt.ylim(-8.00, 4.00)
    plt.xlim(0,0.5)
    plt.title('Ion ' + '(' + ion_types[ion_of_interest -1] + ')')
    plt.show()


if __name__ == '__main__':
    globals()[sys.argv[1]](sys.argv[2])
