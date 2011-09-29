#!/bin/sh

current_year=`date +"%Y"`
tmpfile=`mktemp /tmp/cmd.XXXXXX` || exit 1
wget=`which wget` || exit 1
unzip=`which unzip` || exit 1

# Gastos diretos
$wget "http://arquivos.portaldatransparencia.gov.br/PortalTransparenciaEscolheTipoDePlanilha.asp?origem=PortalComprasDiretasOEOrgaoSuperior&Exercicio=$current_year" -O $tmpfile

rm AplicacoesDiretasDespesaOrgao.csv
$unzip $tmpfile
mv -f AplicacoesDiretasDespesaOrgao.csv diretas/$current_year.csv
#rm AplicacoesDiretasDespesaOrgao.csv

# Transferencias
$wget "http://arquivos.portaldatransparencia.gov.br/PortalTransparenciaEscolheTipoDePlanilha.asp?origem=TransferenciasEstMun&Planilha=$current_year" -O $tmpfile

rm TransferenciaRecursosEstadoMunicipios$current_year.csv
$unzip $tmpfile
mv -f TransferenciaRecursosEstadoMunicipios$current_year.csv transferencia/$current_year.csv
#rm TransferenciaRecursosEstadoMunicipios$current_year.csv




