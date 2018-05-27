#!/bin/bash
#########################################################
# written by George Liu (eva2000) https://centminmod.com
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")


#########################################################
# functions
#############

mysql_cmd() {
  mysqlclient=$1
  mysqlarga=$2
  mysqlargb=$3
  mysqlargc=$4
  mysqlargd=$5
  if [[ "$mysqlclient" = 'show-engines' ]]; then
    echo "${MYSQLEIGHT_BINDIR}mysql -P $PORT -S $SOCKET -e \"SHOW ENGINES;\""
    ${MYSQLEIGHT_BINDIR}mysql -P $PORT -S $SOCKET -e "SHOW ENGINES;"
  else
    echo "${MYSQLEIGHT_BINDIR}${mysqlclient} -P $PORT -S $SOCKET $mysqlarga $mysqlargb $mysqlargc $mysqlargd"
    ${MYSQLEIGHT_BINDIR}${mysqlclient} -P $PORT -S $SOCKET $mysqlarga $mysqlargb $mysqlargc $mysqlargd
  fi
}

#########################################################
case $1 in
  1 )
MYSQLEIGHT_BINDIR=""
PORT='3306'
SOCKET='/var/lib/mysql/mysql.sock'
mysql_cmd $2 $3 $4 $5 $6
    ;;
  2 )
MYSQLEIGHT_BINDIR=""
PORT='3307'
SOCKET='/var/lib/mysql2/mysql.sock'
mysql_cmd $2 $3 $4 $5 $6
    ;;
  3 )
MYSQLEIGHT_BINDIR=""
PORT='3308'
SOCKET='/var/lib/mysql3/mysql.sock'
mysql_cmd $2 $3 $4 $5 $6
    ;;
  8 )
MYSQLEIGHT_BINDIR='/usr/local/mysql/bin/'
PORT='3407'
SOCKET='/opt/mysql/data/mysql.sock'
mysql_cmd $2 $3 $4 $5 $6
    ;;
  pattern )
    ;;
  * )
    echo
    echo "Usage:"
    echo 
    echo "mysql-control 1 mysqladmin ver"
    echo "mysql-control 2 mysqladmin ver"
    echo "mysql-control 3 mysqladmin ver"
    echo "mysql-control 8 mysqladmin ver"
    echo 
    echo "mysql-control 1 show-engines"
    echo "mysql-control 2 show-engines"
    echo "mysql-control 3 show-engines"
    echo "mysql-control 8 show-engines"
    echo
    ;;
esac
exit
