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

-- ex 1: ������� ��� ���������� � ��� ����� ���������� + ������� �� insert
create table TR_WORKER (
	ID int identity,
	STMT varchar(20) check (STMT in ('INS', 'DEL', 'UPD')),
	TRNAME varchar(50),
	CC varchar(300)
)
go

create trigger TR_WORKER_INS
		on ���������� after INSERT
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print '�������� �������';
	set @name = (select ���_���������� from inserted);
	set @dep = (select ����� from inserted);
	set @money = (select ������_������� from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
	insert into TR_WORKER(STMT, TRNAME, CC) values ('INS', 'TR_WORKER_INS', @in);
	return;
go

insert into ���������� values ('����', 'PR', 73.23);
select * from TR_WORKER
go

-- ex 2: ������� �� delete
create trigger TR_WORKER_DEL
		on ���������� after DELETE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print '��������  ��������';
	set @name = (select ���_���������� from deleted);
	set @dep = (select ����� from deleted);
	set @money = (select ������_������� from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
	insert into TR_WORKER(STMT, TRNAME, CC) values ('DEL', 'TR_WORKER_DEL', @in);
	return;
go

delete ���������� where ���_���������� = '����';
select * from TR_WORKER;
go

-- ex 3: ������� �� update
create trigger TR_WORKER_UPD
		on ���������� after UPDATE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	print '�������� ���������';
	set @name = (select ���_���������� from inserted);
	set @dep = (select ����� from inserted);
	set @money = (select ������_������� from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);

	set @name = (select ���_���������� from deleted);
	set @dep = (select ����� from deleted);
	set @money = (select ������_������� from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money) + ' -> ' + @in;
	insert into TR_WORKER(STMT, TRNAME, CC) values ('UPD', 'TR_WORKER_UPD', @in);
	return;
go

update ���������� set ������_������� = 32.13 where ���_���������� = '����';
select * from TR_WORKER;
go

-- ex 4:
create trigger TR_WORKER_ALL
		on ���������� after INSERT, DELETE, UPDATE
	as declare @name varchar(20), @dep varchar(20), @money real, @in varchar(300);
	declare @ins int = (select count(*) from inserted), 
		@del int = (select count(*) from deleted);
	if (@ins > 0 and @del = 0)
		begin
			print '�������: INSERT';
			set @name = (select ���_���������� from inserted);
			set @dep = (select ����� from inserted);
			set @money = (select ������_������� from inserted);
			set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
			insert into TR_WORKER(STMT, TRNAME, CC) values ('INS', 'TR_WORKER_ALL', @in);
			return;
		end;
	if (@ins = 0 and @del > 0)
		begin
			print '�������: DELETE';
			set @name = (select ���_���������� from deleted);
			set @dep = (select ����� from deleted);
			set @money = (select ������_������� from deleted);
			set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);
			insert into TR_WORKER(STMT, TRNAME, CC) values ('DEL', 'TR_WORKER_ALL', @in);
			return;
		end;
	print '�������: UPDATE';
	set @name = (select ���_���������� from inserted);
	set @dep = (select ����� from inserted);
	set @money = (select ������_������� from inserted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money);

	set @name = (select ���_���������� from deleted);
	set @dep = (select ����� from deleted);
	set @money = (select ������_������� from deleted);
	set @in = rtrim(@name) + ' ' + rtrim(@dep) + ' ' + convert(varchar,@money) + ' -> ' + @in;
	insert into TR_WORKER(STMT, TRNAME, CC) values ('UPD', 'TR_WORKER_ALL', @in);
	return;
go

insert ���������� values ('�����', '������������', 15.04);
update ���������� set ������_������� = 38.14 where ���_���������� = '�����';
delete ���������� where ���_���������� = '�����';
select * from TR_WORKER;
go

-- ex 5: � ������� WORKER ����������� �� �������� �����
update ���������� set ����� = 'Lorem' where ���_���������� = '����';
select * from TR_WORKER;
go

-- ex 6: 3 ����� ��������, ���������� �������, �������������
create trigger TR_WORKER_DEL1 on ���������� after DELETE  
       as print 'TR_WORKER_DEL1';
	return;  
go 

create trigger TR_WORKER_DEL2 on ���������� after DELETE  
       as print 'TR_WORKER_DEL2';
	return;  
go 

create trigger TR_WORKER_DEL3 on ���������� after DELETE  
       as print 'TR_WORKER_DEL3';
	return;  
go 

delete ���������� where ���_���������� = '����';
select * from TR_WORKER;
go

select t.name, e.type_desc 
from sys.triggers t join sys.trigger_events e  
	on t.object_id = e.object_id  
where OBJECT_NAME(t.parent_id) = '����������' and e.type_desc = 'DELETE';
go

exec sp_settriggerorder @triggername = 'TR_WORKER_DEL3',
	@order = 'First', @stmttype = 'DELETE';

exec sp_settriggerorder @triggername = 'TR_WORKER_DEL1',
	@order = 'Last', @stmttype = 'DELETE';
go

-- ex 7: ������� ����������� � ������ ���������� ���������� ��� ���������
create trigger EX7_WORKER on ���������� after INSERT, UPDATE
	as declare @c real = (select sum(������_�������) from ����������);
	if (@c > 10000)
		begin
			raiserror('����� ������ ������� �� ����� ���� >10000', 10, 1);
			rollback
		end;
	return;
go

insert ���������� values ('���', '������������', 9999);
select * from ����������;
go

-- ex 8: instead of �������, ����������� �������� ����� � �������
create trigger TR_DEP_INSTEAD_OF on ������ instead of DELETE
	as raiserror('�������� ������� ���������',16,1);
	return;
go

delete ������ where ��������_������ = 'PR';
go;

-- ex 9: DDL-������� �� ��� DDL-������� � �� [04_UNIVER]
create trigger TR_DDL_MYBASE 
		on database for DDL_DATABASE_LEVEL_EVENTS
	as declare @ev_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
	declare @obj_name varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
	declare @obj_type varchar(50) = eventdata().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)');
	if (@ev_type = 'CREATE_TABLE') 
		begin
			raiserror('�������� ������ ���������',16,1);
			rollback;
		end;
	if (@ev_type = 'DROP_TABLE') 
		begin
			raiserror('�������� ������ ���������',16,1);
			rollback;
		end;
go

create table TESTING (
	value int
)
drop table TR_WORKER;
go