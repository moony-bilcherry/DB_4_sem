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

-- ex 6
drop function dbo.FACULTY_REPORT;
drop function dbo.COUNT_PULPIT;
drop function dbo.COUNT_GROUPS;
drop function dbo.COUNT_PROFESSION;
go

create function COUNT_PULPIT(@faculty varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(*) from PULPIT
			where PULPIT.FACULTY = @faculty)
		return @rc;
	end;
go

create function COUNT_GROUPS(@faculty varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(*) from GROUPS
			where GROUPS.FACULTY = @faculty)
		return @rc;
	end;
go

create function COUNT_PROFESSION(@faculty varchar(20)) returns int
	as begin
		declare @rc int = 0;
		set @rc = (select count(*) from PROFESSION
			where PROFESSION.FACULTY = @faculty)
		return @rc;
	end;
go

go
create function FACULTY_REPORT(@c int) returns @fr table
	([���������] varchar(50), 
	[���������� ������] int, 
	[���������� �����] int, 
	[���������� ���������] int, 
	[���������� ��������������] int)
	as begin 
		declare cc cursor local static for 
			select FACULTY from FACULTY where dbo.COUNT_STUDENTS(FACULTY.FACULTY) > @c; 
		declare @f varchar(30);
		open cc;  
			fetch cc into @f;
		while @@fetch_status = 0
			begin
				insert @fr values(
				@f,  
				dbo.COUNT_PULPIT(@f),
	            dbo.COUNT_GROUPS(@f),   
				dbo.COUNT_STUDENTS(@f),
				dbo.COUNT_PROFESSION(@f)); 
	            fetch cc into @f;  
			end;   
		close cc;
		deallocate cc;
		return; 
	end;
go

select * from dbo.FACULTY_REPORT(0);
go

-- ex 7
drop procedure PRINT_REPORTX;
go

create procedure PRINT_REPORTX
	@fac char(10) = null, @pul char(10) = null
	as declare @faculty char(50), @pulpit char(10), @subject char(100), @cnt_teacher int;
		declare @temp_fac char(50), @temp_pul char(10), @list varchar(100), 
			@DISCIPLINES char(12) = '����������: ', @DISCIPLINES_NONE char(16) = '����������: ���.';
	begin try
		if (@pul is not null 
			and not exists (select FACULTY from PULPIT where PULPIT = @pul))
			raiserror('������ � ����������', 11, 1);

		declare @count int = 0;

		declare EX8 cursor local static 
			for select func.FACULTY, 
				func.PULPIT, 
				dbo.FSUBJECTS(func.PULPIT) [����������], 
				dbo.FCTEACHER(func.PULPIT) [���-�� ��������������]
			from dbo.FFACPUL(null, null) func
				left outer join SUBJECT on func.PULPIT = SUBJECT.PULPIT
				left outer join TEACHER on func.PULPIT = TEACHER.PULPIT
			where func.FACULTY = isnull(@fac, func.FACULTY)
				and func.PULPIT = isnull(@pul, func.PULPIT)
			group by func.FACULTY, func.PULPIT, dbo.FSUBJECTS(func.PULPIT)
			order by func.FACULTY asc, func.PULPIT asc, dbo.FSUBJECTS(func.PULPIT) asc;

		open EX8;
			fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
			while @@FETCH_STATUS = 0
				begin 
					print '��������� ' + rtrim(@faculty) + ': ';
					set @temp_fac = @faculty;
					while (@faculty = @temp_fac)
						begin
							print char(9) + '������� ' + rtrim(@pulpit) + ': ';
							set @count += 1;
							print char(9) + char(9) + '���������� ��������������: ' + rtrim(@cnt_teacher) + '.';
							set @list = @DISCIPLINES;

							if(@subject = @DISCIPLINES)
								set @list = @DISCIPLINES_NONE;
							else 
								set @list = @subject;
							if (@subject is null) set @list = @DISCIPLINES_NONE;

							set @temp_pul = @pulpit;
							fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
							print char(9) + char(9) + @list;
							if(@@FETCH_STATUS != 0) break;
						end;
				end;
		close EX8;
		deallocate EX8;
		return @count;
	end try
	begin catch
		print '����� ������: ' + convert(varchar, error_number());
		print '���������: ' + error_message();
		print '�������: ' + convert(varchar, error_severity());
		print '�����: ' + convert(varchar, error_state());
		print '����� ������: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print '��� ���������: ' + error_procedure();
		return -1;
	end catch;
go

declare @temp_8_1 int;
exec @temp_8_1 = PRINT_REPORTX null, null;
select @temp_8_1;

exec PRINT_REPORTX '��', null;
exec PRINT_REPORTX null, '������';
exec PRINT_REPORTX null, 'testing';