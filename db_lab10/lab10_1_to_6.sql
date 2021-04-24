use [04_UNIVER]

-- ex 1: таблица на 1к, кластеризированный индекс
exec sp_helpindex 'AUDITORIUM'
exec sp_helpindex 'AUDITORIUM_TYPE'
exec sp_helpindex 'FACULTY'
exec sp_helpindex 'PULPIT'
exec sp_helpindex 'PROFESSION'
exec sp_helpindex 'GROUPS'
exec sp_helpindex 'STUDENT'
exec sp_helpindex 'PROGRESS'
exec sp_helpindex 'SUBJECT'
exec sp_helpindex 'TEACHER'
exec sp_helpindex 'TIMETABLE'

create table #EX1TABLE 
	(t_ind int,
	t_field varchar(100));

set nocount on;
declare @ex1_cnt int = 0;
while (@ex1_cnt < 1000)
begin
	insert into #EX1TABLE values (floor(20000*rand()), replicate('string1', 10));
	if ((@ex1_cnt + 1) % 100 = 0) 
		print 'Добавлено строк:' + convert(varchar, @ex1_cnt + 1);
	set @ex1_cnt = @ex1_cnt + 1;
end;

select * from #EX1TABLE where t_ind between 1500 and 2000 order by t_ind;

checkpoint;
dbcc dropcleanbuffers;

create clustered index #EX1TABLE_CL on #EX1TABLE(t_ind asc);
select * from #EX1TABLE where t_ind between 1500 and 2000 order by t_ind;

drop index #EX1TABLE_CL on #EX1TABLE
drop table #EX1TABLE

-- ex 2: таблица на 10к, некастеризованный неуникальный составной индекс

create table #EX2TABLE 
	(t_ind int,
	t_identity int identity(1,1),
	t_field varchar(100));

set nocount on;
declare @ex2_cnt int = 0;
while (@ex2_cnt < 10000)
begin
	insert into #EX2TABLE(t_ind, t_field) values (floor(30000*rand()), replicate('string2', 10));
	if ((@ex2_cnt + 1) % 1000 = 0) 
		print 'Добавлено строк:' + convert(varchar, @ex2_cnt + 1);
	set @ex2_cnt = @ex2_cnt + 1;
end;

select * from #EX2TABLE;
select count(*) as 'Количество строк' from #EX2TABLE;

create index #EX2_NONCLU on #EX2TABLE(t_ind, t_identity);

select * from #EX2TABLE where t_ind > 15000 and t_identity < 4500
select * from #EX2TABLE order by t_ind, t_identity

select * from #EX2TABLE where t_identity = 2804

drop index #EX2_NONCLU on #EX2TABLE
drop table #EX2TABLE

-- ex 3: таблица на 10к, некластеризованный индекс покрытия
create table #EX3TABLE 
	(t_ind int,
	t_identity int identity(1,1),
	t_field varchar(100));

set nocount on;
declare @ex3_cnt int = 0;
while (@ex3_cnt < 10000)
begin
	insert into #EX3TABLE(t_ind, t_field) values (floor(30000*rand()), replicate('string3', 10));
	if ((@ex3_cnt + 1) % 1000 = 0) 
		print 'Добавлено строк:' + convert(varchar, @ex3_cnt + 1);
	set @ex3_cnt = @ex3_cnt + 1;
end;

select * from #EX3TABLE;
select count(*) as 'Количество строк' from #EX3TABLE;

create index #EX3_INCL on #EX3TABLE(t_ind) include (t_identity)
select * from #EX3TABLE where t_ind > 15000;


drop index #EX3_INCL on #EX3TABLE
drop table #EX3TABLE

-- ex 4: таблица, некластеризованный фильтруемый индекс
create table #EX4
	(t_rnd int,
	t_identity int identity(1,1),
	t_field varchar(100));

set nocount on;
declare @ex4_cnt int = 0;
while (@ex4_cnt < 10000)
begin
	insert into #EX4(t_rnd, t_field) values (floor(30000*rand()), replicate('string4', 10));
	if ((@ex4_cnt + 1) % 1000 = 0) 
		print 'Добавлено строк:' + convert(varchar, @ex4_cnt + 1);
	set @ex4_cnt = @ex4_cnt + 1;
end;

select * from #EX4 where t_rnd between 7432 and 10385;
select * from #EX4 where t_rnd > 24862;
select count(*) as 'Количество строк' from #EX4;

create index #EX4_FILTER1 on #EX4(t_rnd) where (t_rnd >= 15000 and t_rnd <= 17000)

drop index #EX4_FILTER1 on #EX4
drop table #EX4

-- ex 5: таблица, некластеризированный индекс, оценить уровень фрагментации индекса

create table #EX5 
	(tkey int,
	cc int identity(1,1),
	tf varchar(100));

set nocount on;
declare @ex5_cnt int = 0;
while (@ex5_cnt < 10000)
begin
	insert into #EX5(tkey, tf) values (floor(30000*rand()), replicate('string5', 10));
	if ((@ex5_cnt + 1) % 1000 = 0) 
		print 'Добавлено строк:' + convert(varchar, @ex5_cnt + 1);
	set @ex5_cnt = @ex5_cnt + 1;
end;

select * from #EX5;

use tempdb
create index #EX5_TKEY on #EX5(tkey);

insert top(10000) #EX5(tkey, tf) select tkey, tf from #EX5

alter index #EX5_TKEY on #EX5 reorganize;
alter index #EX5_TKEY on #EX5 rebuild with (online = off);

select name [Индекс],
	avg_fragmentation_in_percent [Фрагментация(%)]
	from sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'),
		OBJECT_ID(N'#EX5_TKEY'), null, null, null) ss
	join sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id
	where name is not null;

-- ex 6: некластеризованный индекс, fillfactor=65
create index  #EX6_TKEY on #EX5(tkey) with (fillfactor = 65);

insert top(50) percent into #EX5(tkey,tf) select tkey, tf from #EX5

select name [Индекс],
	avg_fragmentation_in_percent [Фрагментация(%)]
	from sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'),
		OBJECT_ID(N'#EX6_TKEY'), null, null, null) ss
	join sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id
	where name is not null;

drop index #EX5_TKEY on #EX5
drop index #EX6_TKEY on #EX5
drop table #EX5