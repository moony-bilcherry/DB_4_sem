use [04_UNIVER]

-- ex 1
declare @vchar char(2) = 'hi',
		@vvarchar varchar(9) = 'Note',
		@vdate datetime,
		@vtime time,
		@vint int,
		@vsmall smallint,
		@vtiny tinyint,
		@vnumeric numeric(12,5);

set @vdate = getdate();
select @vtime = '12:59:34';

select @vint = 434635, @vsmall = 3562, @vnumeric  = 1234567.12345;
select @vchar vchar, @vvarchar vvarchar, @vdate vdate, @vtime vtime;

print 'vint = ' + cast(@vint as varchar(10));
print 'vsmall = ' + cast(@vsmall as varchar(10));
print 'vtiny = ' + cast(@vtiny as varchar(10));				-- null
print 'vnumeric = ' + cast(@vnumeric as varchar(20));

-- ex 2: �������� ��������

declare @capacity int = (select sum(AUDITORIUM.AUDITORIUM_CAPACITY) from AUDITORIUM),
		@count int,
		@avg numeric(8,2),
		@count_lesser int,
		@percentage numeric (5,2);

if @capacity >= 200 
	begin
		set @count = (select count(*) from AUDITORIUM)
		set @avg = (select avg(AUDITORIUM_CAPACITY) from AUDITORIUM);
		set @count_lesser = (select count(*) from AUDITORIUM where AUDITORIUM_CAPACITY < @avg);
		set @percentage = (cast(@count_lesser as numeric (5,2)) / cast(@count as numeric (5,2))) * 100;
		select @count '����� ���������', @avg '������� �����������', 
			@count_lesser '����������� < �������', @percentage '% ��������� ������ �������';
	end
else
	select @capacity '��������� �����������'

-- ex 3: ���������� ����������
print '����� ������������ �����: ';
print @@ROWCOUNT;
print '������ SQL Server: ';
print @@VERSION;
print '��������� ID ��������: ';
print @@SPID;
print '��� ��������� ������: ';
print @@ERROR;
print '��� �������: ';
print @@SERVERNAME;
print '������� ����������� ����������: ';
print @@TRANCOUNT;
print '�������� ���������� ���������� ����� ��������������� ������: ';
print @@FETCH_STATUS;
print '������� ����������� ������� ���������: ';
print @@NESTLEVEL;

-- ex 4.1: ���������
declare @zzz float, @ttt float, @xxx float;
select @ttt = 5.37, @xxx = 5.37;

if (@ttt > @xxx) set @zzz = power(sin(@ttt),2);
if (@ttt < @xxx) set @zzz = (4 * (@ttt + @xxx));
if (@ttt = @xxx) set @zzz = (1 - exp(@xxx - 2));
print 'z = ' + cast(@zzz as varchar(10));
select @zzz '4.1. Z = ';

-- ex 4.2: �������������� ������� ��� � ������� + ��������
declare @v_fio varchar(100) = (select top 1 STUDENT.NAME from STUDENT);
declare @v_fio_short varchar(50) = substring(@v_fio, 1, charindex(' ', @v_fio))
	+ substring(@v_fio, charindex(' ', @v_fio) + 1, 1) + '.'
	+ substring(@v_fio, charindex(' ', @v_fio, charindex(' ', @v_fio) + 1) + 1, 1) + '.';

select @v_fio '4.2. ������������ ���:', @v_fio_short '����������: ';

-- ex 4.3: ����� ���������, � ������� �� � ����. ������, � ����������� �� ��������;
select STUDENT.NAME as '4.3. ���', STUDENT.BDAY as '���� ��������',
	(datediff(year, STUDENT.BDAY, getdate())) as '�������'
from STUDENT
	where month(STUDENT.BDAY) = (month(getdate()) + 1);

-- ex 5
if ((select count(*) from AUDITORIUM) > 10)
	print '������� >= 10 ���������';
else 
	print '������� < 10 ���������';

-- ex 6
select 
	case 
	when PROGRESS.NOTE = 10 then '������������'
	when PROGRESS.NOTE between 7 and 9 then '�������'
	when PROGRESS.NOTE between 4 and 6 then '������'
	else '���'
	end '������', count(*) '����������'
from PROGRESS, STUDENT, GROUPS
where PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
	and STUDENT.IDGROUP = GROUPS.IDGROUP
	and GROUPS.FACULTY = '����'
group by
	case 
	when PROGRESS.NOTE = 10 then '������������'
	when PROGRESS.NOTE between 7 and 9 then '�������'
	when PROGRESS.NOTE between 4 and 6 then '������'
	else '���'
	end

-- ex 7: ��������� ��������� �������, ���������� ������ � while
drop table #EX7TABLE
create table #EX7TABLE
	(id int not null,
	name varchar(10) not null,
	age int not null);

set nocount on;
declare @cnt int = 0;
while (@cnt < 10)
	begin
		insert into #EX7TABLE values (@cnt, ('user' + cast(@cnt as varchar(2))), cast((floor(rand()*(60 - 18 + 1)) + 18) as int));
		set @cnt = @cnt + 1;
	end;
select * from #EX7TABLE

-- ex 9: try catch
begin try
	insert into #EX7TABLE values (null, null, null);
	print '����� ��������� � �������';
end try
begin catch
	print 'ERROR_NUMBER: ' + CONVERT(varchar, ERROR_NUMBER());
	print 'ERROR_MESSAGE: ' + ERROR_MESSAGE();
	print 'ERROR_LINE: ' + CONVERT(varchar, ERROR_LINE());
	print 'ERROR_PROCEDURE: ' + CONVERT(varchar, ERROR_PROCEDURE());
	print 'ERROR_SEVERITY: ' + CONVERT(varchar, ERROR_SEVERITY());
	print 'ERROR_STATE: ' + CONVERT(varchar, ERROR_STATE());
end catch

-- ex 8:
declare @ex8_cnt int = 0;
while @ex8_cnt < 10
	begin
		print 'x = ' + cast(@ex8_cnt as varchar(2));
		if (@ex8_cnt = 5) return;
		set @ex8_cnt = @ex8_cnt + 1;
	end;