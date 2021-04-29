use [04_UNIVER]
go

drop procedure PSUBJECT;
go
-- ex 1: �������� ��������� ��� ����������, ��������� �������������� ����� �� ������ ������� SUBJECT
create procedure PSUBJECT 
	as begin
		declare @num int = (select count(*) from SUBJECT);
		select * from SUBJECT;
		return @num;
	end;
go

declare @temp_1 int = 0;
exec @temp_1 = PSUBJECT;
print '���������� ���������: ' + convert(varchar, @temp_1);
go

-- ex 2: �������� + ���������
alter procedure PSUBJECT @p varchar(20), @c int output
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print '���������: @p = ' + @p + ', @c = ' + convert (varchar, @c);
		select * from SUBJECT where PULPIT = @p;
		set @c = @@ROWCOUNT;
		return @num;
	end;
go

declare @temp_2 int = 0, @out_2 int = 0;
exec @temp_2 = PSUBJECT '����', @out_2 output;
print '��������� �����: ' + convert(varchar, @temp_2);
print '��������� �� ������� ����: ' + convert(varchar, @out_2);
go

-- ex 3: ��������� ��������� �������, �������� ���������, insert
alter procedure PSUBJECT @p varchar(20)
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print '���������: @p = ' + @p;
		select * from SUBJECT where PULPIT = @p;
	end;
go

create table #EX3 (
	sub nvarchar(10) primary key,
	sub_name nvarchar(50),
	pul nvarchar(50)
)

insert #EX3 exec PSUBJECT '����';
select * from #EX3;
go

-- ex 4: