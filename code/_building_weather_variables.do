* Francisco Cavalcanti
* Website: https://sites.google.com/view/franciscocavalcanti/
* GitHub: https://github.com/FranciscoCavalcanti
* Twitter: https://twitter.com/Franciscolc85
* LinkedIn: https://www.linkedin.com/in/francisco-de-lima-cavalcanti-5497b027/

// Replace missing observations in monthly historial mean
sort id_munic_7 year month
by id_munic_7 month, sort: egen sdff = mean(evaporacao)
by id_munic_7, sort: replace evaporacao =  sdff if evaporacao ==. 

drop sdff

sort id_munic_7 year month
by id_munic_7 month, sort: egen sdff = mean(chuva)
by id_munic_7, sort: replace chuva =  sdff if chuva ==. 

drop sdff

sort id_munic_7 year month
by id_munic_7 month, sort: egen sdff = mean(temperatura_media)
by id_munic_7, sort: replace temperatura_media =  sdff if temperatura_media ==. 

drop sdff

sort id_munic_7 year month
by id_munic_7 month, sort: egen sdff = mean(umidade)
by id_munic_7, sort: replace umidade =  sdff if umidade ==. 

drop sdff

/////////////////////////////////////////// 
///// 
///// Generate cumulative weather measures
///// Regarding 12 monhts
///// 
/////////////////////////////////////////// 

//Aridity Index - 12 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  /*
	*/	month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11]
**if opa == 78 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 78
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] +  /*
	*/	chuva[_n-5] +  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10] +  /*
	*/	chuva[_n-11] if opa == 78
by id_munic_7, sort: gen inst2 =  evaporacao[_n] +  evaporacao[_n-1] +  evaporacao[_n-2] +  evaporacao[_n-3] +  /*
	*/	evaporacao[_n-4] +  evaporacao[_n-5] +  evaporacao[_n-6] +  evaporacao[_n-7] +  evaporacao[_n-8] +  /*
	*/	evaporacao[_n-9] +  evaporacao[_n-10] +  evaporacao[_n-11] if opa == 78
**Inverse of Aridity Index (higher numbers represent higher aridity) - 12 months
by id_munic_7, sort: gen aridity_evapo_12months = inst2/inst1
label variable aridity_evapo_12months "Aridity Index over 12 months"
drop  opa inst*

//Quantity of Rainfall - 12 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11]
**if opa == 78 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 78
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] +  chuva[_n-5] +  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10] +  chuva[_n-11] if opa == 78
**Inverse of Aridity Index (higher numbers represent higher aridity) - 12 months
by id_munic_7, sort: gen acum_rain_12months = inst1
label variable acum_rain_12months "Cumulative rainfall over 12 months"
drop  opa inst*

//Average Umidiy - 12 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11]
**if opa == 78 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 78
by id_munic_7, sort: gen inst1 =  umidade[_n] +  umidade[_n-1] +  umidade[_n-2] +  umidade[_n-3] +  umidade[_n-4] +  umidade[_n-5] +  umidade[_n-6] +  umidade[_n-7] +  umidade[_n-8] +  umidade[_n-9] +  umidade[_n-10] +  umidade[_n-11] if opa == 78
**average umidity  - 12 months
by id_munic_7, sort: gen umidade_12months = inst1/12
label variable umidade_12months "Average umidiy over 12 months"
drop  opa inst*

//Average Temperature - 12 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11]
**if opa == 78 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 78
by id_munic_7, sort: gen inst1 =  temperatura_media[_n] +  temperatura_media[_n-1] +  temperatura_media[_n-2] +  temperatura_media[_n-3] +  temperatura_media[_n-4] +  temperatura_media[_n-5] +  temperatura_media[_n-6] +  temperatura_media[_n-7] +  temperatura_media[_n-8] +  temperatura_media[_n-9] +  temperatura_media[_n-10] +  temperatura_media[_n-11] if opa == 78
**Average Temperature  - 12 months
by id_munic_7, sort: gen temperatura_12months = inst1/12
label variable temperatura_12months "Average temperature over 12 months"
drop  opa inst*

// The Standardised Precipitation-Evapotranspiration Index (SPEI)- 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  /*
*/	month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11]
**if opa == 78 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 78
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] +  /*
	*/	chuva[_n-5] +  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10] +  /*
	*/	chuva[_n-11] if opa == 78
by id_munic_7, sort: gen inst2 =  evaporacao[_n] +  evaporacao[_n-1] +  evaporacao[_n-2] +  evaporacao[_n-3] +  /*
	*/	evaporacao[_n-4] +  evaporacao[_n-5] +  evaporacao[_n-6] +  evaporacao[_n-7] +  evaporacao[_n-8] +  /*
	*/	evaporacao[_n-9] +  evaporacao[_n-10] +  evaporacao[_n-11] if opa == 78
**Difference between Evaporation and Precipitation (higher numbers represent higher aridity) - 12 months
by id_munic_7, sort: gen acum_SPEI_12months = inst2 - inst1
label variable acum_SPEI_12months "Cumulative SPEI over 12 months"
drop opa inst*

/////////////////////////////////////////// 
///// 
///// Generate cumulative weather measures
///// Regarding 24 monhts
///// 
/////////////////////////////////////////// 

//Aridity Index - 24 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] /*
	*/	+ month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11] +  month[_n-12] /* 
	*/	+ month[_n-13] +  month[_n-14] +  month[_n-15] +  month[_n-16] +  month[_n-17] +  month[_n-18] /*
	*/	+  month[_n-19] +  month[_n-20] +  month[_n-21] +  month[_n-22] +  month[_n-23]  
**if opa == 156 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 156
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] /*
	*/	+  chuva[_n-5] +  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10] /*
	*/	+ chuva[_n-11] + chuva[_n-12] + chuva[_n-13] + chuva[_n-14] + chuva[_n-15] /*
	*/	+ chuva[_n-16] + chuva[_n-17] + chuva[_n-18] + chuva[_n-19] + chuva[_n-20] /* 
	*/	+ chuva[_n-21] + chuva[_n-22] + chuva[_n-23] /* 
	*/	if opa == 156
by id_munic_7, sort: gen inst2 =  evaporacao[_n] +  evaporacao[_n-1] +  evaporacao[_n-2] +  evaporacao[_n-3] +  evaporacao[_n-4] /*
	*/	+  evaporacao[_n-5] +  evaporacao[_n-6] +  evaporacao[_n-7] +  evaporacao[_n-8] +  evaporacao[_n-9] +  evaporacao[_n-10] /*
	*/	+ evaporacao[_n-11] + evaporacao[_n-12] + evaporacao[_n-13] + evaporacao[_n-14] + evaporacao[_n-15] /*
	*/	+ evaporacao[_n-16] + evaporacao[_n-17] + evaporacao[_n-18] + evaporacao[_n-19] + evaporacao[_n-20] /* 
	*/	+ evaporacao[_n-21] + evaporacao[_n-22] + evaporacao[_n-23] /* 
	*/	if opa == 156
**Inverse of Aridity Index (higher numbers represent higher aridity) - 24 months
by id_munic_7, sort: gen aridity_evapo_24months = inst2/inst1
label variable aridity_evapo_24months "Aridity Index over 24 months"
drop  opa inst*

//Quantity of Rainfall - 24 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] /*
	*/	+  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11] +  month[_n-12] /*
	*/	+ month[_n-13] +  month[_n-14] +  month[_n-15] +  month[_n-16] +  month[_n-17] +  month[_n-18] /*
	*/	+  month[_n-19] +  month[_n-20] +  month[_n-21] +  month[_n-22] +  month[_n-23]  
**if opa == 156 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 156
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] +  chuva[_n-5] /*
	*/	+  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10] /*
	*/	+ chuva[_n-11] + chuva[_n-12] + chuva[_n-13] + chuva[_n-14] + chuva[_n-15] /* 
	*/	+ chuva[_n-16] + chuva[_n-17] + chuva[_n-18] + chuva[_n-19] + chuva[_n-20] /* 
	*/	+ chuva[_n-21] + chuva[_n-22] + chuva[_n-23] /* 
	*/	if opa == 156
**Inverse of Aridity Index (higher numbers represent higher aridity) - 24 months
by id_munic_7, sort: gen acum_rain_24months = inst1
label variable acum_rain_24months "Cumulative rainfall over 24 months"
drop  opa inst*

//Average Umidiy - 24 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] /*
	*/	+  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11] +  month[_n-12] /*
	*/	+ month[_n-13] +  month[_n-14] +  month[_n-15] +  month[_n-16] +  month[_n-17] +  month[_n-18] /*
	*/	+  month[_n-19] +  month[_n-20] +  month[_n-21] +  month[_n-22] +  month[_n-23]  
**if opa == 156 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 156
by id_munic_7, sort: gen inst1 =  umidade[_n] +  umidade[_n-1] +  umidade[_n-2] +  umidade[_n-3] +  umidade[_n-4] +  umidade[_n-5] /*
	*/	+  umidade[_n-6] +  umidade[_n-7] +  umidade[_n-8] +  umidade[_n-9] +  umidade[_n-10] /*
	*/	+ umidade[_n-11] + umidade[_n-12] + umidade[_n-13] + umidade[_n-14] + umidade[_n-15] /* 
	*/	+ umidade[_n-16] + umidade[_n-17] + umidade[_n-18] + umidade[_n-19] + umidade[_n-20] /* 
	*/	+ umidade[_n-21] + umidade[_n-22] + umidade[_n-23] /* 
	*/	if opa == 156
**average umidity  - 24 months
by id_munic_7, sort: gen umidade_24months = inst1/24
label variable umidade_24months "Average umidiy over 24 months"
drop  opa inst*

//Average Temperature - 24 months
sort id_munic_7 year month
gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] /*
	*/	+  month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11] +  month[_n-12] /*
	*/	+ month[_n-13] +  month[_n-14] +  month[_n-15] +  month[_n-16] +  month[_n-17] +  month[_n-18] /*
	*/	+  month[_n-19] +  month[_n-20] +  month[_n-21] +  month[_n-22] +  month[_n-23]  
**if opa == 156 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 156
by id_munic_7, sort: gen inst1 =  temperatura_media[_n] +  temperatura_media[_n-1] +  temperatura_media[_n-2] +  temperatura_media[_n-3] +  temperatura_media[_n-4] +  temperatura_media[_n-5] /*
	*/	+  temperatura_media[_n-6] +  temperatura_media[_n-7] +  temperatura_media[_n-8] +  temperatura_media[_n-9] +  temperatura_media[_n-10] /*
	*/	+ temperatura_media[_n-11] + temperatura_media[_n-12] + temperatura_media[_n-13] + temperatura_media[_n-14] + temperatura_media[_n-15] /* 
	*/	+ temperatura_media[_n-16] + temperatura_media[_n-17] + temperatura_media[_n-18] + temperatura_media[_n-19] + temperatura_media[_n-20] /* 
	*/	+ temperatura_media[_n-21] + temperatura_media[_n-22] + temperatura_media[_n-23] /* 
	*/	if opa == 156
**Average Temperature  - 24 months
by id_munic_7, sort: gen temperatura_24months = inst1/24
label variable temperatura_24months "Average temperature over 24 months"
drop  opa inst*

// The Standardised Precipitation-Evapotranspiration Index (SPEI)- 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen opa = month[_n] +  month[_n-1] +  month[_n-2] +  month[_n-3] +  month[_n-4] +  month[_n-5] +  /*
*/	month[_n-6] +  month[_n-7] +  month[_n-8] +  month[_n-9] +  month[_n-10] +  month[_n-11] +  month[_n-12] /* 
*/	+ month[_n-13] +  month[_n-14] +  month[_n-15] +  month[_n-16] +  month[_n-17] +  month[_n-18] /*
*/	+  month[_n-19] +  month[_n-20] +  month[_n-21] +  month[_n-22] +  month[_n-23]  
**if opa == 156 our observations is continues in months
**so we just have to count cumulative rainfall if opa == 156
by id_munic_7, sort: gen inst1 =  chuva[_n] +  chuva[_n-1] +  chuva[_n-2] +  chuva[_n-3] +  chuva[_n-4] +  /*
	*/	chuva[_n-5] +  chuva[_n-6] +  chuva[_n-7] +  chuva[_n-8] +  chuva[_n-9] +  chuva[_n-10]	/*
	*/	+ chuva[_n-11] + chuva[_n-12] + chuva[_n-13] + chuva[_n-14] + chuva[_n-15] /* 
	*/	+ chuva[_n-16] + chuva[_n-17] + chuva[_n-18] + chuva[_n-19] + chuva[_n-20] /* 
	*/	+ chuva[_n-21] + chuva[_n-22] + chuva[_n-23] /* 
	*/	if opa == 156
by id_munic_7, sort: gen inst2 =  evaporacao[_n] +  evaporacao[_n-1] +  evaporacao[_n-2] +  evaporacao[_n-3] +  evaporacao[_n-4] /*
	*/	+  evaporacao[_n-5] +  evaporacao[_n-6] +  evaporacao[_n-7] +  evaporacao[_n-8] +  evaporacao[_n-9] +  evaporacao[_n-10] /*
	*/	+ evaporacao[_n-11] + evaporacao[_n-12] + evaporacao[_n-13] + evaporacao[_n-14] + evaporacao[_n-15] /*
	*/	+ evaporacao[_n-16] + evaporacao[_n-17] + evaporacao[_n-18] + evaporacao[_n-19] + evaporacao[_n-20] /* 
	*/	+ evaporacao[_n-21] + evaporacao[_n-22] + evaporacao[_n-23] /* 
	*/	if opa == 156
**Difference between Evaporation and Precipitation (higher numbers represent higher aridity) - 24 months
by id_munic_7, sort: gen acum_SPEI_24months = inst2 - inst1
label variable acum_SPEI_24months "Cumulative SPEI over 24 months"
drop opa inst*

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////
//// Lag of weather variables
//// Regarding variables of 12 monhts
////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* Construct Lags of Measures of Rainfall
** Average Rainfall - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_rain_12months_lag1 = acum_rain_12months[_n-12]
by id_munic_7, sort: gen acum_rain_12months_lag2 = acum_rain_12months[_n-24]
by id_munic_7, sort: gen acum_rain_12months_lag3 = acum_rain_12months[_n-36]

* Construct Lags of Measures of Umidity
** Average Umidiy - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen umidade_12months_lag1 = umidade_12months[_n-12]
by id_munic_7, sort: gen umidade_12months_lag2 = umidade_12months[_n-24]
by id_munic_7, sort: gen umidade_12months_lag3 = umidade_12months[_n-36]

* Construct Lags of Measures of Temperature
** Average Temperature - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen temperatura_12months_lag1 = temperatura_12months[_n-12]
by id_munic_7, sort: gen temperatura_12months_lag2 = temperatura_12months[_n-24]
by id_munic_7, sort: gen temperatura_12months_lag3 = temperatura_12months[_n-36]

* Construct Lags of Measures of Aridity Index
** Aridity Index - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen aridity_evapo_12months_lag1 = aridity_evapo_12months[_n-12]
by id_munic_7, sort: gen aridity_evapo_12months_lag2 = aridity_evapo_12months[_n-24]
by id_munic_7, sort: gen aridity_evapo_12months_lag3 = aridity_evapo_12months[_n-36]

* Construct Lags of Measures of SPEI
** SPEI - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_SPEI_12months_lag1 = acum_SPEI_12months[_n-12]
by id_munic_7, sort: gen acum_SPEI_12months_lag2 = acum_SPEI_12months[_n-24]
by id_munic_7, sort: gen acum_SPEI_12months_lag3 = acum_SPEI_12months[_n-36]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////
//// Lag of weather variables
//// Regarding variables of 24 monhts
////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* Construct Lags of Measures of Rainfall
** Average Rainfall - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_rain_24months_lag1 = acum_rain_24months[_n-24]
by id_munic_7, sort: gen acum_rain_24months_lag2 = acum_rain_24months[_n-48]

* Construct Lags of Measures of Umidity
** Average Umidiy - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen umidade_24months_lag1 = umidade_24months[_n-24]
by id_munic_7, sort: gen umidade_24months_lag2 = umidade_24months[_n-48]

* Construct Lags of Measures of Temperature
** Average Temperature - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen temperatura_24months_lag1 = temperatura_24months[_n-24]
by id_munic_7, sort: gen temperatura_24months_lag2 = temperatura_24months[_n-48]

* Construct Lags of Measures of Aridity Index
** Aridity Index - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen aridity_evapo_24months_lag1 = aridity_evapo_24months[_n-24]
by id_munic_7, sort: gen aridity_evapo_24months_lag2 = aridity_evapo_24months[_n-48]

* Construct Lags of Measures of SPEI
** SPEI - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_SPEI_24months_lag1 = acum_SPEI_24months[_n-24]
by id_munic_7, sort: gen acum_SPEI_24months_lag2 = acum_SPEI_24months[_n-48]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////
//// Lead of weather variables
//// Regarding variables of 12 monhts
////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* Construct Leads of Measures of Rainfall
** Average Rainfall - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_rain_12months_lead1 = acum_rain_12months[_n+12]
by id_munic_7, sort: gen acum_rain_12months_lead2 = acum_rain_12months[_n+24]
by id_munic_7, sort: gen acum_rain_12months_lead3 = acum_rain_12months[_n+36]

* Construct Leads of Measures of Umidity
** Average Umidiy - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen umidade_12months_lead1 = umidade_12months[_n+12]
by id_munic_7, sort: gen umidade_12months_lead2 = umidade_12months[_n+24]
by id_munic_7, sort: gen umidade_12months_lead3 = umidade_12months[_n+36]

* Construct Leads of Measures of Temperature
** Average Temperature - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen temperatura_12months_lead1 = temperatura_12months[_n+12]
by id_munic_7, sort: gen temperatura_12months_lead2 = temperatura_12months[_n+24]
by id_munic_7, sort: gen temperatura_12months_lead3 = temperatura_12months[_n+36]

* Construct Leads of Measures of Aridity Index
** Aridity Index - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen aridity_evapo_12months_lead1 = aridity_evapo_12months[_n+12]
by id_munic_7, sort: gen aridity_evapo_12months_lead2 = aridity_evapo_12months[_n+24]
by id_munic_7, sort: gen aridity_evapo_12months_lead3 = aridity_evapo_12months[_n+36]

* Construct Leads of Measures of SPEI
** SPEI - 12 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_SPEI_12months_lead1 = acum_SPEI_12months[_n+12]
by id_munic_7, sort: gen acum_SPEI_12months_lead2 = acum_SPEI_12months[_n+24]
by id_munic_7, sort: gen acum_SPEI_12months_lead3 = acum_SPEI_12months[_n+36]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////
//// Lead of weather variables
//// Regarding variables of 24 monhts
////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* Construct Leads of Measures of Rainfall
** Average Rainfall - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_rain_24months_lead1 = acum_rain_24months[_n+24]
by id_munic_7, sort: gen acum_rain_24months_lead2 = acum_rain_24months[_n+48]

* Construct Leads of Measures of Umidity
** Average Umidiy - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen umidade_24months_lead1 = umidade_24months[_n+24]
by id_munic_7, sort: gen umidade_24months_lead2 = umidade_24months[_n+48]

* Construct Leads of Measures of Temperature
** Average Temperature - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen temperatura_24months_lead1 = temperatura_24months[_n+24]
by id_munic_7, sort: gen temperatura_24months_lead2 = temperatura_24months[_n+48]

* Construct Leads of Measures of Aridity Index
** Aridity Index - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen aridity_evapo_24months_lead1 = aridity_evapo_24months[_n+24]
by id_munic_7, sort: gen aridity_evapo_24months_lead2 = aridity_evapo_24months[_n+48]

* Construct Leads of Measures of SPEI
** SPEI - 24 months
sort id_munic_7 year month
by id_munic_7, sort: gen acum_SPEI_24months_lead1 = acum_SPEI_24months[_n+24]
by id_munic_7, sort: gen acum_SPEI_24months_lead2 = acum_SPEI_24months[_n+48]

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////
//// Average and standard deviation of weather variables
////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* keep only observations by year

keep if month ==12

// Calculating the average of cumulative rainfall each year and its standard deviation

by id_munic_7: egen mean_acum_rain_12months = mean(acum_rain_12months) 
by id_munic_7: egen sd_acum_rain_12months = sd(acum_rain_12months)
label variable mean_acum_rain_12months "Historial mean of rainfall"
label variable sd_acum_rain_12months "Standard deviation of historical rainfall"

by id_munic_7: egen mean_acum_rain_24months = mean(acum_rain_24months) 
by id_munic_7: egen sd_acum_rain_24months = sd(acum_rain_24months)
label variable mean_acum_rain_24months "Historial mean of rainfall"
label variable sd_acum_rain_24months "Standard deviation of historical rainfall"

// Calculating the average of cumulative aridity index each year and its standard deviation

by id_munic_7: egen mean_aridity_evapo_12months = mean(aridity_evapo_12months) 
by id_munic_7: egen sd_aridity_evapo_12months = sd(aridity_evapo_12months)
label variable mean_aridity_evapo_12months "Historial mean of aridity index"
label variable sd_aridity_evapo_12months "Standard deviation of historical aridity index"

by id_munic_7: egen mean_aridity_evapo_24months = mean(aridity_evapo_24months) 
by id_munic_7: egen sd_aridity_evapo_24months = sd(aridity_evapo_24months)
label variable mean_aridity_evapo_24months "Historial mean of aridity index"
label variable sd_aridity_evapo_24months "Standard deviation of historical aridity index"

// Calculating the average of cumulative umidity each year and its standard deviation

by id_munic_7: egen mean_umidade_12months = mean(umidade_12months) 
by id_munic_7: egen sd_umidade_12months = sd(umidade_12months)
label variable mean_umidade_12months "Historial mean of umidity"
label variable sd_umidade_12months "Standard deviation of historical umidity"

by id_munic_7: egen mean_umidade_24months = mean(umidade_24months) 
by id_munic_7: egen sd_umidade_24months = sd(umidade_24months)
label variable mean_umidade_24months "Historial mean of umidity"
label variable sd_umidade_24months "Standard deviation of historical umidity"

// Calculating the average of cumulative temperature each year and its standard deviation

by id_munic_7: egen mean_temperatura_12months = mean(temperatura_12months) 
by id_munic_7: egen sd_temperatura_12months = sd(temperatura_12months)
label variable mean_temperatura_12months "Historial mean of temperature"
label variable sd_temperatura_12months "Standard deviation of historical temperature"

by id_munic_7: egen mean_temperatura_24months = mean(temperatura_24months) 
by id_munic_7: egen sd_temperatura_24months = sd(temperatura_24months)
label variable mean_temperatura_24months "Historial mean of temperature"
label variable sd_temperatura_24months "Standard deviation of historical temperature"

// Calculating the average of cumulative rainfall each year and its standard deviation

by id_munic_7: egen mean_acum_SPEI_12months = mean(acum_SPEI_12months) 
by id_munic_7: egen sd_acum_SPEI_12months = sd(acum_SPEI_12months)
label variable mean_acum_SPEI_12months "Historial mean of SPEI"
label variable sd_acum_SPEI_12months "Standard deviation of historical SPEI"

by id_munic_7: egen mean_acum_SPEI_24months = mean(acum_SPEI_24months) 
by id_munic_7: egen sd_acum_SPEI_24months = sd(acum_SPEI_24months)
label variable mean_acum_SPEI_24months "Historial mean of SPEI"
label variable sd_acum_SPEI_24months "Standard deviation of historical SPEI"
