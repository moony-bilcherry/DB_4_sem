use [04_UNIVER]
go

-- ex 1: представление преподаватель: select к TEACHER и сод. столбцы: TEACHER, TEACHER_NAME, GENDER, PULPIT
drop view Преподаватель
go
create view Преподаватель
		as select TEACHER.TEACHER [код],
			TEACHER.TEACHER_NAME [имя],
			TEACHER.GENDER [пол],
			TEACHER.PULPIT [кафедра]
		from TEACHER
go
select * from Преподаватель order by кафедра


-- ex 2: количество кафедр, таблицы FACULTY и PULPIT
drop view Количество_кафедр
go
create view Количество_кафедр
		as select FACULTY.FACULTY_NAME [факультет],
			count(PULPIT.FACULTY) [количество]
		from FACULTY join PULPIT
			on FACULTY.FACULTY = PULPIT.FACULTY
		group by FACULTY.FACULTY_NAME
go
select * from Количество_кафедр

-- ex 3: аудитории, показать допустимость insert, update, delete
drop view Аудитории
go
create view Аудитории
	as select AUDITORIUM.AUDITORIUM [код],
		AUDITORIUM.AUDITORIUM_NAME [наименование],
		AUDITORIUM.AUDITORIUM_TYPE [тип]
	from AUDITORIUM
	where AUDITORIUM_TYPE like '%ЛК%'
go
select * from Аудитории;

insert into Аудитории values ('test', 'test_name', 'ЛК')
select * from Аудитории;

update Аудитории
	 set код = 'UPDATE' where наименование = 'test_name'
select * from Аудитории;

delete from Аудитории where код = 'UPDATE';
select * from Аудитории

-- ex 4: то же, что в 3 задании + with check option
drop view Аудитории_ЛК
go
create view Аудитории_ЛК
	as select AUDITORIUM.AUDITORIUM [код],
		AUDITORIUM.AUDITORIUM_NAME [наименование],
		AUDITORIUM.AUDITORIUM_TYPE [тип]
	from AUDITORIUM
	where AUDITORIUM_TYPE like '%ЛК%' with check option
go
select * from Аудитории_ЛК;
-- из-за with check option не удасться запустить сценарий со строкой ниже: 'ЛБ-К' не подх. под условие
--insert into Аудитории_ЛК values ('test', 'test_name', 'ЛБ-К')

-- ex 5: дисциплины. top + order by
drop view Дисциплины
go
create view Дисциплины (КОД, ДИСЦИПЛИНА, КОД_КАФЕДРЫ)
	as select top 50 SUBJECT, SUBJECT_NAME, PULPIT
	from SUBJECT
	order by SUBJECT
go
select * from Дисциплины

-- ex 6: изменить Количество_кафедр с помощью schemabinding
go
alter view Количество_кафедр with schemabinding
	as select FACULTY.FACULTY_NAME [факультет],
			count(PULPIT.FACULTY) [количество]
		from dbo.FACULTY join dbo.PULPIT
			on FACULTY.FACULTY = PULPIT.FACULTY
		group by FACULTY.FACULTY_NAME
go
select * from Количество_кафедр

-- ex 8: представление для таблицы TIMETABLE (лаба 6) в виде расписания + pivot
-- PIVOT(агрегатная функция
-- FOR столбец, содержащий значения, которые станут именами столбцов
-- IN ([значения по горизонтали],…)
-- )AS псевдоним таблицы (обязательно)
drop view Расписание
go
create view Расписание
	as select top(100) [День], [Пара], [1 группа], [2 группа], [4 группа], [5 группа], [6 группа], [7 группа], [8 группа], [9 группа], [10 группа]
		from (select top(100) DAY_NAME [День],
				convert(varchar, LESSON) [Пара],
				convert(varchar, IDGROUP) + ' группа' [Группа],
				[SUBJECT] + ' ' + AUDITORIUM [Дисциплина и аудитория]
			from TIMETABLE) tbl
		pivot
			(max([Дисциплина и аудитория]) 
			for [Группа]
			in ([1 группа], [2 группа], [4 группа], [5 группа], [6 группа], [7 группа], [8 группа], [9 группа], [10 группа])
			) as pvt
			order by 
				(case
					 when [День] like 'пн' then 1
					 when [День] like 'вт' then 2
					 when [День] like 'ср' then 3
					 when [День] like 'чт' then 4
					 when [День] like 'пт' then 5
					 when [День] like 'сб' then 6
				 end), [Пара] asc
go
select * from Расписание
