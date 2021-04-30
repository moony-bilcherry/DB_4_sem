use [04_UNIVER]

-- ex 1: список дисциплин на кафедре ИСиТ в одну строку через запятую
declare EX1_ISIT cursor 
	for select SUBJECT
	from SUBJECT
	where SUBJECT.PULPIT='ИСиТ'; 
declare @sub char(30), @out char(500) = '';
	open EX1_ISIT;
		fetch EX1_ISIT into @sub;
		print 'Дисциплины на кафедре ИСиТ: ';
		while @@FETCH_STATUS = 0
		begin
			set @out = RTRIM(@sub) +', ' +  @out;
			FETCH  EX1_ISIT into @sub;
		end;
		print @out;
	close EX1_ISIT;
	deallocate EX1_ISIT;

-- ex 2: отличие глобального курсора от локального
declare EX2_LOCAL cursor local
	for select AUDITORIUM, AUDITORIUM_CAPACITY 
	from AUDITORIUM
declare @aud char(10), @cap int;
	open EX2_LOCAL;
		fetch EX2_LOCAL into @aud, @cap;
		print '[LOCAL] 1. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	go
-- ОШИБКА: курсор EX2_LOCAL не существует
--declare @aud char(10), @cap int;
--		fetch EX2_LOCAL into @aud, @cap;
--		print '[LOCAL] 2. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
--	go

declare EX2_GLOBAL cursor global
	for select AUDITORIUM, AUDITORIUM_CAPACITY 
	from AUDITORIUM
declare @aud char(10), @cap int;
	open EX2_GLOBAL;
		fetch EX2_GLOBAL into @aud, @cap;
		print '[GLOBAL] 1. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	go
declare @aud char(10), @cap int;
		fetch EX2_GLOBAL into @aud, @cap;
		print '[GLOBAL] 2. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	close EX2_GLOBAL;
	deallocate EX2_GLOBAL;
	go

-- ex 3: отличие статического курсора от динамического
declare EX3_TEACHER cursor local static
	for select PULPIT, GENDER, TEACHER_NAME
	from TEACHER
	where PULPIT = 'ИСиТ';
declare @pul char(10), @gen char(1), @name char(50);
	open EX3_TEACHER;
		print 'Количество строк: ' + convert(varchar, @@CURSOR_ROWS);
		insert into TEACHER values ('ЙГР', 'Эрен', 'м', 'ИСиТ');
		update TEACHER set TEACHER_NAME = 'Йегер Эрен Григорьевич' where TEACHER = 'ЙГР';
		fetch EX3_TEACHER into @pul, @gen, @name;
		while @@FETCH_STATUS = 0
		begin
			print rtrim(@pul) + ' ' + @gen + ' ' + rtrim(@name);
			fetch EX3_TEACHER into @pul, @gen, @name;
		end;
	close EX3_TEACHER;
delete TEACHER where TEACHER = 'ЙГР';
go

-- ex 4: scroll запрос
declare EX4_SCROLL cursor local dynamic scroll
	for select ROW_NUMBER() over (order by NAME asc) N, NAME
	from STUDENT
declare @num int, @name char(50);
	open EX4_SCROLL;
		fetch last from EX4_SCROLL into @num, @name;
		print char(9) + 'LAST:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch first from EX4_SCROLL into @num, @name;
		print char(9) + 'FIRST:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch next from EX4_SCROLL into @num, @name;
		print char(9) + 'NEXT:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch absolute 20 from EX4_SCROLL into @num, @name;
		print char(9) + 'ABSOLUTE 20:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch relative 10 from EX4_SCROLL into @num, @name;
		print char(9) + 'RELATIVE 10:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch prior from EX4_SCROLL into @num, @name;
		print char(9) + 'PRIOR:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch absolute -20 from EX4_SCROLL into @num, @name;
		print char(9) + 'ABSOLUTE -20:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch relative -10 from EX4_SCROLL into @num, @name;
		print char(9) + 'RELATIVE -10:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
	close EX4_SCROLL;
go

-- ex 5: current of
insert into FACULTY values ('TEST', 'testing current of'); 

declare EX5_CURRENT cursor local scroll dynamic
	for select FACULTY, FACULTY_NAME 
	from FACULTY
	for update; 
declare @fac varchar(5), @full varchar(50); 
	open EX5_CURRENT 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		update FACULTY set FACULTY = 'YEAH' where current of EX5_CURRENT; 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		delete FACULTY where current of EX5_CURRENT;
	close EX5_CURRENT;
go

-- ex 6.1: из таблицы PROGRESS удаляются строки с оценками <4  (объединение PROGRESS, STUDENT, GROUPS)
insert into PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE) values 
	('КГ',   1026,  '06.05.2013',3),
	('КГ',   1027,  '06.05.2013',2),
	('КГ',   1028,  '06.05.2013',2),
	('КГ',   1029,  '06.05.2013',3),
	('КГ',   1030,  '06.05.2013',1),
	('КГ',   1031,  '06.05.2013',3)

select NAME, NOTE 
from PROGRESS 
	inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where NOTE < 4

declare EX6_1 cursor local 
	for	select NAME, NOTE 
	from PROGRESS 
		inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where NOTE < 4
declare @student nvarchar(20), @mark int;  
	open EX6_1;  
		fetch  EX6_1 into @student, @mark;
		while @@FETCH_STATUS = 0
			begin 		
				delete PROGRESS where current of EX6_1;	
				fetch  EX6_1 into @student, @mark;  
			end
	close EX6_1;
		
insert into PROGRESS (SUBJECT, IDSTUDENT, PDATE, NOTE) values ('КГ',   1025,  '06.05.2013',3)
select NAME, NOTE 
from PROGRESS inner join STUDENT
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where NOTE<4

go
		
-- ex 6.2: +1 к оценке конкретного студента (IDSTUDENT) - id 1025
declare EX6_2 cursor local 
	for	select NAME, NOTE 
	from PROGRESS 
		inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where PROGRESS.IDSTUDENT = 1025;
declare @student nvarchar(20), @mark int;  
	open EX6_2;  
		fetch  EX6_2 into @student, @mark;
		update PROGRESS set NOTE = NOTE + 1 where CURRENT OF EX6_2;
	close EX6_2;

select NAME, NOTE 
from PROGRESS inner join STUDENT
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where PROGRESS.IDSTUDENT = 1025

update PROGRESS set NOTE = NOTE - 1 where IDSTUDENT = 1025;
go

-- ex 8:
select count(*) from PULPIT
select FACULTY.FACULTY_NAME, PULPIT.PULPIT, SUBJECT.SUBJECT, count(TEACHER.TEACHER)
	from FACULTY 
		inner join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
		left outer join SUBJECT on PULPIT.PULPIT = SUBJECT.PULPIT
		left outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
	group by FACULTY.FACULTY_NAME, PULPIT.PULPIT, SUBJECT.SUBJECT
	order by FACULTY_NAME asc, PULPIT asc, SUBJECT asc;

declare EX8 cursor local static 
	for select FACULTY.FACULTY_NAME, PULPIT.PULPIT, SUBJECT.SUBJECT, count(TEACHER.TEACHER)
	from FACULTY 
		inner join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
		left outer join SUBJECT on PULPIT.PULPIT = SUBJECT.PULPIT
		left outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
	group by FACULTY.FACULTY_NAME, PULPIT.PULPIT, SUBJECT.SUBJECT
	order by FACULTY_NAME asc, PULPIT asc, SUBJECT asc;
declare @faculty char(50), @pulpit char(10), @subject char(10), @cnt_teacher int;
declare @temp_fac char(50), @temp_pul char(10), @list varchar(100), @DISCIPLINES char(12) = 'Дисциплины: ', @DISCIPLINES_NONE char(16) = 'Дисциплины: нет.';
	open EX8;
		fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
		while @@FETCH_STATUS = 0
			begin
				print 'Факультет ' + rtrim(@faculty) + ': ';
				set @temp_fac = @faculty;
				while (@faculty = @temp_fac)
					begin
						print char(9) + 'Кафедра ' + rtrim(@pulpit) + ': ';
						print char(9) + char(9) + 'Количество преподавателей: ' + rtrim(@cnt_teacher) + '.';
						set @list = @DISCIPLINES;
						if(@subject is not null)
							begin
								if(@list = @DISCIPLINES)
									set @list += rtrim(@subject);
								else
									set @list += ', ' + rtrim(@subject);
							end;
						if (@subject is null) set @list = @DISCIPLINES_NONE;

						set @temp_pul = @pulpit;
						fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;

						--if (@subject is null and @list != '' and @list != @DISCIPLINES_NONE)
						--	set @list += '.';
						while (@pulpit = @temp_pul)
							begin
								if(@subject is not null)
									begin
										if(@list = @DISCIPLINES)
											set @list += rtrim(@subject);
										else
											set @list += ', ' + rtrim(@subject);
									end;
								fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
								--if (@subject is null and @list != '' and @list != @DISCIPLINES_NONE)
								--	set @list += '.';
								if(@@FETCH_STATUS != 0) break;
							end;
						if(@list != @DISCIPLINES_NONE)
							set @list += '.';
						print char(9) + char(9) + @list;
						if(@@FETCH_STATUS != 0) break;
					end;
			end;
	close EX8;
	deallocate EX8;
go