# INMET_Codes

Codes in **Stata** to extract the raw data provided by the [INMET - Instituto Nacional de Meteorologia](http://www.inmet.gov.br/portal/ "INMET - Instituto Nacional de Meteorologia") and generate a database in **.dta** format collapsed at the year and municipality level.

The data cover monthly information from **1960** to  **2018**. The raw data is stored in the the folder [input](./input). 

## Raw data

The raw data is text files (.txt) that have been downloaded from [INMET](http://www.inmet.gov.br/portal/) and are stored in the folder [input](./input). Specifically:

*  [**INMET_1960_2018.zip**](./input/INMET_1960_2018.zip) It is a compilation of the download of monthly data from all INMET weather stations.

*  [**brazilian_municipalities.dta**](./input/brazilian_municipalities.dta) codes of Brazilian municipalities.

## Stata codes

The codes are stored in the folder [code](./code).

* [**inmet.do**](./code/inmet.do):  Main code. Extract the raw data and generate a .dta database collapsed at the year and municipality level.

* [**_cleaning_data_imnet.do**](./code/_cleaning_data_imnet.do): Sub code. Clean the raw data

* [**_building_weather_variables.do**](./code/_building_weather_variables.do): Sub code. Generate weather variables

## How to reproduce

* You must generate a folder (give a name) with additional 4 folders contained within: **_input_**, **_output_**, **_code_**, **_tmp_**.
* Save raw data in **_input_**
* Save Stata codes in **_code_**
* Edit your path folder between lines 16 - 22 in the code [**inmet.do**](./code/inmet.do).
* Run the code [**inmet.do**](./code/inmet.do)
* It generates a database **inmet.dta** in the folder **_output_**
 
## Variables

![alt text](https://github.com/FranciscoCavalcanti/INMET_Codes/blob/master/input/DicionarioIMNET.PNG)

