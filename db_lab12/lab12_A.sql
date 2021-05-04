use [04_UNIVER];

-- ex 1: ������� ����������
set nocount on;
if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	drop table EX1_T;

declare @c int, @flag char = 'r';
set implicit_transactions on;
create table EX1_T (val int);
insert EX1_T values (1), (2), (3);
set @c = (select count(*) from EX1_T);
print '���-�� ����� � ������� EX1_T: ' + convert(varchar, @c);
if @flag = 'c' 
	commit;
else 
	rollback;
set implicit_transactions off;

if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	print '������� EX1_T ����';
else
	print '������� EX1_T ���';

if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	drop table EX1_T;

-- ex 2: �������� �������� ����������� ����� ���������� (����������� ��� ��� ������)
delete AUDITORIUM where AUDITORIUM_NAME = '222-1';
insert into AUDITORIUM values('222-1','��-�','15','222-1');

begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '222-1';
		print '* ��������� �������';
		insert into AUDITORIUM values('222-1','��-�','15','222-1');
		print '* ��������� ���������';
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='222-1';
		print '* ��������� ��������';
	commit tran;
end try
begin catch
	print '������: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%AUDITORIUM_PK%', ERROR_MESSAGE()) > 0
			then '��������'
			else '����������� ������: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if @@TRANCOUNT > 0 rollback tran;
end catch;

-- ex 3: save tran
delete AUDITORIUM where AUDITORIUM_NAME = '333-1';
insert into AUDITORIUM values('333-1','��-�','15','333-1');

declare @point varchar(32);
begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '333-1';
		print '* ��������� �������';
		set @point = 'p1'; save tran @point;
		insert into AUDITORIUM values('333-1','��-�','15','333-1');
		print '* ��������� ���������';
		set @point = 'p2'; save tran @point;
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='333-1';
	commit tran;
end try
begin catch
	print '������: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%AUDITORIUM_PK%', ERROR_MESSAGE()) > 0
			then '��������'
			else '����������� ������: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if (@@TRANCOUNT > 0) 
		begin
			print '����������� �����: ' + @point;
			rollback tran @point;
			commit tran;
		end;
end catch;

-- ex 4: 2 ������������ ����������, READ UNCOMMITED
delete AUDITORIUM where AUDITORIUM_NAME = '222-1';
insert into AUDITORIUM values('222-1','��-�','15','222-1');
				--- A ---
-- 1
set transaction isolation level READ UNCOMMITTED 
begin tran
-- 3
select @@SPID, 'insert SUBJECT' '���������', * 
	from SUBJECT where SUBJECT = '���';
select @@SPID, 'update AUDITORIUM'  '���������', AUDITORIUM, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE 
	from AUDITORIUM where AUDITORIUM = '222-1';
-- 5
commit tran; 

delete SUBJECT where SUBJECT = '���';

select * from SUBJECT
select * from PULPIT
select * from AUDITORIUM

-- ex 5: READ COMMITTED 
				--- A ---
-- 1
set transaction isolation level READ COMMITTED;
begin tran
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;

-- 3
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;

-- 5
commit tran;

-- ex 6: REPEATABLE READ
insert AUDITORIUM values ('126-1', '��-�', 12,'126-1'); 
				--- A ---
-- 1
set transaction isolation level  REPEATABLE READ 
begin transaction 
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;

-- 3
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;
commit tran; 

-- 4
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;

--delete from AUDITORIUM where AUDITORIUM = '126-2';

-- ex 7: SERIALIZABLE
				--- A ---
-- 1
set transaction isolation level SERIALIZABLE
begin tran
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;

-- 3
select count(*) '���-�� ���������', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;
commit tran;

delete from AUDITORIUM where AUDITORIUM = '127-1';

-- ex 8: ��������� ����������
select count(*) '���-�� ��������� ���' 
	from SUBJECT where SUBJECT = '���'

begin tran
insert SUBJECT values ('���', '������ ������ ����������', '����'); 
	begin tran
		update SUBJECT set SUBJECT_NAME = '������ ������ ��������� ������ �����' where SUBJECT = '���';
		commit;
	select count(*) '���-�� ��������� ���' 
	from SUBJECT where SUBJECT = '���'
	if @@TRANCOUNT > 0 rollback;

select count(*) '���-�� ��������� ���'
	from SUBJECT where SUBJECT = '���'

delete from SUBJECT where SUBJECT = '���'