* Francisco Cavalcanti
* Website: https://sites.google.com/view/franciscocavalcanti/
* GitHub: https://github.com/FranciscoCavalcanti
* Twitter: https://twitter.com/Franciscolc85
* LinkedIn: https://www.linkedin.com/in/francisco-de-lima-cavalcanti-5497b027/

*------------------------------------------------------------------------
* STATA VERSION 14
* ------------------------------------------------------------------------

* version of stata
version 14.2

*** FOLDERS PATHWAY

* check what your username is in Stata by typing "di c(username)"
if "`c(username)'" == "Francisco"   {
    global ROOT "C:/Users/Francisco/Dropbox"
}
else if "`c(username)'" == "f.cavalcanti"   {
    global ROOT "C:/Users/f.cavalcanti/Dropbox"
}

global datadir			"${ROOT}/data_sources/Climatologia/INMET/input"
global dataout			"${ROOT}/data_sources/Climatologia/INMET/output"
global codedir			"${ROOT}/data_sources/Climatologia/INMET/code"
global tmp				"${ROOT}/data_sources/Climatologia/INMET/tmp"

* extract files .csv
* teste pra galera!

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
gen exp1 = 58 // 1960 + 58 = 2018
expand exp1
by estacao, sort: gen year = _n + 1960
gen exp2 = 12 //  12 months
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

* create a database where there is no missing date
preserve
	keep id_munic_7
	gen exp1 = 58 // 1960 + 58 = 2018
	expand exp1
	by id_munic_7, sort: gen year = _n + 1960
	gen exp2 = 12 //  12 months
	expand exp2
	by id_munic_7 year, sort: gen month = _n
	keep id_munic_7 year month
* save as temporary to use later
save "$tmp\nomissingdate.dta", replace
restore

* expand dataset in order merge each ground station with a municipality
**	obs: there are 265 ground stations
gen expd = 265
expand expd
by id_munic_7, sort: gen id  = _n

* merge with the ground station data set
merge m:1 id using "$tmp\stations.dta"

//generate the distance of each station for each municipality
sort  id_munic_7 id
gen distancia_estacao = sqrt((abs(lon - Longitude))^2 + (abs(lat - Latitude))^2)
sort  id_munic_7  distancia_estacao

gen distancia_estacao2 = distancia_estacao^2

//determine which stations are the least distant
sort  id_munic_7  distancia_estacao2
by id_munic_7: gen menores_distancias = _n

* Each municipality is a point
* When we draw two perpendicular lines where the point of intersection is the municipality
* we will then have 4 quadrants
* It should be noted which ground stations in each quadrant are closest to the municipality
* That is: which is the nearest station of the municipality in the Northwest quadrants? Northeast? South-west? Southeast?

* Define stations in each quadrant
sort  id_munic_7 id
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
sort  id_munic_7  quadrante_noroeste quadrante_nordeste quadrante_sudoeste quadrante_sudeste distancia_estacao2
by id_munic_7 quadrante_noroeste quadrante_nordeste quadrante_sudoeste quadrante_sudeste, sort: gen menores_distancias_por_quadrante = _n
keep if  menores_distancias_por_quadrante==1
sort  id_munic_7 menores_distancias
 
* define 4 different ways of measuring relevant stations

* first way: the nearest station
gen estacao_maneira = 1 if menores_distancias==1
replace estacao_maneira= 0 if estacao_maneira==.

* second way: distance of the two stations closest to the square and in different quadrants
sort  id_munic_7 menores_distancias_por_quadrante menores_distancias
by id_munic_7: gen depois_deleta = _n
by id_munic_7: egen algo = total(distancia_estacao2) if depois_deleta <=2
by id_munic_7: egen iten2 = mean(algo)
gen estacao_maneira2 = 1 - (distancia_estacao2/iten2)  if depois_deleta <=2 
replace estacao_maneira2 = 1 - (distancia_estacao2/iten2) if  depois_deleta <=2
replace estacao_maneira2= 0 if estacao_maneira2==.
drop  algo iten2


* third way: distance of the three stations closest to the square
sort  id_munic_7 menores_distancias_por_quadrante menores_distancias
by id_munic_7: egen algo = total(distancia_estacao2) if depois_deleta <=3
by id_munic_7: egen iten2 = mean(algo)

gen iten3 = distancia_estacao2/iten2 if depois_deleta <=3
replace iten3 = 1/iten3
by id_munic_7, sort: egen iten4 = total(iten3)
gen estacao_maneira3 = iten3/iten4
replace estacao_maneira3= 0 if estacao_maneira3==.
drop  algo iten2 iten3 iten4

* fourth way: distance from the nearest four stations to the square
sort  id_munic_7 menores_distancias_por_quadrante menores_distancias
by id_munic_7: egen algo = total(distancia_estacao2) if depois_deleta <=4
by id_munic_7: egen iten2 = mean(algo)

gen iten3 = distancia_estacao2/iten2 if depois_deleta <=4
replace iten3 = 1/iten3
by id_munic_7, sort: egen iten4 = total(iten3)
gen estacao_maneira4 = iten3/iten4
replace estacao_maneira4= 0 if estacao_maneira4==.
drop  algo iten2 iten3 iten4 depois_deleta

* delete irrelevant stations
keep  id_munic_6 id_munic_7 Latitude Longitude altitude area estacao estacao_maneira estacao_maneira2 estacao_maneira3 estacao_maneira4
gen codmun = id_munic_7
egen leao = group(id_munic_7)

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
forvalues inst1 = 1(1)5570{
	use "$tmp/mun_stations.dta", clear
	keep if leao == `inst1'
	merge m:m  estacao using "$tmp\inmet.dta"
	keep if _merge==3
	drop _merge
	replace numdiasprecipitacao = 31 if numdiasprecipitacao >= 31
	do "$codedir/_cleaning_data_imnet.do" 
	save "$tmp/id_munic_7_`inst1'.dta", replace
	clear
}

* append data
use "$tmp/id_munic_7_1.dta", clear

forvalues inst1 = 2(1)5570{
	append using "$tmp/id_munic_7_`inst1'.dta"
}

* merge with a database where there is no missing date
sort id_munic_7 year month
merge 1:1  id_munic_7 year month using "$tmp\nomissingdate.dta"
drop _merge

* generate variable of Regions
tostring id_munic_7, replace
gen region = substr(id_munic_7,1,1)
destring id_munic_7, replace
destring region, replace

* generate variable of State 
tostring id_munic_7, generate(str_id_munic_7)
gen state = substr(str_id_munic_7,1,2)
gen uf = real(state)
drop str_id_munic_7 state

* Graph histogram of evapotranspiration and precipitation
twoway (histogram evapotranspiracao, start(0) width(2) color(%65)) ///
       (histogram chuva, start(0) width(2)  ///
	   fcolor(none) lcolor(black)), 	/*
	   */	legend(order(1 "Potential Evapotranspiration" 2 "Precipitation"))	/*
	   */	yscale( axis(1) range(0 0.04) lstyle(none) )	/* how y axis looks
	   */	xscale( axis(1) range(0 160) lstyle(none) )	/* how x axis looks
	   */	title("Overlay of Histograms of Monthly Weather Data", size()) /*
	   */	xtitle("Millimeter (mm)")
	   
	graph save Graph "$dataout\histogram.gph", replace
	graph use "$dataout\histogram.gph"
	graph export "$dataout\histogram.png", replace	   

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

					
