# INMET_Codes

Codes in **Stata** to extract the raw data provided by the [INMET - Instituto Nacional de Meteorologia](http://www.inmet.gov.br/portal/ "INMET - Instituto Nacional de Meteorologia") and generate a database in **.dta** format collapsed at the year and municipality level.

The data cover monthly information from **1960** to  **2018**. The raw data is stored in the the folder [input](./input). 

## Raw data

The raw data are stored in the folder [input](./input). Specifically:

*  [**INMET_1960_2018.zip**](./input/INMET_1960_2018.zip) It is a compilation of the download of monthly data from all INMET weather stations.

*  [**brazilian_municipalities.dta**](./input/brazilian_municipalities.dta) codes of Brazilian municipalities.

## Main codes

The codes are stored in the folder [code](./code).

* [**inmet.do**](./code/inmet.do):  extract the raw data and generate a .dta database collapsed at the year and municipality level.

* [**_cleaning_data_imnet.do**](./code/_cleaning_data_imnet.do): clean the raw data

* [**_building_weather_variables.do**](./code/_building_weather_variables.do): generate weather variables


