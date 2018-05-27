# Contents

* [MariaDB mysqld_multi](#mariadb-mysqld_multi---multiple-mariadb-mysql-server-setup)
* [Main MariaDB MySQL Server](#main-mariadb-mysql-server)
* [Second MariaDB MySQL Server](#second-mariadb-mysql-server)
* [Oracle MySQL 8.0](#oracle-mysql-80)
  * [Oracle MySQL 8.0.11 Details](#oracle-mysql-8011)
  * [MariaDB MySQL 10.1 main + Oracle MySQL 8.0.11](#oracle-mysql-8011--mariadb-mysql-101-main)
  * [MariaDB MySQL 10.1 second instance via mysqld_multi + Oracle MySQL 8.0.11](#oracle-mysql-8011--mariadb-mysql-101-second-instance-via-mysqld_multi)
  * [Netstat listening ports](#netstat-listening-ports)
  * [mysql-control file](#mysql-control-file)

# MariaDB mysqld_multi - multiple MariaDB MySQL server setup

Setup multiple MariaDB MySQL server instances on the same [Centmin Mod LEMP Stack](https://centminmod.com/) server. Optional Oracle MySQL 8.0.11 Server install using separate `/etc/init.d/mysql8` startup script.

* https://mariadb.com/kb/en/library/mysqld_multi/
* https://dev.mysql.com/doc/refman/5.6/en/mysqld-multi.html
* https://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html

`mysqld2` second MariaDB server instance report status

```
mysqld_multi report
Reporting MariaDB servers
MariaDB server from group: mysqld2 is running
```

# Main MariaDB MySQL Server

Default main MariaDB 10.1 MySQL server `mysqld`

```
mysqladmin ver                     
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 19 min 22 sec

Threads: 1  Questions: 3  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.002
```

```
mysql -e "SHOW ENGINES;"
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
```

```
my_print_defaults --defaults-file=/etc/my.cnf mysqld
--ignore_db_dirs=cmsetiofiotest
--local-infile=0
--ignore_db_dirs=lost+found
--character-set-server=utf8
--datadir=/var/lib/mysql
--tmpdir=/home/mysqltmp
--innodb=ON
--back_log=75
--max_connections=300
--key_buffer_size=32M
--myisam_sort_buffer_size=32M
--myisam_max_sort_file_size=2048M
--join_buffer_size=64K
--read_buffer_size=64K
--sort_buffer_size=128K
--table_definition_cache=4096
--table_open_cache=2048
--thread_cache_size=64
--wait_timeout=1800
--connect_timeout=10
--tmp_table_size=32M
--max_heap_table_size=32M
--max_allowed_packet=32M
--max_length_for_sort_data=1024
--net_buffer_length=16384
--max_connect_errors=100000
--concurrent_insert=2
--read_rnd_buffer_size=256K
--bulk_insert_buffer_size=8M
--query_cache_limit=512K
--query_cache_size=16M
--query_cache_type=1
--query_cache_min_res_unit=2K
--query_prealloc_size=262144
--query_alloc_block_size=65536
--transaction_alloc_block_size=8192
--transaction_prealloc_size=4096
--default-storage-engine=InnoDB
--log_warnings=1
--slow_query_log=0
--long_query_time=1
--slow_query_log_file=/var/lib/mysql/slowq.log
--innodb_large_prefix=1
--innodb_purge_threads=2
--innodb_file_format=Barracuda
--innodb_file_per_table=1
--innodb_open_files=1000
--innodb_data_file_path=ibdata1:10M:autoextend
--innodb_buffer_pool_size=48M
--innodb_buffer_pool_instances=1
--innodb_log_files_in_group=2
--innodb_log_file_size=128M
--innodb_log_buffer_size=8M
--innodb_flush_log_at_trx_commit=2
--innodb_lock_wait_timeout=50
--innodb_flush_method=O_DIRECT
--innodb_support_xa=1
--innodb_io_capacity=1400
--innodb_io_capacity_max=2800
--innodb_read_io_threads=2
--innodb_write_io_threads=2
--innodb_flush_neighbors=0
```

# Second MariaDB MySQL Server

Second MariaDB 10.1 MySQL server `mysqld2` instance

```
mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql2/mysql.sock
Uptime:                 19 min 7 sec

Threads: 1  Questions: 20  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.017
```

```
mysql -P 3307 -S /var/lib/mysql2/mysql.sock -e "SHOW ENGINES;"
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
```

```
my_print_defaults --defaults-file=/etc/my.cnf mysqld2
--socket=/var/lib/mysql2/mysql2.sock
--port=3307
--pid-file=/var/lib/mysql2/centos7.localdomain.pid2
--datadir=/var/lib/mysql2
--ignore_db_dirs=cmsetiofiotest
--local-infile=0
--ignore_db_dirs=lost+found
--character-set-server=utf8
--datadir=/var/lib/mysql2
--socket=/var/lib/mysql2/mysql.sock
--tmpdir=/home/mysqltmp2
--innodb=ON
--back_log=75
--max_connections=300
--key_buffer_size=32M
--myisam_sort_buffer_size=32M
--myisam_max_sort_file_size=2048M
--join_buffer_size=64K
--read_buffer_size=64K
--sort_buffer_size=128K
--table_definition_cache=4096
--table_open_cache=2048
--thread_cache_size=64
--wait_timeout=1800
--connect_timeout=10
--tmp_table_size=32M
--max_heap_table_size=32M
--max_allowed_packet=32M
--max_length_for_sort_data=1024
--net_buffer_length=16384
--max_connect_errors=100000
--concurrent_insert=2
--read_rnd_buffer_size=256K
--bulk_insert_buffer_size=8M
--query_cache_limit=512K
--query_cache_size=16M
--query_cache_type=1
--query_cache_min_res_unit=2K
--query_prealloc_size=262144
--query_alloc_block_size=65536
--transaction_alloc_block_size=8192
--transaction_prealloc_size=4096
--default-storage-engine=InnoDB
--log_warnings=1
--slow_query_log=0
--long_query_time=1
--slow_query_log_file=/var/lib/mysql2/slowq.log
--innodb_large_prefix=1
--innodb_purge_threads=2
--innodb_file_format=Barracuda
--innodb_file_per_table=1
--innodb_open_files=1000
--innodb_data_file_path=ibdata1:10M:autoextend
--innodb_buffer_pool_size=48M
--innodb_buffer_pool_instances=1
--innodb_log_files_in_group=2
--innodb_log_file_size=128M
--innodb_log_buffer_size=8M
--innodb_flush_log_at_trx_commit=2
--innodb_lock_wait_timeout=50
--innodb_flush_method=O_DIRECT
--innodb_support_xa=1
--innodb_io_capacity=1400
--innodb_io_capacity_max=2800
--innodb_read_io_threads=2
--innodb_write_io_threads=2
--innodb_flush_neighbors=0
```

# Oracle MySQL 8.0

## Oracle MySQL 8.0.11  

on port `3407` where main `/etc/my.cnf` moved to `/var/lib/mysql/my.cnf` with separate config file at `/usr/local/mysql/my.cnf`

```
mysqladmin -P 3407 -S /opt/mysql/data/mysql.sock ver
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          8.0.11
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /opt/mysql/data/mysql.sock
Uptime:                 2 min 28 sec

Threads: 2  Questions: 3  Slow queries: 0  Opens: 110  Flush tables: 2  Open tables: 86  Queries per second avg: 0.020
```

```
mysql -P 3407 -S /opt/mysql/data/mysql.sock -e "SHOW ENGINES;"
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
```

```
my_print_defaults --defaults-file=/usr/local/mysql/my.cnf client
--port=3407
--character_set_server=utf8
--basedir=/usr/local/mysql
--datadir=/opt/mysql/data
--socket=/opt/mysql/data/mysql.sock
```

```
my_print_defaults --defaults-file=/usr/local/mysql/my.cnf mysqld                     
--port=3407
--ssl=0
--local-infile=0
--character_set_server=utf8
--collation_server=utf8_general_ci
--default_authentication_plugin=mysql_native_password
--skip-character-set-client-handshake
--basedir=/usr/local/mysql
--datadir=/opt/mysql/data
--socket=/opt/mysql/data/mysql.sock
--general_log-file=/opt/mysql/data/general.log
--slow_query_log-file=/opt/mysql/data/slowq.log
--log_error=/opt/mysql/data/error.log
--innodb_undo_log_truncate=off
--innodb_doublewrite=0
```

## MariaDB MySQL 10.1 main + Oracle MySQL 8.0.11 

on port `3306` where main `/etc/my.cnf` moved to `/var/lib/mysql/my.cnf`

```
mysqladmin ver
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 3 min 55 sec

Threads: 1  Questions: 1  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.004
```

```
my_print_defaults --defaults-file=/var/lib/mysql/my.cnf mysqld
--ignore_db_dirs=cmsetiofiotest
--local-infile=0
--ignore_db_dirs=lost+found
--character-set-server=utf8
--datadir=/var/lib/mysql
--tmpdir=/home/mysqltmp
--innodb=ON
--back_log=75
--max_connections=300
--key_buffer_size=32M
--myisam_sort_buffer_size=32M
--myisam_max_sort_file_size=2048M
--join_buffer_size=64K
--read_buffer_size=64K
--sort_buffer_size=128K
--table_definition_cache=4096
--table_open_cache=2048
--thread_cache_size=64
--wait_timeout=1800
--connect_timeout=10
--tmp_table_size=32M
--max_heap_table_size=32M
--max_allowed_packet=32M
--max_length_for_sort_data=1024
--net_buffer_length=16384
--max_connect_errors=100000
--concurrent_insert=2
--read_rnd_buffer_size=256K
--bulk_insert_buffer_size=8M
--query_cache_limit=512K
--query_cache_size=16M
--query_cache_type=1
--query_cache_min_res_unit=2K
--query_prealloc_size=262144
--query_alloc_block_size=65536
--transaction_alloc_block_size=8192
--transaction_prealloc_size=4096
--default-storage-engine=InnoDB
--log_warnings=1
--slow_query_log=0
--long_query_time=1
--slow_query_log_file=/var/lib/mysql/slowq.log
--innodb_large_prefix=1
--innodb_purge_threads=2
--innodb_file_format=Barracuda
--innodb_file_per_table=1
--innodb_open_files=1000
--innodb_data_file_path=ibdata1:10M:autoextend
--innodb_buffer_pool_size=48M
--innodb_buffer_pool_instances=1
--innodb_log_files_in_group=2
--innodb_log_file_size=128M
--innodb_log_buffer_size=8M
--innodb_flush_log_at_trx_commit=2
--innodb_lock_wait_timeout=50
--innodb_flush_method=O_DIRECT
--innodb_support_xa=1
--innodb_io_capacity=1400
--innodb_io_capacity_max=2800
--innodb_read_io_threads=2
--innodb_write_io_threads=2
--innodb_flush_neighbors=0
```

## MariaDB MySQL 10.1 second instance via mysqld_multi + Oracle MySQL 8.0.11 

on port `3307` where main `/etc/my.cnf` moved to `/var/lib/mysql/my.cnf`

```
mysqld_multi --defaults-file=/var/lib/mysql/my.cnf stop 2 
```

```
mysqld_multi --defaults-file=/var/lib/mysql/my.cnf report 2
Reporting MariaDB servers
MariaDB server from group: mysqld2 is not running
```

```
mysqld_multi --defaults-file=/var/lib/mysql/my.cnf start 2
```

```
mysqld_multi --defaults-file=/var/lib/mysql/my.cnf report 2
Reporting MariaDB servers
MariaDB server from group: mysqld2 is running
```

```
mysqladmin -P 3307 ver -S /var/lib/mysql2/mysql.sock
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql2/mysql.sock
Uptime:                 6 min 12 sec

Threads: 1  Questions: 2  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.005
```

```
my_print_defaults --defaults-file=/var/lib/mysql/my.cnf mysqld2   
--socket=/var/lib/mysql2/mysql2.sock
--port=3307
--pid-file=/var/lib/mysql2/centos7.localdomain.pid2
--datadir=/var/lib/mysql2
--ignore_db_dirs=cmsetiofiotest
--local-infile=0
--ignore_db_dirs=lost+found
--character-set-server=utf8
--datadir=/var/lib/mysql2
--socket=/var/lib/mysql2/mysql.sock
--tmpdir=/home/mysqltmp2
--innodb=ON
--back_log=75
--max_connections=300
--key_buffer_size=32M
--myisam_sort_buffer_size=32M
--myisam_max_sort_file_size=2048M
--join_buffer_size=64K
--read_buffer_size=64K
--sort_buffer_size=128K
--table_definition_cache=4096
--table_open_cache=2048
--thread_cache_size=64
--wait_timeout=1800
--connect_timeout=10
--tmp_table_size=32M
--max_heap_table_size=32M
--max_allowed_packet=32M
--max_length_for_sort_data=1024
--net_buffer_length=16384
--max_connect_errors=100000
--concurrent_insert=2
--read_rnd_buffer_size=256K
--bulk_insert_buffer_size=8M
--query_cache_limit=512K
--query_cache_size=16M
--query_cache_type=1
--query_cache_min_res_unit=2K
--query_prealloc_size=262144
--query_alloc_block_size=65536
--transaction_alloc_block_size=8192
--transaction_prealloc_size=4096
--default-storage-engine=InnoDB
--log_warnings=1
--slow_query_log=0
--long_query_time=1
--slow_query_log_file=/var/lib/mysql2/slowq.log
--innodb_large_prefix=1
--innodb_purge_threads=2
--innodb_file_format=Barracuda
--innodb_file_per_table=1
--innodb_open_files=1000
--innodb_data_file_path=ibdata1:10M:autoextend
--innodb_buffer_pool_size=48M
--innodb_buffer_pool_instances=1
--innodb_log_files_in_group=2
--innodb_log_file_size=128M
--innodb_log_buffer_size=8M
--innodb_flush_log_at_trx_commit=2
--innodb_lock_wait_timeout=50
--innodb_flush_method=O_DIRECT
--innodb_support_xa=1
--innodb_io_capacity=1400
--innodb_io_capacity_max=2800
--innodb_read_io_threads=2
--innodb_write_io_threads=2
--innodb_flush_neighbors=0
```

## Netstat listening ports

* default main MariaDB 10.1 server on `3306`
* second MariaDB 10.1 via mysqld_multi config setup on `3307`
* Oracle MySQL 8.0 via `/etc/init.d/mysql8` on `3407` with MySQL X Plugin port `33060`

```
netstat -plant | grep mysql
tcp6       0      0 :::3306                 :::*                    LISTEN      7110/mysqld         
tcp6       0      0 :::3307                 :::*                    LISTEN      7019/mysqld         
tcp6       0      0 :::3407                 :::*                    LISTEN      7527/mysqld         
tcp6       0      0 :::33060                :::*                    LISTEN      7527/mysqld  
```

## mysql-control file

Custom script to manage MySQL clients for multople MariaDB 10.1 and MySQL 8.0 servers.

```
mysql-control

Usage:

mysql-control 1 mysqladmin ver
mysql-control 2 mysqladmin ver
mysql-control 3 mysqladmin ver
mysql-control 8 mysqladmin ver

mysql-control 1 show-engines
mysql-control 2 show-engines
mysql-control 3 show-engines
mysql-control 8 show-engines
```

### mysql-control Main MariaDB 10.1

```
/usr/bin/mysql-control 1 mysqladmin ver
mysqladmin -P 3306 -S /var/lib/mysql/mysql.sock ver   
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql/mysql.sock
Uptime:                 1 hour 6 min 44 sec

Threads: 1  Questions: 18  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.004
```

check MySQL server's default MySQL data directory variable value for `datadir`

```
/usr/bin/mysql-control 1 mysqladmin var | grep datadir | tr -s ' '
| datadir | /var/lib/mysql/ |
```

```
/usr/bin/mysql-control 1 show-engines
mysql -P 3306 -S /var/lib/mysql/mysql.sock -e "SHOW ENGINES;"
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
```

### mysql-control Second MariaDB 10.1

```
/usr/bin/mysql-control 2 mysqladmin ver
mysqladmin -P 3307 -S /var/lib/mysql2/mysql.sock ver   
mysqladmin  Ver 9.1 Distrib 10.1.32-MariaDB, for Linux on x86_64
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Server version          10.1.32-MariaDB
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /var/lib/mysql2/mysql.sock
Uptime:                 53 min 27 sec

Threads: 1  Questions: 5  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.001
```

check MySQL server's default MySQL data directory variable value for `datadir`

```
/usr/bin/mysql-control 2 mysqladmin var | grep datadir | tr -s ' ' 
| datadir | /var/lib/mysql2/ |
```

```
/usr/bin/mysql-control 2 show-engines
mysql -P 3307 -S /var/lib/mysql2/mysql.sock -e "SHOW ENGINES;"
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                                                          | Transactions | XA   | Savepoints |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
| CSV                | YES     | CSV storage engine                                                                               | NO           | NO   | NO         |
| MRG_MyISAM         | YES     | Collection of identical MyISAM tables                                                            | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                                                            | NO           | NO   | NO         |
| SEQUENCE           | YES     | Generated tables filled with sequential values                                                   | YES          | NO   | YES        |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables                                        | NO           | NO   | NO         |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                                                               | NO           | NO   | NO         |
| Aria               | YES     | Crash-safe tables with MyISAM heritage                                                           | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Percona-XtraDB, Supports transactions, row-level locking, foreign keys and encryption for tables | YES          | YES  | YES        |
+--------------------+---------+--------------------------------------------------------------------------------------------------+--------------+------+------------+
```

### mysql-control Oracle MySQL 8.0

```
/usr/bin/mysql-control 8 mysqladmin ver 
/usr/local/mysql/bin/mysqladmin -P 3407 -S /opt/mysql/data/mysql.sock ver   
/usr/local/mysql/bin/mysqladmin  Ver 8.0.11 for el7 on x86_64 (MySQL Community Server - GPL)
Copyright (c) 2000, 2018, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Server version          8.0.11
Protocol version        10
Connection              Localhost via UNIX socket
UNIX socket             /opt/mysql/data/mysql.sock
Uptime:                 1 hour 44 min 44 sec

Threads: 2  Questions: 10  Slow queries: 0  Opens: 110  Flush tables: 2  Open tables: 86  Queries per second avg: 0.001
```

check MySQL server's default MySQL data directory variable value for `datadir`

```
/usr/bin/mysql-control 8 mysqladmin var | grep datadir | tr -s ' ' 
| datadir | /opt/mysql/data/ |
```

```
/usr/bin/mysql-control 8 show-engines
mysql -P 3407 -S /opt/mysql/data/mysql.sock -e "SHOW ENGINES;"
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| Engine             | Support | Comment                                                        | Transactions | XA   | Savepoints |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
| FEDERATED          | NO      | Federated MySQL storage engine                                 | NULL         | NULL | NULL       |
| MEMORY             | YES     | Hash based, stored in memory, useful for temporary tables      | NO           | NO   | NO         |
| InnoDB             | DEFAULT | Supports transactions, row-level locking, and foreign keys     | YES          | YES  | YES        |
| PERFORMANCE_SCHEMA | YES     | Performance Schema                                             | NO           | NO   | NO         |
| MyISAM             | YES     | MyISAM storage engine                                          | NO           | NO   | NO         |
| MRG_MYISAM         | YES     | Collection of identical MyISAM tables                          | NO           | NO   | NO         |
| BLACKHOLE          | YES     | /dev/null storage engine (anything you write to it disappears) | NO           | NO   | NO         |
| CSV                | YES     | CSV storage engine                                             | NO           | NO   | NO         |
| ARCHIVE            | YES     | Archive storage engine                                         | NO           | NO   | NO         |
+--------------------+---------+----------------------------------------------------------------+--------------+------+------------+
```