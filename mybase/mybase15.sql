use [02_MyBase]
go

drop trigger TR_WORKER_INS
drop trigger TR_WORKER_DEL
drop trigger TR_WORKER_UPD
drop trigger TR_WORKER_ALL
drop trigger TR_WORKER_DEL1
drop trigger TR_WORKER_DEL2
drop trigger TR_WORKER_DEL3
drop trigger EX7_WORKER
drop trigger TR_DEP_INSTEAD_OF
drop table TR_WORKER
go

-- ex 1: таблица для добавления в нее строк триггерами + триггер на insert
create table TR_WORKER (
	ID int identity,
	STMT varchar(20) check (STMT in ('INS', 'DEL', 'UPD')),
	TRNAME varchar(50),
	CC varchar(300)
)
go

create trigger TR_WORKER_INS
		on СОТРУДНИКИ after INSERT
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print 'Операция вставки';
	set @name = (select Имя_сотрудника from inserted);
	set @dep = (select Отдел from inserted);
	set @money = (select Предел_расхода from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
	insert into TR_WORKER(STMT, TRNAME, CC) values ('INS', 'TR_WORKER_INS', @in);
	return;
go

insert into СОТРУДНИКИ values ('Эрен', 'PR', 73.23);
select * from TR_WORKER
go

-- ex 2: триггер на delete
create trigger TR_WORKER_DEL
		on СОТРУДНИКИ after DELETE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print 'Операция  удаления';
	set @name = (select Имя_сотрудника from deleted);
	set @dep = (select Отдел from deleted);
	set @money = (select Предел_расхода from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
	insert into TR_WORKER(STMT, TRNAME, CC) values ('DEL', 'TR_WORKER_DEL', @in);
	return;
go

delete СОТРУДНИКИ where Имя_сотрудника = 'Эрен';
select * from TR_WORKER;
go

-- ex 3: триггер на update
create trigger TR_WORKER_UPD
		on СОТРУДНИКИ after UPDATE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print 'Операция изменения';
	set @name = (select Имя_сотрудника from inserted);
	set @dep = (select Отдел from inserted);
	set @money = (select Предел_расхода from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);

	set @name = (select Имя_сотрудника from deleted);
	set @dep = (select Отдел from deleted);
	set @money = (select Предел_расхода from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money) + ' -> ' + @in;
	insert into TR_WORKER(STMT, TRNAME, CC) values ('UPD', 'TR_WORKER_UPD', @in);
	return;
go

update СОТРУДНИКИ set Предел_расхода = 32.13 where Имя_сотрудника = 'Эрен';
select * from TR_WORKER;
go

-- ex 4:
create trigger TR_WORKER_ALL
		on СОТРУДНИКИ after INSERT, DELETE, UPDATE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	declare @ins int = (select count(*) from inserted), 
		@del int = (select count(*) from deleted);
	if (@ins > 0 and @del = 0)
		begin
			print 'Событие: INSERT';
			set @name = (select Имя_сотрудника from inserted);
			set @dep = (select Отдел from inserted);
			set @money = (select Предел_расхода from inserted);
			set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
			insert into TR_WORKER(STMT, TRNAME, CC) values ('INS', 'TR_WORKER_ALL', @in);
			return;
		end;
	if (@ins = 0 and @del > 0)
		begin
			print 'Событие: DELETE';
			set @name = (select Имя_сотрудника from deleted);
			set @dep = (select Отдел from deleted);
			set @money = (select Предел_расхода from deleted);
			set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
			insert into TR_WORKER(STMT, TRNAME, CC) values ('DEL', 'TR_WORKER_ALL', @in);
			return;
		end;
	print 'Событие: UPDATE';
	set @name = (select Имя_сотрудника from inserted);
	set @dep = (select Отдел from inserted);
	set @money = (select Предел_расхода from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);

	set @name = (select Имя_сотрудника from deleted);
	set @dep = (select Отдел from deleted);
	set @money = (select Предел_расхода from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money) + ' -> ' + @in;
	insert into TR_WORKER(STMT, TRNAME, CC) values ('UPD', 'TR_WORKER_ALL', @in);
	return;
go

insert СОТРУДНИКИ values ('Армин', 'Безопасности', 15.04);
update СОТРУДНИКИ set Предел_расхода = 38.14 where Имя_сотрудника = 'Армин';
delete СОТРУДНИКИ where Имя_сотрудника = 'Армин';
select * from TR_WORKER;
go

-- ex 5: у таблицы WORKER ограничение по внешнему ключу
update СОТРУДНИКИ set Отдел = 'Lorem' where Имя_сотрудника = 'Эрен';
select * from TR_WORKER;
go

-- ex 6: 3 новых триггера, посмотреть порядок, упорядоточить
create trigger TR_WORKER_DEL1 on СОТРУДНИКИ after DELETE  
       as print 'TR_WORKER_DEL1';
	return;  
go 

create trigger TR_WORKER_DEL2 on СОТРУДНИКИ after DELETE  
       as print 'TR_WORKER_DEL2';
	return;  
go 

create trigger TR_WORKER_DEL3 on СОТРУДНИКИ after DELETE  
       as print 'TR_WORKER_DEL3';
	return;  
go 

delete СОТРУДНИКИ where Имя_сотрудника = 'Эрен';
select * from TR_WORKER;
go

select t.name, e.type_desc 
from sys.triggers t join sys.trigger_events e  
	on t.object_id = e.object_id  
where OBJECT_NAME(t.parent_id) = 'СОТРУДНИКИ' and e.type_desc = 'DELETE';
go

exec sp_settriggerorder @triggername = 'TR_WORKER_DEL3',
	@order = 'First', @stmttype = 'DELETE';

exec sp_settriggerorder @triggername = 'TR_WORKER_DEL1',
	@order = 'Last', @stmttype = 'DELETE';
go

-- ex 7: триггер выполняется в рамках транзакции вызвавшего его оператора
create trigger EX7_WORKER on СОТРУДНИКИ after INSERT, UPDATE
	as declare @c real = (select sum(Предел_расхода) from СОТРУДНИКИ);
	if (@c > 10000)
		begin
			raiserror('Общий предел расхода не может быть >10000', 10, 1);
			rollback
		end;
	return;
go

insert СОТРУДНИКИ values ('Жан', 'Безопасности', 9999);
select * from СОТРУДНИКИ;
go

-- ex 8: instead of триггер, запрещающий удаление строк в таблице
create trigger TR_DEP_INSTEAD_OF on ОТДЕЛЫ instead of DELETE
	as raiserror('Удаление отделов запрещено',16,1);
	return;
go

delete ОТДЕЛЫ where Название_отдела = 'PR';
go;

-- ex 9: DDL-триггер на все DDL-события в бд [04_UNIVER]
create trigger TR_DDL_MYBASE 
		on database for DDL_DATABASE_LEVEL_EVENTS
	as declare @ev_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
	declare @obj_name varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
	declare @obj_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)');
	if (@ev_type = 'CREATE_TABLE') 
		begin
			raiserror('Создание таблиц запрещено',16,1);
			rollback;
		end;
	if (@ev_type = 'DROP_TABLE') 
		begin
			raiserror('Удаление таблиц запрещено',16,1);
			rollback;
		end;
go

create table TESTING (
	value int
)
drop table TR_WORKER;
go