# MariaDB mysqld_multi - multiple MariaDB MySQL server setup

Setup multiple MariaDB MySQL server instances on the same [Centmin Mod LEMP Stack](https://centminmod.com/) server.

* https://mariadb.com/kb/en/library/mysqld_multi/
* https://dev.mysql.com/doc/refman/5.6/en/mysqld-multi.html
* https://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html

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