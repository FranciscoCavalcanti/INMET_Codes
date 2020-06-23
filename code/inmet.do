* ------------------------------------------------------------------------
* STATA VERSION 14
* ------------------------------------------------------------------------

* version of stata
version 14.2

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox/drought_corruption/build"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/f.cavalcanti/Dropbox/drought_corruption/build"
}

global datadir			"${ROOT}/INMET/input"
global dataout			"${ROOT}/INMET/output"
global codedir			"${ROOT}/INMET/code"
global tmp				"${ROOT}/INMET/tmp"

* extract files .csv

cd  "${tmp}"

unzipfile	"${datadir}/INMET_1960_2018.zip"

pwd

* set files
local files : dir . files "*.txt"
display `files'

* loop over files to extract longitude, latitude, and saving as .dta at the temporary directory
foreach file in `files' {	
	clear
	import delimited "${tmp}/`file'"/* 
	*/	,	delimiter(":") varnames(3)	
	drop if _n>4
	gen id = _n
	gen iten01 = v2 if id ==2
	egen latitude = mode(iten01)
	drop iten01
	gen iten01 = v2 if id ==3
	egen longitude = mode(iten01)
	drop iten01
	gen iten01 = v2 if id ==4
	egen altitude = mode(iten01)
	drop iten01
	gen iten01 = v3 if id ==1
	egen estacao = mode(iten01)	
	drop iten01
	drop if _n>1
	order estacao latitude longitude altitude
	keep estacao latitude longitude altitude
	replace estacao = substr(estacao,1,6)
	destring estacao, replace
	sum estacao
	local code = cond(r(min)==r(max),r(min),.)
	save "${tmp}/`code'_lat_long.dta", replace
	clear
}

* loop over files to extract rainfall, ando so on, and saving as .dta at the temporary directory
foreach file in `files' {	
	clear
	import delimited "${tmp}/`file'" /*
	*/ , delimiter(";") varnames(17) 
	destring estacao, replace
	sum estacao
	local code = cond(r(min)==r(max),r(min),.)
	save "${tmp}/`code'_data.dta", replace
	clear
}

* merging .dta files with 

* set files
cd  "${tmp}"

local dtafiles : dir . files "*.dta"
display `dtafiles'

foreach file in `dtafiles' {		
	append using "${tmp}/`file'"		
}

* manipulating the data to improve the format
by estacao, sort: egen Latitude = mode(latitude)
by estacao, sort: egen Longitude = mode(longitude)
by estacao, sort: egen Altitude = mode(altitude)

gen date = date(data, "DMY")
generate year = year(date)
generate month = month(date)
drop if data ==""

* keep relevant variables
keep estacao data direcaovento velocidadeventomedia velocidadeventomaximamedia /*
	*/	evaporacaopiche evapobhpotencial evapobhreal insolacaototal nebulosidademedia /*
	*/	numdiasprecipitacao precipitacaototal pressaonivelmarmedia pressaomedia tempmaximamedia /*
	*/	tempcompensadamedia tempminimamedia umidaderelativamedia visibilidademedia /*
	*/	Latitude Longitude Altitude year month

* save the data as temporary
cd  "${tmp}/"
save "${tmp}/inmet.dta", replace

* create a database where there is no missing date
use "${tmp}/inmet.dta", clear
by estacao, sort: drop if _n>1
keep estacao
gen exp1 = 58
expand exp1
by estacao, sort: gen year = _n + 1960
gen exp2 = 12
expand exp2
by estacao year, sort: gen month = _n
keep estacao year month

merge 1:1 estacao year month using "${tmp}/inmet.dta"
drop _merge

* generate an id to every ground station data set

** fulfill all missing values of Latitute, Longitude, Altitute
by estacao, sort: egen iten = mode(Latitude)
replace Latitude = iten
drop iten
by estacao, sort: egen iten = mode(Longitude)
replace Longitude = iten
drop iten
by estacao, sort: egen iten = mode(Altitude)
replace Altitude = iten
drop iten

** gen an id to all ground stations
by  estacao, sort: drop if _n>1
gen id  = _n
gen lat = Latitude
gen lon = Longitude
gen alt = Altitude
keep estacao lat lon alt id

* destring variables
destring lat, replace
destring lon, replace
destring alt, replace

* save as temporary to use later
save "$tmp\stations.dta", replace

* use data from brazilian municipalities
use "$datadir\brazilian_municipalities.dta", clear

* expand dataset in order merge each ground station with a municipality
**	obs: there are 264 ground stations
gen expd = 264
expand expd
by muncoddv, sort: gen id  = _n

* merge with the ground station data set
merge m:1 id using "$tmp\stations.dta"

//generate the distance of each station for each municipality
sort  muncoddv id
gen distancia_estacao = sqrt((abs(lon - Longitude))^2 + (abs(lat - Latitude))^2)
sort  muncoddv  distancia_estacao

gen distancia_estacao2 = distancia_estacao^2

//determine which stations are the least distant
sort  muncoddv  distancia_estacao2
by muncoddv: gen menores_distancias = _n

* Each municipality is a point
* When we draw two perpendicular lines where the point of intersection is the municipality
* we will then have 4 quadrants
* It should be noted which ground stations in each quadrant are closest to the municipality
* That is: which is the nearest station of the municipality in the Northwest quadrants? Northeast? South-west? Southeast?

* Define stations in each quadrant
sort  muncoddv id
gen  iten1 = lon - Longitude
gen iten2 = lat - Latitude

* Set stations that are in each quadrant
gen quadrante_noroeste =  1 if iten1 <=0 & iten2 >0
gen quadrante_nordeste =  1 if iten1 > 0 & iten2 >= 0
gen quadrante_sudoeste =  1 if iten1 < 0 & iten2 <= 0
gen quadrante_sudeste =  1 if iten1 >= 0 & iten2 <= 0
replace  quadrante_noroeste =0 if quadrante_noroeste~=1
replace  quadrante_nordeste =0 if quadrante_nordeste~=1
replace  quadrante_sudoeste =0 if quadrante_sudoeste~=1
replace  quadrante_sudeste =0 if quadrante_sudeste~=1
drop iten1 iten2
sort  muncoddv  quadrante_noroeste quadrante_nordeste quadrante_sudoeste quadrante_sudeste distancia_estacao2
by muncoddv quadrante_noroeste quadrante_nordeste quadrante_sudoeste quadrante_sudeste, sort: gen menores_distancias_por_quadrante = _n
keep if  menores_distancias_por_quadrante==1
sort  muncoddv menores_distancias
 
* define 4 different ways of measuring relevant stations

* first way: the nearest station
gen estacao_maneira = 1 if menores_distancias==1
replace estacao_maneira= 0 if estacao_maneira==.

* second way: distance of the two stations closest to the square and in different quadrants
sort  muncoddv menores_distancias_por_quadrante menores_distancias
by muncoddv: gen depois_deleta = _n
by muncoddv: egen algo = total(distancia_estacao2) if depois_deleta <=2
by muncoddv: egen iten2 = mean(algo)
gen estacao_maneira2 = 1 - (distancia_estacao2/iten2)  if depois_deleta <=2 
replace estacao_maneira2 = 1 - (distancia_estacao2/iten2) if  depois_deleta <=2
replace estacao_maneira2= 0 if estacao_maneira2==.
drop  algo iten2


* third way: distance of the three stations closest to the square
sort  muncoddv menores_distancias_por_quadrante menores_distancias
by muncoddv: egen algo = total(distancia_estacao2) if depois_deleta <=3
by muncoddv: egen iten2 = mean(algo)

gen iten3 = distancia_estacao2/iten2 if depois_deleta <=3
replace iten3 = 1/iten3
by muncoddv, sort: egen iten4 = total(iten3)
gen estacao_maneira3 = iten3/iten4
replace estacao_maneira3= 0 if estacao_maneira3==.
drop  algo iten2 iten3 iten4

* fourth way: distance from the nearest four stations to the square
sort  muncoddv menores_distancias_por_quadrante menores_distancias
by muncoddv: egen algo = total(distancia_estacao2) if depois_deleta <=4
by muncoddv: egen iten2 = mean(algo)

gen iten3 = distancia_estacao2/iten2 if depois_deleta <=4
replace iten3 = 1/iten3
by muncoddv, sort: egen iten4 = total(iten3)
gen estacao_maneira4 = iten3/iten4
replace estacao_maneira4= 0 if estacao_maneira4==.
drop  algo iten2 iten3 iten4 depois_deleta

* delete irrelevant stations
keep  muncod muncoddv Latitude Longitude altitude area estacao estacao_maneira estacao_maneira2 estacao_maneira3 estacao_maneira4
gen cod_mun = real( muncoddv)
egen leao = group(cod_mun)

* to string variable in order to perfectly match in merging process
tostring Latitude, replace
tostring Longitude, replace
gen Altitude = altitude 
tostring Altitude, replace
gen Area = area
tostring Area, replace

* save dataset as temporary file
save "$tmp/mun_stations.dta", replace

* merging each station of a municipality with rainfall data from IMNET
forvalues inst1 = 1(1)5658{
use "$tmp/mun_stations.dta", clear
keep if leao == `inst1'
merge m:m  estacao using "$tmp\inmet.dta"
keep if _merge==3
drop _merge
replace numdiasprecipitacao = 31 if numdiasprecipitacao >= 31
do "$codedir/_cleaning_data_imnet.do" 
save "$tmp/cod_mun_`inst1'.dta", replace
clear
}

* append data
use "$tmp/cod_mun_1.dta", clear

forvalues inst1 = 2(1)5658{
append using "$tmp/cod_mun_`inst1'.dta"
}

* generate variable of Regions
tostring cod_mun, replace
gen region = substr(cod_mun,1,1)
destring cod_mun, replace
destring region, replace

* generate variable of State 
tostring cod_mun, generate(str_cod_mun)
gen state = substr(str_cod_mun,1,2)
gen uf = real(state)
drop str_cod_mun state


* build weather variables
do "$codedir/_building_weather_variables.do" 

* save data in output
save "${dataout}/inmet.dta", replace
	
* delete temporary files

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.dta"
foreach datafile of local datafiles {
	rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.csv"
foreach datafile of local datafiles {
    rm `datafile'
}

cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.txt"
foreach datafile of local datafiles {
	rm "`datafile'"
}


cd  "${tmp}/"
local datafiles: dir "${tmp}/" files "*.pdf"
foreach datafile of local datafiles {
	rm `datafile'
}

* clear all
clear

					
