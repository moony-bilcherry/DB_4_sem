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