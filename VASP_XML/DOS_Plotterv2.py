import json 
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

data = pd.read_json("vasp_data.json")
