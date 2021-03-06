#!/bin/bash
fun_trans () { 
local texto
local retorno
declare -A texto
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z $(echo ${texto[$2]}) ]]; then
ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
  while [[ -z $retorno ]]; do
    NUM="$(($RANDOM%${#ENGINES[@]}))"
    retorno="$(source trans -e ${ENGINES[$NUM]} -b pt:$1 "$2"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
  done
 echo "texto[$2]='$retorno'"  >> /etc/texto-adm
 echo "$retorno"
else
 echo "${texto[$2]}"
fi
}
declare -A cor=( [0]="\033[33m" [1]="\033[33m" [2]="\033[33m" [3]="\033[33m" [4]="\033[33m" )
barra="\e[33m======================================================\033[1;37m"
[[ -z $1 ]] && exit || id=$1
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
API_TRANS="aHR0cHM6Ly93d3cuZHJvcGJveC5jb20vcy9sNmlxZjV4anRqbXBkeDUvdHJhbnM/ZGw9MA=="
SUB_DOM='base64 -d'
wget -O /usr/bin/trans $(echo $API_TRANS|$SUB_DOM) &> /dev/null
#LISTA PORTAS
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
fun_squid  () {
  if [[ -e /etc/squid/squid.conf ]]; then
  var_squid="/etc/squid/squid.conf"
  elif [[ -e /etc/squid3/squid.conf ]]; then
  var_squid="/etc/squid3/squid.conf"
  fi
  [[ -e $var_squid ]] && {
  msg -ama " $(fun_trans "REMOVIENDO SQUID")"
  msg -bar
  service squid stop > /dev/null 2>&1
  fun_bar "apt-get remove squid3 -y"
  msg -ama " $(fun_trans "Procedimiento completado")"
  msg -bar
  [[ -e $var_squid ]] && rm $var_squid
  return 0
  }
}
install_squid () {
msg -ama  " $(fun_trans "INSTALADOR SQUID ADM-ULTIMATE")"
msg -bar
fun_ip
msg -ne " $(fun_trans "Confirme su IP")"; read -p ": " -e -i $IP ip
msg -ama " $(fun_trans "Ahora elige las Puertas que desea en el Squid")"
msg -ama " $(fun_trans "Seleccione las puertas en orden secuencial de ejemplo: 80 8080 8799 3128")"
msg -ne " $(fun_trans "Introduzca los puertos:") "; read portasx
totalporta=($portasx)
unset PORT
   for portx in $(echo $portasx); do
        [[ $(mportas|grep "${portx}") = "" ]] && {
        msg -ama " $(fun_trans "Puerta Elegida:")\033[1;32m ${portx} OK"
        PORT+="${portx}\n"
        } || {
        msg -ama " $(fun_trans "Puerta Elegida:")\033[1;31m ${portx} FALLO"
        }
   done
  [[ -z $PORT ]] && {
  msg -verm " $(fun_trans "No se ha elegido ninguna puerta valida")\033[0m"
  return 1
  }
msg -bar
msg -ama  " $(fun_trans "INSTALACION SQUID")"
msg -bar
fun_bar "apt-get install squid3 -y"
msg -bar
msg -ama  " $(fun_trans "INICIANDO CONFIGURACION")"
msg -bar
echo -e ".bookclaro.com.br/\n.claro.com.ar/\n.claro.com.br/\n.claro.com.co/\n.claro.com.ec/\n.claro.com.gt/\n.cloudfront.net/\n.claro.com.ni/\n.claro.com.pe/\n.claro.com.sv/\n.claro.cr/\n.clarocurtas.com.br/\n.claroideas.com/\n.claroideias.com.br/\n.claromusica.com/\n.clarosomdechamada.com.br/\n.clarovideo.com/\n.facebook.net/\n.facebook.com/\n.netclaro.com.br/\n.oi.com.br/\n.oimusica.com.br/\n.speedtest.net/\n.tim.com.br/\n.timanamaria.com.br/\n.vivo.com.br/\n.rdio.com/\n.compute-1.amazonaws.com/\n.portalrecarga.vivo.com.br/\n.vivo.ddivulga.com/" > /etc/payloads
msg -ama " $(fun_trans "Ahora Escoja Una Configuracion Para Su Proxy")"
msg -bar
msg -ama  "|1| $(fun_trans "Comum")"
msg -ama  "|2| $(fun_trans "Customizado") -\033[1;31m $(fun_trans "Usuario Debe Ajustar")\033[1;37m"
msg -bar
read -p "[1/2]: " -e -i 1 proxy_opt
tput cuu1 && tput dl1
if [[ $proxy_opt = 1 ]]; then
msg -ama  " $(fun_trans "INSTALACION SQUID COMUN")"
elif [[ $proxy_opt = 1 ]]; then
msg -ama " $(fun_trans "INSTALACION SQUID CUSTOMIZADO")"
else
msg -ama " $(fun_trans "INSTALACION SQUID COMUM")"
proxy_opt=1
fi
unset var_squid
if [[ -d /etc/squid ]]; then
var_squid="/etc/squid/squid.conf"
elif [[ -d /etc/squid3 ]]; then
var_squid="/etc/squid3/squid.conf"
fi
if [[ "$proxy_opt" = @(02|2) ]]; then
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 url_regex -i '/etc/opendns'
acl url5 dstdomain -i localhost
acl accept dstdomain -i GET
acl accept dstdomain -i POST
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i CONNECT
acl accept dstdomain -i PUT
acl HEAD dstdomain -i HEAD
acl accept dstdomain -i TRACE
acl accept dstdomain -i OPTIONS
acl accept dstdomain -i PATCH
acl accept dstdomain -i PROPATCH
acl accept dstdomain -i DELETE
acl accept dstdomain -i REQUEST
acl accept dstdomain -i METHOD
acl accept dstdomain -i NETDATA
acl accept dstdomain -i MOVE
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow url5
http_access allow accept
http_access allow HEAD
http_access deny all

# Request Headers Forcing

request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
#request_header_access All deny all

# Response Headers Spoofing

#reply_header_access Via deny all
#reply_header_access X-Cache deny all
#reply_header_access X-Cache-Lookup deny all

#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-MANAGER

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
 else
echo -e "#ConfiguracaoSquiD
acl url1 dstdomain -i $ip
acl url2 dstdomain -i 127.0.0.1
acl url3 url_regex -i '/etc/payloads'
acl url4 url_regex -i '/etc/opendns'
acl url5 dstdomain -i localhost
acl all src 0.0.0.0/0
http_access allow url1
http_access allow url2
http_access allow url3
http_access allow url4
http_access allow url5
http_access deny all

#portas" > $var_squid
for pts in $(echo -e $PORT); do
echo -e "http_port $pts" >> $var_squid
done
echo -e "
#nome
visible_hostname ADM-MANAGER

via off
forwarded_for off
pipeline_prefetch off" >> $var_squid
fi
touch /etc/opendns
fun_eth
msg -ne " \033[1;31m [ ! ] \033[1;33m$(fun_trans "REINICIANDO SERVICIOS")"
squid3 -k reconfigure > /dev/null 2>&1
service ssh restart > /dev/null 2>&1
service squid3 restart > /dev/null 2>&1
echo -e " \033[1;32m[OK]"
msg -bar && msg -ama " $(fun_trans "SQUID CONFIGURADO")" && msg -bar
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}
online_squid () {
payload="/etc/payloads"
msg -azu " $(fun_trans "SQUID CONFIGURADO")"
msg -bar
echo -ne "\033[1;32m [1] > " && msg -azu "$(fun_trans "Colocar Host en Squid")"
echo -ne "\033[1;32m [2] > " && msg -azu "$(fun_trans "Quitar el host de Squid")"
echo -ne "\033[1;32m [3] > " && msg -azu "$(fun_trans "Desinstalar Squid")"
echo -ne "\033[1;32m [0] > " && msg -bra "$(fun_trans "Volver")"
msg -bar
while [[ $varpay != @(0|[1-3]) ]]; do
read -p "[0/3]: " varpay
tput cuu1 && tput dl1
done
if [[ "$varpay" = "0" ]]; then
return 1
elif [[ "$varpay" = "1" ]]; then
msg -ama " $(fun_trans "Hosts Actuales Dentro del Squid")"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
while [[ $hos != \.* ]]; do
msg -ne " $(fun_trans "Escriba el nuevo host"): " && read hos
tput cuu1 && tput dl1
[[ $hos = \.* ]] && continue
msg -ama " $(fun_trans "Comience con") .${cor[0]}"
sleep 2s
tput cuu1 && tput dl1
done
host="$hos/"
[[ -z $host ]] && return 1
[[ `grep -c "^$host" $payload` -eq 1 ]] &&:echo -e "${cor[4]}$(fun_trans "Host Ya Existe")${cor[0]}" && return 1
echo "$host" >> $payload && grep -v "^$" $payload > /tmp/a && mv /tmp/a $payload
msg -ama "$(fun_trans "Host agregado con exito")"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload
service squid3 restart
else
/etc/init.d/squid reload
service squid restart
fi	
return 0
elif [[ "$varpay" = "2" ]]; then
echo -e "${cor[4]} $(fun_trans "Hosts Actuales Dentro del Squid")"
msg -bar 
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
while [[ $hos != \.* ]]; do
echo -ne "${cor[4]}$(fun_trans "Introduzca el host"): " && read hos
tput cuu1 && tput dl1
[[ $hos = \.* ]] && continue
echo -e "${cor[4]}$(fun_trans "Comience con") .${cor[0]}"
sleep 2s
tput cuu1 && tput dl1
done
host="$hos/"
[[ -z $host ]] && return 1
[[ `grep -c "^$host" $payload` -ne 1 ]] &&!msg -ama "$(fun_trans "Host no encontrado")" && return 1
grep -v "^$host" $payload > /tmp/a && mv /tmp/a $payload
msg -ama " $(fun_trans "Host Removido Con exito")${cor[0]}"
msg -bar
cat $payload | awk -F "/" '{print $1,$2,$3,$4}'
msg -bar
if [[ ! -f "/etc/init.d/squid" ]]; then
service squid3 reload
service squid3 restart
else
/etc/init.d/squid reload
service squid restart
fi	
return 0
elif [[ "$varpay" = "3" ]]; then
fun_squid
fi
}
if [[ -e /etc/squid/squid.conf ]]; then
online_squid
elif [[ -e /etc/squid3/squid.conf ]]; then
online_squid
else
fun_squid
fi