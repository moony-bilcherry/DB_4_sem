use master
create database [04_UNIVER]

on primary
(name = N'UNIVER_mdf', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_mdf.mdf',
size = 5Mb, maxsize = 10240Kb, filegrowth = 10%),
(name = N'UNIVER_ndf', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_ndf.ndf', 
size = 5120Kb, maxsize = 10240Kb, filegrowth = 10%), 

filegroup G1 
	(name = N'UNIVER_fg1_1', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_g1_1.ndf', 
		size = 10240Kb, maxsize = 15360Kb, filegrowth = 1024Kb), 
	(name = N'UNIVER_fg1_2', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_g1_2.ndf', 
		size = 2048Kb, maxsize = 5120Kb, filegrowth = 1024Kb), 
		
filegroup G2 
	(name = N'UNIVER_fg2_1', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_g2_1.ndf', 
		size = 5120Kb, maxsize = 10240Kb, filegrowth = 1024Kb), 
	(name = N'UNIVER_fg2_2', filename = N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_g2_2.ndf', 
		size = 2048Kb, maxsize = 5120Kb, filegrowth = 1024Kb)

log on 
(name = N'UNIVER_log', filename=N'E:\Uni\4 сем\DB\labs_db\db_lab04\UNIVER_log.ldf', 
		size=5120Kb, maxsize=UNLIMITED, filegrowth=1024Kb) 


