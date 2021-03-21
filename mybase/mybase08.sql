use [02_MyBase]
go

-- просто все сотрудники
drop view Люди
go
create view Люди
	as select СОТРУДНИКИ.Имя_сотрудника [имя],
		СОТРУДНИКИ.Отдел [отдел],
		СОТРУДНИКИ.Предел_расхода [предел]
	from СОТРУДНИКИ
go
select * from Люди
insert into Люди values ('test', 'HR', 46.3)
select * from Люди
update Люди set предел = 87.12 where имя = 'test'
select * from Люди;
delete from Люди where имя = 'test';
select * from Люди

-- количество трат в отделе
drop view Траты
go
create view Траты
	as select СОТРУДНИКИ.Отдел [отдел],
		count(РАСХОДЫ.Сотрудник) [количество]
	from СОТРУДНИКИ join РАСХОДЫ 
		on СОТРУДНИКИ.Имя_сотрудника = РАСХОДЫ.Сотрудник
	group by СОТРУДНИКИ.Отдел
go
select * from Траты

-- сотрудники HR отдела
drop view Люди_PR
go
create view Люди_PR
	as select СОТРУДНИКИ.Имя_сотрудника [имя],
		СОТРУДНИКИ.Отдел [отдел],
		СОТРУДНИКИ.Предел_расхода [предел]
	from СОТРУДНИКИ
	where СОТРУДНИКИ.Отдел = 'PR' with check option
go
select * from Люди_PR
--insert into Люди_PR values ('test', 'HR', 46.3)

-- schemabinding
go
alter view Траты with schemabinding
	as select СОТРУДНИКИ.Отдел [отдел],
		count(РАСХОДЫ.Сотрудник) [количество]
	from dbo.СОТРУДНИКИ join dbo.РАСХОДЫ 
		on СОТРУДНИКИ.Имя_сотрудника = РАСХОДЫ.Сотрудник
	group by СОТРУДНИКИ.Отдел
go
select * from Траты

-- top + order by
drop view Отделы_компании
go
create view Отделы_компании (название, штат)
	as select top 50 ОТДЕЛЫ.Название_отдела, ОТДЕЛЫ.Количество_сотрудников
	from ОТДЕЛЫ
	order by ОТДЕЛЫ.Название_отдела
go
select * from Отделы_компании
