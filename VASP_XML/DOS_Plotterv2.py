from email import header
import json
import numpy as np 
import xmltodict
import pandas as pd


#pandas handles JSON files better than xml
def to_json(file):
    with open(file) as xml_file:
        data_dict = xmltodict.parse(xml_file.read())
        xml_file.close()

        json_data = json.dumps(data_dict)

        with open("vasp_data.json", "w") as json_file:
            json_file.write(json_data)
            json_file.close()


        with open('vasp_data.json','r') as f:
            data = json.loads(f.read())


        headers = data['modeling']['calculation']['dos']['partial']['array']['field']
        efermi = data['modeling']['calculation']['dos']['i']['#text']
        atoms = int(data['modeling']['atominfo']['atoms'])
        
        
        indices = np.array([])
        for i in range(1,atoms+1):
            np.concatenate((indices, i*np.ones(301)),axis=None)
        
        indices = pd.DataFrame(indices)
        
        dos_arrays = []
        for ion in range(atoms):
            dos_arrays.append(data['modeling']['calculation']['dos']['partial']['array']['set']['set'][ion]['set']['r'])
        
        df = pd.DataFrame(np.concatenate(dos_arrays))
        
        df = pd.concat([df,indices])

        print(df)
to_json('VASP_XML/vasprun.xml')