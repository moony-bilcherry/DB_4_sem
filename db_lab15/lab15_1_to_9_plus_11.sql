use [04_UNIVER]
go

drop trigger TR_TEACHER_INS
drop trigger TR_TEACHER_DEL
drop trigger TR_TEACHER_UPD
drop trigger TR_TEACHER
drop trigger TR_TEACHER_DEL1
drop trigger TR_TEACHER_DEL2
drop trigger TR_TEACHER_DEL3
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

-- ex 7: