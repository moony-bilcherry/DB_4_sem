use [02_MyBase]
go

-- ex 1: считает количество сотрудников по названию отдела
drop function dbo.COUNT_WORKERS;
go
create function COUNT_WORKERS(@dep varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(СОТРУДНИКИ.Имя_сотрудника)
			from ОТДЕЛЫ 
				inner join СОТРУДНИКИ on ОТДЕЛЫ.Название_отдела = СОТРУДНИКИ.Отдел
			where ОТДЕЛЫ.Название_отдела = @dep)
		return @rc;
	end;
go

declare @temp_1 int = dbo.COUNT_WORKERS('PR');
print 'Количество сотрудников: ' + convert(varchar, @temp_1);

select ОТДЕЛЫ.Название_отдела 'Факультет', 
	dbo.COUNT_WORKERS(ОТДЕЛЫ.Название_отдела) 'Кол-во сотрудников'
from ОТДЕЛЫ
go

-- ex 2: 
drop function dbo.LISTWORKERS;
go
create function LISTWORKERS(@p varchar(20)) returns varchar(300)
	as begin
		declare @list varchar(300) = 'Сотрудники: ', @sub varchar(20);
			declare LAB14_EX2 cursor local
				for select СОТРУДНИКИ.Имя_сотрудника
					from СОТРУДНИКИ
					where СОТРУДНИКИ.Отдел = @p;
			open LAB14_EX2;
			fetch LAB14_EX2 into @sub;
			while @@FETCH_STATUS = 0
				begin
					set @list +=  rtrim(@sub) + ', ';
					fetch LAB14_EX2 into @sub;
				end;
		return @list;
	end;
go

print dbo.LISTWORKERS('PR');
select ОТДЕЛЫ.Название_отдела 'Кафедра', 
	dbo.LISTWORKERS(ОТДЕЛЫ.Название_отдела) 'Дисциплины'
from ОТДЕЛЫ;
go

-- ex 3: табличная функция
drop function dbo.FDEPWORK;
go
create function FDEPWORK(@fac varchar(20), @pul varchar(20)) returns table
	as return 
		select ОТДЕЛЫ.Название_отдела, СОТРУДНИКИ.Имя_сотрудника
		from ОТДЕЛЫ left outer join СОТРУДНИКИ on СОТРУДНИКИ.Отдел = ОТДЕЛЫ.Название_отдела
		where ОТДЕЛЫ.Название_отдела = isnull(@fac, ОТДЕЛЫ.Название_отдела)
			and СОТРУДНИКИ.Имя_сотрудника = isnull(@pul, СОТРУДНИКИ.Имя_сотрудника);
go

select * from dbo.FDEPWORK(null,null);
select * from dbo.FDEPWORK('PR',null);
select * from dbo.FDEPWORK(null,'Микаса');
select * from dbo.FDEPWORK('Кадров','Олег');
select * from dbo.FDEPWORK('lorem','ipsum');
go

-- ex 4: скалярная, считает количество преподов на кафедре
drop function dbo.FCOUNTWORKERS;
go
create function FCOUNTWORKERS(@pul varchar(20)) returns int
	as begin
		declare @rc int = (select count(*)
			from СОТРУДНИКИ
			where СОТРУДНИКИ.Отдел = isnull(@pul, СОТРУДНИКИ.Отдел));
		return @rc;
	end;
go

select ОТДЕЛЫ.Название_отдела 'Отдел', 
	dbo.FCOUNTWORKERS(ОТДЕЛЫ.Название_отдела) 'Кол-во сотрудников'
from ОТДЕЛЫ;
select dbo.FCOUNTWORKERS(null) 'Всего сотрудников';
go

select * from СОТРУДНИКИ