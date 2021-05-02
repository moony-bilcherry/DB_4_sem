use [02_MyBase]
go

-- ex 1: ������� ���������� ����������� �� �������� ������
drop function dbo.COUNT_WORKERS;
go
create function COUNT_WORKERS(@dep varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(����������.���_����������)
			from ������ 
				inner join ���������� on ������.��������_������ = ����������.�����
			where ������.��������_������ = @dep)
		return @rc;
	end;
go

declare @temp_1 int = dbo.COUNT_WORKERS('PR');
print '���������� �����������: ' + convert(varchar, @temp_1);

select ������.��������_������ '���������', 
	dbo.COUNT_WORKERS(������.��������_������) '���-�� �����������'
from ������
go

-- ex 2: 
drop function dbo.LISTWORKERS;
go
create function LISTWORKERS(@p varchar(20)) returns varchar(300)
	as begin
		declare @list varchar(300) = '����������: ', @sub varchar(20);
			declare LAB14_EX2 cursor local
				for select ����������.���_����������
					from ����������
					where ����������.����� = @p;
			open LAB14_EX2;
			fetch LAB14_EX2 into @sub;
			while @@FETCH_STATUS = 0
				begin
					set @list +=  rtrim(@sub) + ', ';
					fetch LAB14_EX2 into @sub;
				end;
		return @list;
	end;
go

print dbo.LISTWORKERS('PR');
select ������.��������_������ '�������', 
	dbo.LISTWORKERS(������.��������_������) '����������'
from ������;
go

-- ex 3: ��������� �������
drop function dbo.FDEPWORK;
go
create function FDEPWORK(@fac varchar(20), @pul varchar(20)) returns table
	as return 
		select ������.��������_������, ����������.���_����������
		from ������ left outer join ���������� on ����������.����� = ������.��������_������
		where ������.��������_������ = isnull(@fac, ������.��������_������)
			and ����������.���_���������� = isnull(@pul, ����������.���_����������);
go

select * from dbo.FDEPWORK(null,null);
select * from dbo.FDEPWORK('PR',null);
select * from dbo.FDEPWORK(null,'������');
select * from dbo.FDEPWORK('������','����');
select * from dbo.FDEPWORK('lorem','ipsum');
go

-- ex 4: ���������, ������� ���������� �������� �� �������
drop function dbo.FCOUNTWORKERS;
go
create function FCOUNTWORKERS(@pul varchar(20)) returns int
	as begin
		declare @rc int = (select count(*)
			from ����������
			where ����������.����� = isnull(@pul, ����������.�����));
		return @rc;
	end;
go

select ������.��������_������ '�����', 
	dbo.FCOUNTWORKERS(������.��������_������) '���-�� �����������'
from ������;
select dbo.FCOUNTWORKERS(null) '����� �����������';
go

select * from ����������