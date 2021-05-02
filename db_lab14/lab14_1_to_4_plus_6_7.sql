use [04_UNIVER]
go

-- ex 1.1: ��������� �������, ��������� ���-�� ��������� ���������� �� ����
drop function dbo.COUNT_STUDENTS;
go
create function COUNT_STUDENTS(@faculty varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(STUDENT.IDSTUDENT)
			from FACULTY 
				inner join GROUPS on GROUPS.FACULTY = FACULTY.FACULTY
				inner join STUDENT on STUDENT.IDGROUP = GROUPS.IDGROUP
			where FACULTY.FACULTY = @faculty)
		return @rc;
	end;
go

declare @temp_1 int = dbo.COUNT_STUDENTS('����');
print '���������� ���������: ' + convert(varchar, @temp_1);

select FACULTY '���������', 
	dbo.COUNT_STUDENTS(FACULTY) '���-�� ���������'
from FACULTY
go

-- ex 1.2: �������� �������, �������� �������� @prof
alter function dbo.COUNT_STUDENTS(@faculty varchar(20), @prof varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(STUDENT.IDSTUDENT)
			from FACULTY 
				inner join GROUPS on GROUPS.FACULTY = FACULTY.FACULTY
				inner join STUDENT on STUDENT.IDGROUP = GROUPS.IDGROUP
			where FACULTY.FACULTY = @faculty and GROUPS.PROFESSION = @prof)
		return @rc;
	end;
go
declare @temp_1 int = dbo.COUNT_STUDENTS('����', '1-40 01 02');
print '���������� ���������: ' + convert(varchar, @temp_1);

select FACULTY.FACULTY '���������', 
	GROUPS.PROFESSION '�������������',
	dbo.COUNT_STUDENTS(FACULTY.FACULTY, GROUPS.PROFESSION) '���-�� ���������'
from FACULTY 
	inner join GROUPS on GROUPS.FACULTY = FACULTY.FACULTY
group by FACULTY.FACULTY, GROUPS.PROFESSION
go

-- ex 2: 
drop function dbo.FSUBJECTS;
go
create function FSUBJECTS(@p varchar(20)) returns varchar(300)
	as begin
		declare @list varchar(300) = '����������: ', @sub varchar(20);
			declare LAB14_EX2 cursor local
				for select SUBJECT.SUBJECT
					from SUBJECT
					where SUBJECT.PULPIT = @p;
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

print dbo.FSUBJECTS('����');
select PULPIT '�������', 
	dbo.FSUBJECTS(PULPIT) '����������'
from PULPIT;
go

-- ex 3: ��������� �������
drop function dbo.FFACPUL;
go
create function FFACPUL(@fac varchar(10), @pul varchar(10)) returns table
	as return 
		select FACULTY.FACULTY, PULPIT.PULPIT
		from FACULTY left outer join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
		where FACULTY.FACULTY = isnull(@fac, FACULTY.FACULTY)
			and PULPIT.PULPIT = isnull(@pul, PULPIT.PULPIT);
go

select * from dbo.FFACPUL(null,null);
select * from dbo.FFACPUL('����',null);
select * from dbo.FFACPUL(null,'����');
select * from dbo.FFACPUL('����','�����');
select * from dbo.FFACPUL('lorem','ipsum');
go

-- ex 4: ���������, ������� ���������� �������� �� �������
drop function dbo.FCTEACHER;
go
create function FCTEACHER(@pul varchar(10)) returns int
	as begin
		declare @rc int = (select count(*)
			from TEACHER
			where TEACHER.PULPIT = isnull(@pul, TEACHER.PULPIT));
		return @rc;
	end;
go

select PULPIT '�������', 
	dbo.FCTEACHER(PULPIT) '���-�� ��������������'
from PULPIT;
select dbo.FCTEACHER(null) '����� ��������������';
go
