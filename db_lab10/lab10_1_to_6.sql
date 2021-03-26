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
	insert into #EX1TABLE values (floor(20000*rand()), replicate('string', 10));
	if ((@ex1_cnt + 1) % 100 = 0) 
		print 'ƒобавлено строк:' + convert(varchar, @ex1_cnt + 1);
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
	insert into #EX2TABLE(t_ind, t_field) values (floor(30000*rand()), replicate('string', 10));
	if ((@ex2_cnt + 1) % 1000 = 0) 
		print 'ƒобавлено строк:' + convert(varchar, @ex2_cnt + 1);
	set @ex2_cnt = @ex2_cnt + 1;
end;

select * from #EX2TABLE;
select count(*) as ' оличество строк' from #EX2TABLE;

create index #EX2_NONCLU on #EX2TABLE(t_ind, t_identity);

select * from #EX2TABLE where t_ind > 15000 and t_identity < 4500
select * from #EX2TABLE order by t_ind, t_identity

select * from #EX2TABLE where t_identity = 2804

drop index #EX2_NONCLU on #EX2TABLE
drop table #EX2TABLE

-- ex 3: