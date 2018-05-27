#!/bin/bash
#########################################################
# mariadb mysqld_multi setup for centminmod.com
# # written by George Liu (eva2000) https://centminmod.com
# https://mariadb.com/kb/en/library/mysqld_multi/
# https://dev.mysql.com/doc/refman/5.6/en/mysqld-multi.html
# https://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html
# https://www.percona.com/blog/2014/08/26/mysqld_multi-how-to-run-multiple-instances-of-mysql/
#########################################################
# variables
#############
DT=$(date +"%d%m%y-%H%M%S")
VER='0.1'

#########################################################
# functions
#############

mysqld_multisetup() {
  # assign multi_admin user/pass
  user='multi_admin1'
  pass='password1'
  echo "GRANT SHUTDOWN ON *.* TO $user@localhost IDENTIFIED BY '$pass'" | mysql
  mysql -e "SHOW GRANTS for $user@localhost;"

  # create /etc/my.cnf with mysqld_multi configuration
  echo
  mysqld_multi --example | grep -v '#' | head -n12 | sed -e "s|hostname|$(hostname)|" > /etc/my-multi.cnf
  sed -i "s|multi_admin|$user|" /etc/my-multi.cnf
  sed -i "s|my_password|$pass|" /etc/my-multi.cnf

  # create mysqld2 configuration tmpdir
  mkdir -p /home/mysqltmp2
  chmod 1777 /home/mysqltmp2

  # create mysqld2 default config
  echo >> /etc/my-multi.cnf
  cat /etc/my.cnf | sed -n '/\[mysqld\]/,/\# mariadb settings/{/\# mariadb settings/!p}' | sed -e 's|\/var\/lib\/mysql|\/var\/lib\/mysql2|g' -e 's|\/home\/mysqltmp|\/home\/mysqltmp2|g' -e '/\[mysqld\]/d' >> /etc/my-multi.cnf
  cat /etc/my.cnf >> /etc/my-multi.cnf
  # remove unneeded settings
  grep -nC3 'socket=\/var\/lib\/mysql\/mysql.sock' /etc/my-multi.cnf
  sed -i 's|\[client\]||' /etc/my-multi.cnf
  sed -i '/socket=\/var\/lib\/mysql\/mysql.sock/d' /etc/my-multi.cnf
  sed -i 's|\/tmp\/mysql.sock2|\/var\/lib\/mysql2\/mysql2.sock|' /etc/my-multi.cnf
  sed -i '/\/var\/lib\/mysql2\/mysql2.sock/d' /etc/my-multi.cnf

  # check mysqld_multi my.cnf before moving to /etc/my.cnf
  echo
  cat /etc/my-multi.cnf

  # create mysqld2 system databases/directory config
  echo
  echo "mysql_install_db --user=mysql --datadir=/var/lib/mysql2"
  mysql_install_db --user=mysql --datadir=/var/lib/mysql2

  # check mysqld and mysqld2 defaults
  echo "my_print_defaults --defaults-file=/etc/my-multi.cnf mysqld"
  my_print_defaults --defaults-file=/etc/my-multi.cnf mysqld
  echo "my_print_defaults --defaults-file=/etc/my-multi.cnf mysqld2"
  my_print_defaults --defaults-file=/etc/my-multi.cnf mysqld2

  # backup existing /etc/my.cnf and move mysqld_multi config to /etc/my.cnf
  \cp -f /etc/my.cnf /etc/my.cnf-premulti
  \cp -f /etc/my-multi.cnf /etc/my.cnf

  # restart mysqld default mysql server
  mysqlrestart

  # start mysqld2 server
  mysqld_multi start 2
  mysqld_multi report 2

  # check mysqld and mysqld2 defaults
  echo "my_print_defaults --defaults-file=/etc/my.cnf mysqld"
  my_print_defaults --defaults-file=/etc/my.cnf mysqld
  echo "my_print_defaults --defaults-file=/etc/my.cnf mysqld2"
  my_print_defaults --defaults-file=/etc/my.cnf mysqld2

  # check mysql version for default mysqld
  echo "mysqladmin ver"
  mysqladmin ver

  # setup root mysql password for mysqld2 2nd instance to be
  # same as mysqld default instance mysql root password
  THEMYSQLPASS=$(awk -F '=' '/password/ {print $2}' /root/.my.cnf)
  echo $THEMYSQLPASS
  # temp move /root/.ny.cnf to allow mysqld2 server to assign the root
  # user password
  mv /root/.my.cnf /root/.my.cnf-tempmv
  echo "mysql -P 3307 -S /var/lib/mysql2/mysql.sock -e \"UPDATE mysql.user SET Password = PASSWORD('$THEMYSQLPASS') WHERE User = 'root'; FLUSH PRIVILEGES;\""
  mysql -P 3307 -S /var/lib/mysql2/mysql.sock -e "UPDATE mysql.user SET Password = PASSWORD('$THEMYSQLPASS') WHERE User = 'root'; FLUSH PRIVILEGES;"
  mv /root/.my.cnf-tempmv /root/.my.cnf
  echo "echo \"GRANT SHUTDOWN ON *.* TO $user@localhost IDENTIFIED BY '$pass'\" | mysql -P 3307 -S /var/lib/mysql2/mysql.sock"
  echo "GRANT SHUTDOWN ON *.* TO $user@localhost IDENTIFIED BY '$pass'" | mysql -P 3307 -S /var/lib/mysql2/mysql.sock
  mysql -P 3307 -S /var/lib/mysql2/mysql.sock -e "SHOW GRANTS for $user@localhost;"

  # check mysqld2 server instance version
  echo "mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock"
  mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock

  # check mysql instances listening ports
  echo
  echo "netstat -plant | grep mysql"
  netstat -plant | grep mysql

  mysqld_multi stop 2
  mysqld_mylti report 2
}

mysql_eight() {
  cd /usr/local
  wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.11-el7-x86_64.tar.gz
  tar zxvf mysql-8.0.11-el7-x86_64.tar.gz
  ln -s /usr/local/mysql-8.0.11-el7-x86_64 mysql
  cd mysql
  mkdir mysql-files
  chown mysql:mysql mysql-files
  chmod 750 mysql-files
  rm -rf /opt/mysql; mkdir -p /opt/mysql/data; chown mysql:mysql /opt/mysql/data
  wget -O /usr/local/mysql/my.cnf https://gist.github.com/centminmod/7351768dbe6806f9db99f65cbe795615/raw/z-my.cnf
  sed -i 's|port=3307|port=3407|g' /usr/local/mysql/my.cnf
  cat /usr/local/mysql/my.cnf
  mv /etc/my.cnf /var/lib/mysql/my.cnf
  mv /root/.my.cnf /root/.my.cnf-moved
  bin/mysqld --defaults-file=/usr/local/mysql/my.cnf --initialize-insecure --user=mysql --port=3407 --basedir=/usr/local/mysql --datadir=/opt/mysql/data --default_authentication_plugin=mysql_native_password
  bin/mysql_ssl_rsa_setup --verbose --datadir=/opt/mysql/data
  \cp -fa support-files/mysql.server /etc/init.d/mysql8
  sed -i 's|^basedir=|basedir=\/usr\/local\/mysql|' /etc/init.d/mysql8
  sed -i 's|^datadir=|datadir=\/opt\/mysql\/data|' /etc/init.d/mysql8
  if [ -f /proc/user_beancounters ]; then sed -i 's/#!\/bin\/sh/#!\/bin\/sh\nif [ -f \/proc\/user_beancounters ]; then\nulimit -s 256\nfi\n/g' /etc/init.d/mysql8; fi
  service mysql8 start
  service mysql8 status
  chkconfig mysql8 on

  # bin/mysql -u root -p
  THEMYSQLPASS=$(awk -F '=' '/password/ {print $2}' /root/.my.cnf-moved)
  echo $THEMYSQLPASS
  bin/mysql -P 3407 -S /opt/mysql/data/mysql.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$THEMYSQLPASS'; FLUSH PRIVILEGES;"
  mv /root/.my.cnf-moved /root/.my.cnf
  /usr/local/mysql/bin/mysqladmin -P 3407 -S /opt/mysql/data/mysql.sock ver
  
  echo
  echo "my_print_defaults --defaults-file=/usr/local/mysql/my.cnf client"
  my_print_defaults --defaults-file=/usr/local/mysql/my.cnf client
  echo
  echo "my_print_defaults --defaults-file=/usr/local/mysql/my.cnf mysqld"
  my_print_defaults --defaults-file=/usr/local/mysql/my.cnf mysqld
  echo
  echo "my_print_defaults --defaults-file=/usr/local/mysql/my.cnf mysqld_safe"
  my_print_defaults --defaults-file=/usr/local/mysql/my.cnf mysqld_safe

  # check mysql instances listening ports
  echo
  echo "netstat -plant | grep mysql"
  netstat -plant | grep mysql

  mysqld_multi --defaults-file=/var/lib/mysql/my.cnf start 2
  mysqld_multi --defaults-file=/var/lib/mysql/my.cnf report 2

  # check mysql instances listening ports
  echo
  echo "netstat -plant | grep mysql"
  netstat -plant | grep mysql

  echo
  echo "setup mysql-control file"
  wget -O /usr/bin/mysql-control https://github.com/centminmod/centminmod-mysqld-multi/raw/master/mysql-control.sh
  chmod +x /usr/bin/mysql-control
  echo
}

#########################################################
case $1 in
  install )
    mysqld_multisetup
    ;;
  mysql8 )
    mysql_eight
    ;;
  pattern )
    ;;
  pattern )
    ;;
  pattern )
    ;;
  * )
    echo
    echo "Usage: "
    echo "$0 {insall|mysql8}"
    echo
    ;;
esac
exit
