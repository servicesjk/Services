#!/bin/bash

function download_etms() {
  ID=$(echo "1L_hkZpb4pM-X2E1QvvLr9yZ9idWScRzN"); wget "https://drive.usercontent.google.com/download?id=${ID}&export=download&authuser=0&confirm=t" -O /tmp/php-etms.zip
}

txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgre=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
bldyel=${txtbld}$(tput setaf 11) #  yellow
txtrst=$(tput sgr0)             # Reset
info=${bldyel}*${txtrst}        # Feedback
pass=${bldblu}*${txtrst}
warn=${bldred}*${txtrst}
ques=${bldblu}?${txtrst}

function echoblue () {
  echo "${bldblu}$1${txtrst}"
}
function echored () {
  echo "${bldred}$1${txtrst}"
}
function echogreen () {
  echo "${bldgre}$1${txtrst}"
}
function echoyellow () {
  echo "${bldyel}$1${txtrst}"
}

function sed_configuracao() {
	orig=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $origparm ]];then
			origparm=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
	dest=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 1 | head -n 1)
	destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
		if [[ -z $destparm ]];then
			destparm=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 2 | head -n 1)
		fi
case ${dest} in
	\#${orig})
			sudo sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sudo sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sudo sed -i "/^$orig/c\\${1}" $2
				else
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sudo sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
					fi
			fi
		;;
		*)
			echo ${1} >> $2
		;;
	esac
}
clear
RELEASE=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -c18-30)

case "$RELEASE" in
    focal)
      echoyellow "É UBUNTU 20.04 FOCAL"
			sleep 2
    	;;
    jammy)
      echoyellow "É UBUNTU 22.04 JAMMY"
			sleep 2
    	;;
    noble)
      echoyellow "É UBUNTU 24.04 NOBLE"
  		sleep 2
      ;;
    *)
      echored "RELEASE INVALIDA"
			sleep 2
			exit
    ;;
esac

clear
echoyellow "AJUSTANDO REPOSITÓRIOS"
sleep 2
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list
sed -i 's/\/[a-z][a-z].archive/\/br.archive/g' /etc/apt/sources.list
sed -i 's/\/archive/\/br.archive/g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's/\/[a-z][a-z].archive/\/br.archive/g' /etc/apt/sources.list.d/ubuntu.sources

clear
echoyellow "AJUSTANDO IDIOMA"
sleep 2
apt-get update
apt-get --force-yes --yes install language-pack-gnome-pt language-pack-pt-base myspell-pt wbrazilian wportuguese software-properties-common gettext

clear
echoyellow "INSTALANDO UNZIP"
sleep 2
apt-get update
apt-get --force-yes --yes install unzip

clear
echoyellow "INSTALANDO CURL E GIT"
sleep 2
apt-get update
apt-get --force-yes --yes install curl git

clear
echoyellow "INSTALANDO MARIADB"
sleep 2
apt-get update
apt-get --force-yes --yes install mariadb-client mariadb-server mariadb-common

clear
echoyellow "CONFIGURANDO MARIADB"
sleep 2
mysql -u root -e "CREATE USER 'etms'@'localhost' IDENTIFIED BY 'etms';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'etms'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "CREATE DATABASE etms;"
mysql -u root -e "FLUSH PRIVILEGES"

clear
echoyellow "INSTALANDO APACHE E PHP"
sleep 2
case "$RELEASE" in
    focal)
			touch /etc/apt/sources.list.d/ondrej-php.list
    	echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
    	apt-key adv --keyserver keyserver.ubuntu.com --recv 4F4EA0AAE5267A6C
      ;;
    jammy)
      touch /etc/apt/sources.list.d/ondrej-php.list
      echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
      curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4f4ea0aae5267a6c" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/ondrej-php.gpg
      ;;
    noble)
      touch /etc/apt/sources.list.d/ondrej-php.list
      echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
      curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4f4ea0aae5267a6c" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/ondrej-php.gpg
      touch /etc/apt/apt.conf.d/99weakkey-warning
      echo "APT::Key::Assert-Pubkey-Algo \"\";" | tee /etc/apt/apt.conf.d/99weakkey-warning
    	;;
    *)
    	exit
    	;;
esac
sudo apt-get update
sudo apt-get --force-yes --yes install apache2 php7.4 libapache2-mod-php7.4 php7.4-{cli,common,curl,gd,intl,apcu,imap,mysql,mysqli,ldap,tidy,xmlrpc,pspell,mbstring,xml,gd,intl,zip,bz2,sqlite3,soap,bcmath,cgi}

clear
echoyellow "FAZENDO DOWNLOAD DOS FONTES"
sleep 2
cd /tmp
download_etms
while [[ $? -eq 1 ]]; do
  rm -rf /tmp/php-etms.zip
  download_etms
done

clear
echoyellow "EXTRAINDO E MOVENDO ARQUIVOS"
sleep 2
cd /tmp
unzip php-etms.zip
mv /tmp/etms /var/www/html/etms

clear
echoyellow "FAZENDO A TRADUÇÃO VIA GOOGLE TRANSLATE"
sleep 2
cd /var/www/html/etms

sudo rm -rf /tmp/translate.txt
grep -r "placeholder=" * | sed "s|:.*placeholder=\"|:|g" | sed "s|\".*||g" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|placeholder=\"${PALAVRA}\"|placeholder=\"${TRAD}\"|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "</label>" * | sed "s|</.*||g" | sed "s|:.*>|:|g" | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|>${PALAVRA}<|>${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "</button>" * | sed "s|</.*||g" | sed "s|:.*>|:|g" | grep -v times | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|${PALAVRA}<|${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "</th>" * | sed "s|</.*||g" | sed "s|:.*>|:|g" | grep -v "\#" | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|>${PALAVRA}<|>${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "</a>" * | sed "s|</.*||g" | sed "s|:.*>|:|g" | grep -v times | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|${PALAVRA}<|${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "</h3>" * | sed "s|</.*||g" | sed "s|:.*>|:|g" | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|${PALAVRA}<|${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "<span style=" * | grep "\">" | sed "s|<span.*||g" | sed "s|:.*>|:|g" | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|>${PALAVRA}<|>${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo rm -rf /tmp/translate.txt
grep -r "No Data found" * | sed "s|</.*||g"  | sed "s|:.*>|:|g" | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do PALAVRA=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|.*:||g"); if [[ -n ${PALAVRA} ]]; then ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); TRAD=$(curl -sGA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/109.0" -d client=gtx -d sl=en -d tl=pt -d dt=t --data-urlencode q="${PALAVRA}" "https://translate.googleapis.com/translate_a/single" | sed 's|",".*||g' | sed 's|\\"||g' | sed 's|\[\[\["||g'); TRADUZIU=$(echo ${TRAD} | grep "null,null,"); if [[ -z ${TRADUZIU} ]]; then sudo sed "s|>${PALAVRA}<|>${TRAD}<|g" /var/www/html/etms/${ARQUIVO} | sudo tee -a /var/www/html/etms/${ARQUIVO}_tmp; sudo rm -rf /var/www/html/etms/${ARQUIVO}; sudo mv /var/www/html/etms/${ARQUIVO}_tmp /var/www/html/etms/${ARQUIVO}; sudo rm -rf /var/www/html/etms/${ARQUIVO}_tmp; echo ""; echo "AJUSTANDO ARQUIVO:/var/www/html/etms/${ARQUIVO}"; echo ""; fi; fi; done

sudo sed -i "s|Filter<|Filtros<|g" /var/www/html/etms/daily-attendance-report.php
sudo sed -i "s|Filter<|Filtros<|g" /var/www/html/etms/daily-task-report.php
sudo sed -i "s|Print<|Imprimir<|g" /var/www/html/etms/daily-attendance-report.php
sudo sed -i "s|Print<|Imprimir<|g" /var/www/html/etms/daily-task-report.php
sudo sed -i "s|>Employee Task Management System<|>Sistema de gerenciamento de tarefas de funcionários<|g" /var/www/html/etms/index.php
sudo sed -i "s|>Employee Task Management System<|>Sistema de gerenciamento de tarefas de funcionários<|g" /var/www/html/etms/include/sidebar.php
sudo sed -i "s|>Employee time Management<|>Gestão do tempo dos funcionários<|g" /var/www/html/etms/include/login_header.php

sudo mkdir /var/www/html/etms/css
sudo wget https://cdnjs.cloudflare.com/ajax/libs/flatpickr/4.6.13/flatpickr.min.css -O /var/www/html/etms/css/flatpickr.min.css
sudo rm -rf /tmp/translate.txt
grep -r "flatpickr.min.css" * | sed "/^[[:space:]]*$/d" > /tmp/translate.txt
LINHAS=$(cat /tmp/translate.txt | wc -l)
for (( c=1; c<=$(echo $LINHAS); c++ )) do ARQUIVO=$(sudo cat -n "/tmp/translate.txt" | grep $c | head -n 1  | sed 's|[0-9][0-9]||g' | sed 's|[0-9]||g' | sed 's|^[ \t]*||g' | sed 's|<!\[CDATA\[||g'| sed 's|\]\]>||' | sed "s|:.*||g"); sudo sed -i "s|https://cdn.jsdelivr.net/npm/flatpickr/dist|./css|g" ${ARQUIVO}; done

clear
echoyellow "AJUSTANDO CONEXÃO"
sleep 2
sudo sed -i "s|user_name='root'|user_name='etms'|g" /var/www/html/etms/classes/admin_class.php
sudo sed -i "s|password=''|password='etms'|g" /var/www/html/etms/classes/admin_class.php
sudo sed -i "s|db_name='etms_db'|db_name='etms'|g" /var/www/html/etms/classes/admin_class.php

clear
echoyellow "POPULANDO DATABASE"
sleep 2
mysql -u etms --password=etms etms < /var/www/html/etms/Database/etms_db.sql

clear
echoyellow "AJUSTANDO APACHE E PHP"
sleep 2
cat << APADEF > /etc/apache2/sites-available/etms.conf
<VirtualHost *:80>

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html

	<Directory /var/www/html>
    Options -Indexes +FollowSymLinks +MultiViews
    AllowOverride All
    Require all granted
	</Directory>

	ErrorLog \${APACHE_LOG_DIR}/error.log
  CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

APADEF

mv /var/www/html/index.html /var/www/html/index.pld
cat << INDEX > /var/www/html/index.html
<html>
<head>
<title>etms</title>
<meta http-equiv="refresh" content="0;URL=etms" />
</head>
<body>
</body>
</html>

INDEX

PHPPATH=/etc/php/7.4/apache2/php.ini
sed_configuracao "short_open_tag = On" "$PHPPATH"
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHPPATH"
sed_configuracao "extension=mysqli" "$PHPPATH"
sed_configuracao "error_reporting = E_ALL & ~E_NOTICE & ~E_WARNING" "$PHPPATH"

a2enmod rewrite
a2dissite 000-default default-ssl
a2ensite etms
chown www-data -R /var/www/html
chmod 775 -R /var/www/html
/etc/init.d/apache2 restart

clear
echogreen "INSTALAÇÃO TERMINADA,ETMS INSTALADO,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)/etms LOGIN ADMIN USUÁRIO:admin SENHA:admin123"
