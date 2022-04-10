import re

file_name = '/Users/william/Desktop/Transfer/ltnf.rasscf.S1.log' #This should be the name of the RASSCF .log file
MO_regex = r'        \b([01]?[0-9][0-9]?|2[0-4][0-9]|25[0-5])  ........    ......' #Unique pattern for each individual MO
forbs_regex = r'4f..   \(...[1-9][0-9][0-9][0-9]\)' #Unique pattern for any f-orbital component 


with open(file_name) as f:
    lines = f.readlines()
    coefficients_per_line = []
    for line in lines:
        m = re.findall(forbs_regex, line) #finds all instances of f-orbitals, line by line
        coeffs = 0
        for occurance in m:
            number = re.search(r'\(.(.*)\)', occurance)
            coeffs += float(number.group(1))**2
        coefficients_per_line.append(coeffs)

for element in range(len(coefficients_per_line)-1): #rough heuristic to add AO coeffs if on a different line but within the same MO
    if coefficients_per_line[element+1] != 0:
        coefficients_per_line[element] = 0
        coefficients_per_line[element+1] += coefficients_per_line[element]

highest_value = max(coefficients_per_line)
highest_index = coefficients_per_line.index(highest_value)

with open(file_name) as f: #extracts the coefficients from the coefficient array
    lines = f.readlines()
    line_count = 0
    for line in lines:
        if line_count == highest_index -1:
            orbital = re.search(r'        ([01]?[0-9][0-9]?|2[0-4][0-9]|25[0-5])', line)
            print(orbital.group(1))
        line_count += 1

