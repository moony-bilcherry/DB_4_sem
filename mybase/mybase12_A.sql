use [02_MyBase]

select * from ����������
select * from ������

-- ex 2: ����������� (����������� ��� ��� ������)
delete ���������� where ���_���������� = '���������';
insert into ���������� values('���������','������',5.33);

begin try
	begin tran
		delete ���������� where ���_���������� = '���������';
		print '* ��������� ������';
		insert into ���������� values('���������','������',5.33);
		print '* ��������� ��������';
		update ���������� set ������_������� = 1.99 where ���_����������='���������';
		print '* ��������� �������';
	commit tran;
end try
begin catch
	print '������: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%PK_����������%', ERROR_MESSAGE()) > 0
			then '��������'
			else '����������� ������: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if @@TRANCOUNT > 0 rollback tran;
end catch;

-- ex 3: save tran
delete ������ where ��������_������ = '�������';
insert into ������ values('�������',12);

declare @point varchar(32);
begin try
	begin tran
		delete ������ where ��������_������ = '�������';
		print '* ����� ������';
		set @point = 'p1'; save tran @point;
		insert into ������ values('�������',12);
		print '* ����� ��������';
		set @point = 'p2'; save tran @point;
		update ������ set ����������_����������� = 40 where ��������_������='�������';
	commit tran;
end try
begin catch
	print '������: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%PK_������%', ERROR_MESSAGE()) > 0
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
delete ���������� where ���_���������� = '�������';
insert into ���������� values('�������','������',7.09);
				--- A ---
-- 1
set transaction isolation level READ UNCOMMITTED 
begin tran
-- 3
select @@SPID, 'insert ������' '���������', * 
	from ������ where ��������_������ = 'ϸ�����';
select @@SPID, 'update AUDITORIUM'  '���������', *
	from ���������� where ���_���������� = '�������';
-- 5
commit tran; 

-- ex 5: READ COMMITTED 
				--- A ---
-- 1
set transaction isolation level READ COMMITTED;
begin tran
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- 3
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- 5
commit tran;

-- ex 6: REPEATABLE READ
insert ���������� values ('�������', '������', 12.4); 
				--- A ---
-- 1
set transaction isolation level  REPEATABLE READ 
begin transaction 
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- 3
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;
commit tran; 

-- 4
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- ex 7: SERIALIZABLE
				--- A ---
-- 1
set transaction isolation level SERIALIZABLE
begin tran
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- 3
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;
commit tran;

delete from ���������� where ���_���������� = '������';