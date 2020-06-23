
set more off

gsort year month  -estacao_maneira4 -estacao_maneira3 -estacao_maneira2

//CHUVA
//construir variavel de chuva de cada municipio 

//utilizar as quatro estações mais proximas do municipio
//ou seja, a estacao mais perto no quadrante sudoeste. a estacao mais perto no quadrante noroeste
//a estacao mais perto no quadrante sudeste e a estação mais perto no quadrante nordeste
//utilizo como peso das estacoes a sua distância ao quadrado

//existem estacaos que está faltando observações
//por isso uso apenas as estacoes que obtiveram alguma informacao
//caso contrário a variavel construida "rainfall" poderia ficar viesada
//por exemplo, como uma estação esta "missing" o calculo da rainfall esta atribuindo o valor zero.
//solucao: para dados com missing, refazer os pesos das estações

by year month, sort: gen teste = _n
by year month, sort: egen teste1 = max(teste)

by year month, sort: egen teste2 = total(estacao_maneira4) if precipitacaototal~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*precipitacaototal)
by year month, sort: egen inst2 = total(inst1) if precipitacaototal~=.
by year month, sort: egen chuva = mean(inst2)

label variable chuva "chuva por municipio"

drop teste2 inst1 inst2 peso_novo

//EVAPORACAO
by year month, sort: egen teste2 = total(estacao_maneira4) if  evaporacaopiche~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*evaporacaopiche)
by year month, sort: egen inst2 = total(inst1) if evaporacaopiche~=.
by year month, sort: egen evaporacao = mean(inst2)

label variable evaporacao "evaporação por municipio"

drop teste2 inst1 inst2 peso_novo

//EVAPOTRANSPIRACAO
by year month, sort: egen teste2 = total(estacao_maneira4) if  evapobhpotencial~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*evapobhpotencial)
by year month, sort: egen inst2 = total(inst1) if evapobhpotencial~=.
by year month, sort: egen evapotranspiracao = mean(inst2)

label variable evapotranspiracao "evapotranspiracao potencial por municipio"

drop teste2 inst1 inst2 peso_novo

//NEBULOSIDADE
by year month, sort: egen teste2 = total(estacao_maneira4) if  nebulosidademedia~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*nebulosidademedia)
by year month, sort: egen inst2 = total(inst1) if nebulosidademedia~=.
by year month, sort: egen nebulosidade = mean(inst2)

label variable nebulosidade "nebulosidade por municipio"

drop teste2 inst1 inst2 peso_novo

//INSOLACAO
by year month, sort: egen teste2 = total(estacao_maneira4) if  insolacaototal~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*insolacaototal)
by year month, sort: egen inst2 = total(inst1) if insolacaototal~=.
by year month, sort: egen insolacao = mean(inst2)

label variable insolacao "insolação por municipio"

drop teste2 inst1 inst2 peso_novo

//QUANTIDADE DE DIAS DE CHUVA
by year month, sort: egen teste2 = total(estacao_maneira4) if  numdiasprecipitacao~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*numdiasprecipitacao)
by year month, sort: egen inst2 = total(inst1) if numdiasprecipitacao~=.
by year month, sort: egen diasdechuva = mean(inst2)

label variable diasdechuva "dias de chuva por municipio"

drop teste2 inst1 inst2 peso_novo

//TEMPERATURA MEDIA
by year month, sort: egen teste2 = total(estacao_maneira4) if  tempcompensadamedia~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*tempcompensadamedia)
by year month, sort: egen inst2 = total(inst1) if tempcompensadamedia~=.
by year month, sort: egen temperatura_media = mean(inst2)

label variable temperatura_media "temperatura media por municipio"

drop teste2 inst1 inst2 peso_novo

//TEMPERATURA maxima
by year month, sort: egen teste2 = total(estacao_maneira4) if  tempmaximamedia~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*tempmaximamedia)
by year month, sort: egen inst2 = total(inst1) if tempmaximamedia~=.
by year month, sort: egen temperatura_max = mean(inst2)

label variable temperatura_max "temperatura maxima por municipio"

drop teste2 inst1 inst2 peso_novo

//TEMPERATURA minima
by year month, sort: egen teste2 = total(estacao_maneira4) if  tempminimamedia~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*tempminimamedia)
by year month, sort: egen inst2 = total(inst1) if tempminimamedia~=.
by year month, sort: egen temperatura_min = mean(inst2)


label variable temperatura_min "temperatura minima por municipio"

drop teste2 inst1 inst2 peso_novo

//UMIDADE RELATIVA DO AR
by year month, sort: egen teste2 = total(estacao_maneira4) if  umidaderelativamedia~=.
gen peso_novo = estacao_maneira4/teste2
by year month, sort:  gen inst1 = (peso_novo*umidaderelativamedia)
by year month, sort: egen inst2 = total(inst1) if umidaderelativamedia~=.
by year month, sort: egen umidade = mean(inst2)

label variable umidade "umidade relativar do ar por municipio"

drop teste2 inst1 inst2 peso_novo

keep cod_mun  year month  chuva evaporacao evapotranspiracao nebulosidade insolacao diasdechuva temperatura_media temperatura_max temperatura_min umidade
 
by cod_mun year month, sort: drop if _n>1
