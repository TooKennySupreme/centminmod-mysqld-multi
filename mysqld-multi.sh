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

  # check mysqld2 server instance version
  echo "mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock"
  mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock
}

#########################################################
case $1 in
  install )
    mysqld_multisetup
    ;;
  pattern )
    ;;
  pattern )
    ;;
  pattern )
    ;;
  pattern )
    ;;
  * )
    ;;
esac
exit
