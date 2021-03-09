use [04_UNIVER]

-- ex 1
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
from AUDITORIUM inner join AUDITORIUM_TYPE
on AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE

-- ex 2
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM inner join AUDITORIUM_TYPE
on AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE and AUDITORIUM_TYPE.AUDITORIUM_TYPENAME like N'%компьютер%'

-- ex 3
select T1.AUDITORIUM, T2.AUDITORIUM_TYPENAME 
from AUDITORIUM as T1, AUDITORIUM_TYPE T2
where T1.AUDITORIUM_TYPE=T2.AUDITORIUM_TYPE

select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM, AUDITORIUM_TYPE 
where AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE and AUDITORIUM_TYPE.AUDITORIUM_TYPENAME like N'%компьютер%'

-- ex 4 
select	FACULTY.FACULTY as 'Факультет', 
		PULPIT.PULPIT as 'Кафедра',
		PROFESSION.PROFESSION as 'Специальность',
		[SUBJECT].SUBJECT as 'Дисциплина',
		STUDENT.NAME as 'Имя студента',
		case 
			when (PROGRESS.NOTE = 6) then 'шесть'
			when (PROGRESS.NOTE = 7) then 'семь'
			when (PROGRESS.NOTE = 8) then 'восемь'
		end 'Оценка'
from PROGRESS 
		inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
		inner join [SUBJECT] on [SUBJECT].[SUBJECT] = PROGRESS.[SUBJECT]
		inner join GROUPS on GROUPS.IDGROUP = STUDENT.IDGROUP
		inner join PROFESSION on PROFESSION.PROFESSION = GROUPS.PROFESSION
		inner join PULPIT on PULPIT.PULPIT=[SUBJECT].PULPIT
		inner join FACULTY on FACULTY.FACULTY = PULPIT.FACULTY
where PROGRESS.NOTE between 6 and 8
order by PROGRESS.NOTE desc, FACULTY.FACULTY asc, PULPIT.PULPIT asc, PROFESSION.PROFESSION asc, STUDENT.NAME asc

-- ex 5
select	FACULTY.FACULTY as 'Факультет', 
		PULPIT.PULPIT as 'Кафедра',
		PROFESSION.PROFESSION as 'Специальность',
		[SUBJECT].SUBJECT as 'Дисциплина',
		STUDENT.NAME as 'Имя студента',
		case 
			when (PROGRESS.NOTE = 6) then 'шесть'
			when (PROGRESS.NOTE = 7) then 'семь'
			when (PROGRESS.NOTE = 8) then 'восемь'
		end 'Оценка'
from PROGRESS 
		inner join STUDENT on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
		inner join [SUBJECT] on [SUBJECT].[SUBJECT] = PROGRESS.[SUBJECT]
		inner join GROUPS on GROUPS.IDGROUP = STUDENT.IDGROUP
		inner join PROFESSION on PROFESSION.PROFESSION = GROUPS.PROFESSION
		inner join PULPIT on PULPIT.PULPIT=[SUBJECT].PULPIT
		inner join FACULTY on FACULTY.FACULTY = PULPIT.FACULTY
where PROGRESS.NOTE between 6 and 8
order by (case 
	when (PROGRESS.NOTE = 6) then 3
	when (PROGRESS.NOTE = 7) then 1
	when (PROGRESS.NOTE = 8) then 2
end)

-- ex 6 (несоединенные строки левой таблицы - все кафедры)
select PULPIT.PULPIT_NAME as '6. Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT left outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 7.1 (поменять местами таблицы в джоине - все преподы с кафедрами)
select PULPIT.PULPIT_NAME as '7.1 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from TEACHER left outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 7.2 (правый - то же, что и в 6)
select PULPIT.PULPIT_NAME as '7.2 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from TEACHER right outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.1 (док-во коммутативности)
select PULPIT.PULPIT_NAME as '8.1.1 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

select PULPIT.PULPIT_NAME as '8.1.2 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from TEACHER full outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.2 (содержит в себе inner join)
select PULPIT.PULPIT_NAME as '8.2 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT inner join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.3.1 (где левые null - таких нет)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.1 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
where PULPIT.PULPIT_NAME is null and TEACHER.TEACHER_NAME is not null

-- ex 8.3.2 (где правые null)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.2 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
where PULPIT.PULPIT_NAME is not null and TEACHER.TEACHER_NAME is null

-- ex 8.3.3 (еще раз зачем-то фулл аутер)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.3 Кафедра', isnull(TEACHER.TEACHER_NAME, '***') as 'Преподаватель'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 9 (cross join)
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM cross join AUDITORIUM_TYPE 
where AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE