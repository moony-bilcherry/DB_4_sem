use [02_MyBase]
go

-- ������ ��� ����������
drop view ����
go
create view ����
	as select ����������.���_���������� [���],
		����������.����� [�����],
		����������.������_������� [������]
	from ����������
go
select * from ����
insert into ���� values ('test', 'HR', 46.3)
select * from ����
update ���� set ������ = 87.12 where ��� = 'test'
select * from ����;
delete from ���� where ��� = 'test';
select * from ����

-- ���������� ���� � ������
drop view �����
go
create view �����
	as select ����������.����� [�����],
		count(�������.���������) [����������]
	from ���������� join ������� 
		on ����������.���_���������� = �������.���������
	group by ����������.�����
go
select * from �����

-- ���������� HR ������
drop view ����_PR
go
create view ����_PR
	as select ����������.���_���������� [���],
		����������.����� [�����],
		����������.������_������� [������]
	from ����������
	where ����������.����� = 'PR' with check option
go
select * from ����_PR
--insert into ����_PR values ('test', 'HR', 46.3)

-- schemabinding
go
alter view ����� with schemabinding
	as select ����������.����� [�����],
		count(�������.���������) [����������]
	from dbo.���������� join dbo.������� 
		on ����������.���_���������� = �������.���������
	group by ����������.�����
go
select * from �����

-- top + order by
drop view ������_��������
go
create view ������_�������� (��������, ����)
	as select top 50 ������.��������_������, ������.����������_�����������
	from ������
	order by ������.��������_������
go
select * from ������_��������
