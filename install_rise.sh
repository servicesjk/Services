#!/bin/bash

function download_rise() {
#URL DO ARQUIVO
    ARQ="rise.zip"
    ID=$(echo "1Mjpa7a-IqmZLp8fg4E9DUn_uhPmpRKXq"); wget "https://drive.usercontent.google.com/download?id=${ID}&export=download&authuser=0&confirm=t" -O ${ARQ}
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
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	\;${orig})
			sed -i "/^$dest.*$destparm/c\\${1}" $2
		;;
	${orig})
			if [[ $origparm != $destparm ]]; then
				sed -i "/^$orig/c\\${1}" $2
				else
					if [[ -z $(grep '[A-Z\_A-ZA-Z]$origparm' $2) ]]; then
						fullorigparm3=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fullorigparm4=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fullorigparm5=$(echo $1 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						fulldestparm3=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 3 | head -n 1)
						fulldestparm4=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 4 | head -n 1)
						fulldestparm5=$(grep -E "^(#|\;|)$orig" $2 | tr -s ' ' '|' | cut -d '|' -f 5 | head -n 1)
						sed -i "/^$dest.*$fulldestparm3\ $fulldestparm4\ $fulldestparm5/c\\$orig\ \=\ $fullorigparm3\ $fullorigparm4\ $fullorigparm5" $2
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
echoyellow "INSTALANDO MYSQL"
sleep 2
apt-get update
apt-get --force-yes --yes install mysql-server mysql-client

clear
echoyellow "CONFIGURANDO MYSQL"
sleep 2
mysql -u root -e "CREATE USER 'rise'@'localhost' IDENTIFIED BY 'rise';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'rise'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "CREATE DATABASE rise;"
mysql -u root -e "FLUSH PRIVILEGES"

clear
echoyellow "INSTALANDO PHP E APACHE"
sleep 2
case "$RELEASE" in
    focal)
			touch /etc/apt/sources.list.d/ondrej-php.list
    	echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
    	apt-key adv --keyserver keyserver.ubuntu.com --recv 4F4EA0AAE5267A6C
      sudo apt-get update
      sudo apt-get --force-yes --yes install apache2 php8.1 libapache2-mod-php8.1 php8.1-{cli,common,curl,gd,intl,apcu,memcache,imap,mysql,mysqli,ldap,tidy,xmlrpc,pspell,mbstring,xml,gd,intl,zip,bz2,sqlite3,soap,bcmath,cgi}
    	;;
    jammy)
      touch /etc/apt/sources.list.d/ondrej-php.list
      echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
      curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4f4ea0aae5267a6c" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/ondrej-php.gpg
      sudo apt-get update
      sudo apt-get --force-yes --yes install apache2 php8.1 libapache2-mod-php8.1 php8.1-{cli,common,curl,gd,intl,apcu,memcache,imap,mysql,mysqli,ldap,tidy,xmlrpc,pspell,mbstring,xml,gd,intl,zip,bz2,sqlite3,soap,bcmath,cgi}
      ;;
    noble)
      touch /etc/apt/sources.list.d/ondrej-php.list
      echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${RELEASE} main" | tee /etc/apt/sources.list.d/ondrej-php.list
      curl "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x4f4ea0aae5267a6c" | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/ondrej-php.gpg
      touch /etc/apt/apt.conf.d/99weakkey-warning
      echo "APT::Key::Assert-Pubkey-Algo \"\";" | tee /etc/apt/apt.conf.d/99weakkey-warning
      sudo apt-get update
      sudo apt-get --force-yes --yes install apache2 php8.1 libapache2-mod-php8.1 php8.1-{cli,common,curl,gd,intl,apcu,memcache,imap,mysql,mysqli,ldap,tidy,xmlrpc,pspell,mbstring,xml,gd,intl,zip,bz2,sqlite3,soap,bcmath,cgi}
    	;;
    *)
    	exit
    	;;
esac

clear
echoyellow "CONFIGURANDO PHP"
sleep 2
PHPPATH=/etc/php/8.1/apache2/php.ini
sed_configuracao 'date.timezone = "America/Sao_Paulo"' "$PHPPATH"

clear
echoyellow "FAZENDO DOWNLOAD DOS FONTES"
sleep 2
cd /tmp
download_rise
while [[ $? -eq 1 ]]; do
  rm ${ARQ}
  download_rise
done

clear
echoyellow "EXTRAINDO E MOVENDO PACOTE"
sleep 2
cd /tmp
unzip rise.zip
mv /tmp/rise /var/www/html/rise

clear
echoyellow "AJUSTANDO APACHE"
sleep 2
cat << APADEF > /etc/apache2/sites-available/rise.conf
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

mv /var/www/html/index.html /var/www/html/index.html.old
cat << INDEX > /var/www/html/index.html
<html>
<head>
<title>RISE</title>
<meta http-equiv="refresh" content="0;URL=rise" />
</head>
<body>
</body>
</html>

INDEX

sudo a2enmod rewrite
sudo a2dissite 000-default
sudo chown www-data -R /var/www/html
sudo chmod 775 -R /var/www/html
sudo a2ensite rise
sudo /etc/init.d/apache2 restart

clear
echogreen "INSTALAÇÃO TERMINADA,RISE INSTALADO,ACESSE ATRAVÉS DE SEU NAVEGADOR WEB EM http://$(ip addr show | grep 'inet ' | grep brd | tr -s ' ' '|' | cut -d '|' -f 3 | cut -d '/' -f 1 | head -n 1)/rise E FINALIZE A ISTALAÇÃO,ONDE JÁ FOI CRIADO UM BASE MYSQL HOST:localhost PORTA:3306 DATABASE:rise USUÁRIO:rise SENHA:rise"
