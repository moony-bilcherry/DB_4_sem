use [02_MyBase];

-- ex 4: READ UNCOMMITTED
				--- B ---	
-- 2
begin tran
select @@SPID
insert into ������ values ('ϸ�����', 15); 
update ���������� set ������_������� = 1.52 where ���_���������� = '�������' 
-- 4
rollback tran;

-- ex 5: READ COMMITTED
				--- B ---	
-- 2
begin tran
delete from ���������� where ���_���������� = '�������'

-- 4
rollback tran;

-- ex 6: REPEATABLE READ
				--- B ---
-- 2
begin tran
delete from ���������� where ���_���������� = '�������';
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;

-- 5
commit tran;

-- ex 7: SERIALIZABLE
				--- B ---
-- 2
begin tran
insert ���������� values ('������', '������', 64.92); 

-- 4
select count(*) '���-�� �����������', @@TRANCOUNT '@@TRANCOUNT' from ����������;
commit tran;