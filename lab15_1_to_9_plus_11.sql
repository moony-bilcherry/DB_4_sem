use [04_UNIVER]
go

drop trigger TR_TEACHER_INS
drop trigger TR_TEACHER_DEL
drop table TR_AUDIT
go

-- ex 1: таблица для добавления в нее строк триггерами
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

-- ex 2
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

-- ex 3
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