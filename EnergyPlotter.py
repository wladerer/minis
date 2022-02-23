import pandas as pd
import numpy as np 
import matplotlib.pyplot as plt


def get_attArray(dataframe, att): #Get an array of values
	data = dataframe[att]
	new_array = data.to_numpy()
	return new_array #returns 


def loadIters(titles):

	iteration_data = []
	for i in range(len(titles)):
		data = pd.read_csv(titles[i])
		iteration_data.append(data)
	
	iterations = []
	for data in iteration_data:
		reader = get_attArray(data, '      SCF            ') #Garbage column name from energy file
		valid_nums = reader[~np.isnan(reader)] #removes NaN values
		iterations.append(valid_nums)

	return iterations

#replace this with the titles of the energy files
titles = ['thf_energy_1.csv','thf_energy_2.csv','thf_energy_3.csv','thf_energy_4.csv','thf_energy_5.csv','thf_energy_6.csv']

loadIters(titles)

energies = np.concatenate(tuple((map(tuple, loadIters(titles))))) #creates a tuple of arrays that contain SCF energies

plt.plot(range(len(energies)),energies)
plt.show()

