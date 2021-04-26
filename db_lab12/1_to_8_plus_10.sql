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

-- ex 2: �������� �������� ����������� ����� ����������
insert into AUDITORIUM values('666-1','��-�','15','666-1');

begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '666-1';
		print '* ��������� �������';
		insert into AUDITORIUM values('666-1','��-�','15','666-1');
		print '* ��������� ���������';
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='666-1';
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

delete AUDITORIUM where AUDITORIUM_NAME = '666-1';

-- ex 3: