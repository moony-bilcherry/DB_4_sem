use [04_UNIVER]
go

drop trigger TR_TEACHER_INS
drop trigger TR_TEACHER_DEL
drop trigger TR_TEACHER_UPD
drop trigger TR_TEACHER
drop trigger TR_TEACHER_DEL1
drop trigger TR_TEACHER_DEL2
drop trigger TR_TEACHER_DEL3
drop trigger EX7_AUDITORIUM
drop trigger TR_FACULTY_INSTEAD_OF
drop table TR_AUDIT
go

-- ex 1: таблица для добавления в нее строк триггерами + триггер на insert
create table TR_AUDIT (
	ID int identity,
	STMT varchar(20) check (STMT in ('INS', 'DEL', 'UPD')),
	TRNAME varchar(50),
	CC varchar(300)
)
go

create trigger TR_TEACHER_INS
		on TEACHER after INSERT
	as declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция вставки';
	set @teach = (select TEACHER from inserted);
	set @teachname = (select TEACHER_NAME from inserted);
	set @gen = (select GENDER from inserted);
	set @pul = (select PULPIT from inserted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER_INS', @in);
	return;
go

insert into TEACHER values ('ЙГР', 'Йегер Эрен Григорьевич', 'м', 'ИСиТ')
select * from TR_AUDIT
go

-- ex 2: триггер на delete
create trigger TR_TEACHER_DEL
		on TEACHER after DELETE
	as declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция  удаления';
	set @teach = (select TEACHER from deleted);
	set @teachname = (select TEACHER_NAME from deleted);
	set @gen = (select GENDER from deleted);
	set @pul = (select PULPIT from deleted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER_DEL', @in);
	return;
go

delete TEACHER where TEACHER = 'ЙГР';
select * from TR_AUDIT;
go

-- ex 3: триггер на update
create trigger TR_TEACHER_UPD
		on TEACHER after UPDATE
	as declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	print 'Операция изменения';
	set @teach = (select TEACHER from inserted);
	set @teachname = (select TEACHER_NAME from inserted);
	set @gen = (select GENDER from inserted);
	set @pul = (select PULPIT from inserted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);

	set @teach = (select TEACHER from deleted);
	set @teachname = (select TEACHER_NAME from deleted);
	set @gen = (select GENDER from deleted);
	set @pul = (select PULPIT from deleted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul) + ' -> ' + @in;
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER_UPD', @in);
	return;
go

update TEACHER set TEACHER_NAME = 'Йегер Эрен Гришевич' where TEACHER = 'ЙГР';
select * from TR_AUDIT;
go

-- ex 4:
create trigger TR_TEACHER
		on TEACHER after INSERT, DELETE, UPDATE
	as declare @teach varchar(15), @teachname varchar(50), @gen char(1), @pul varchar(15), @in varchar(300);
	declare @ins int = (select count(*) from inserted), 
		@del int = (select count(*) from deleted);
	if (@ins > 0 and @del = 0)
		begin
			print 'Событие: INSERT';
			set @teach = (select TEACHER from inserted);
			set @teachname = (select TEACHER_NAME from inserted);
			set @gen = (select GENDER from inserted);
			set @pul = (select PULPIT from inserted);
			set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
			insert into TR_AUDIT(STMT, TRNAME, CC) values ('INS', 'TR_TEACHER', @in);
			return;
		end;
	if (@ins = 0 and @del > 0)
		begin
			print 'Событие: DELETE';
			set @teach = (select TEACHER from deleted);
			set @teachname = (select TEACHER_NAME from deleted);
			set @gen = (select GENDER from deleted);
			set @pul = (select PULPIT from deleted);
			set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);
			insert into TR_AUDIT(STMT, TRNAME, CC) values ('DEL', 'TR_TEACHER', @in);
			return;
		end;
	print 'Событие: UPDATE';
	set @teach = (select TEACHER from inserted);
	set @teachname = (select TEACHER_NAME from inserted);
	set @gen = (select GENDER from inserted);
	set @pul = (select PULPIT from inserted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul);

	set @teach = (select TEACHER from deleted);
	set @teachname = (select TEACHER_NAME from deleted);
	set @gen = (select GENDER from deleted);
	set @pul = (select PULPIT from deleted);
	set @in = rtrim(@teach) + ' ' + rtrim(@teachname) + ' ' + @gen + ' ' + rtrim(@pul) + ' -> ' + @in;
	insert into TR_AUDIT(STMT, TRNAME, CC) values ('UPD', 'TR_TEACHER', @in);
	return;
go

insert TEACHER values ('АРЛ', 'Арлерт Армин', 'м', 'ИСиТ');
update TEACHER set TEACHER_NAME = 'Арлерт Армин Дмитриевич' where TEACHER = 'АРЛ';
delete TEACHER where TEACHER = 'АРЛ';
select * from TR_AUDIT;
go

-- ex 5: у таблицы TEACHER ограничение по внешнему ключу
update TEACHER set PULPIT = 'Lorem' where TEACHER = 'ЙГР';
select * from TR_AUDIT;
go

-- ex 6: 3 новых триггера, посмотреть порядок, упорядоточить
create trigger TR_TEACHER_DEL1 on TEACHER after DELETE  
       as print 'TR_TEACHER_DEL1';
	return;  
go 

create trigger TR_TEACHER_DEL2 on TEACHER after DELETE  
       as print 'TR_TEACHER_DEL2';
	return;  
go 

create trigger TR_TEACHER_DEL3 on TEACHER after DELETE  
       as print 'TR_TEACHER_DEL3';
	return;  
go 

delete TEACHER where TEACHER = 'ЙГР';
select * from TR_AUDIT;
go

select t.name, e.type_desc 
from sys.triggers t join sys.trigger_events e  
	on t.object_id = e.object_id  
where OBJECT_NAME(t.parent_id) = 'TEACHER' and e.type_desc = 'DELETE';
go

exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL3',
	@order = 'First', @stmttype = 'DELETE';

exec sp_settriggerorder @triggername = 'TR_TEACHER_DEL1',
	@order = 'Last', @stmttype = 'DELETE';
go

-- ex 7: триггер выполняется в рамках транзакции вызвавшего его оператора
create trigger EX7_AUDITORIUM on AUDITORIUM after INSERT, UPDATE
	as declare @c int = (select sum(AUDITORIUM_CAPACITY) from AUDITORIUM);
	if (@c > 700)
		begin
			raiserror('Общая вместимость аудиторий не может быть >700', 10, 1);
			rollback
		end;
	return;
go

insert AUDITORIUM values ('151515-1', 'ЛК', 250, '151515-1');
select * from AUDITORIUM;
go

-- ex 8: instead of триггер, запрещающий удаление строк в таблице
create trigger TR_FACULTY_INSTEAD_OF on FACULTY instead of DELETE
	as raiserror('Удаление факультетов запрещено',16,1);
	return;
go

delete FACULTY where FACULTY = 'ИТ';
go;

-- ex 9: DDL-триггер на все DDL-события в бд [04_UNIVER]
create trigger TR_DDL_UNIVER 
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
drop table TR_AUDIT;
go

-- ex 11

