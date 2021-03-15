use [04_UNIVER]

-- ex 1: список кафедр, которые находятся на факультете, обеспечивающем подготовку по специальности 
-- с "технология" или "технологии" в названии. (некоррелирующий подзапрос)
select FACULTY.FACULTY_NAME as '1. Факультет', PULPIT.PULPIT_NAME as 'Кафедра'
from FACULTY, PULPIT
where FACULTY.FACULTY = PULPIT.FACULTY and PULPIT.FACULTY in (
	select PROFESSION.FACULTY 
	from PROFESSION 
	where (PROFESSION_NAME like '%технология%' or PROFESSION_NAME like '%технологии%'))

-- ex 2 (то же с inner join)
select FACULTY.FACULTY_NAME as '2. Факультет', PULPIT.PULPIT_NAME as 'Кафедра'
from FACULTY inner join PULPIT
on FACULTY.FACULTY = PULPIT.FACULTY and PULPIT.FACULTY in (
	select PROFESSION.FACULTY 
	from PROFESSION 
	where (PROFESSION_NAME like '%технология%' or PROFESSION_NAME like '%технологии%'))

-- ex 3 (без подзапроса, второй inner join)
select distinct FACULTY.FACULTY_NAME as '3. Факультет', PULPIT.PULPIT_NAME as 'Кафедра'
from FACULTY inner join PULPIT
	on FACULTY.FACULTY = PULPIT.FACULTY 
inner join PROFESSION  
	on FACULTY.FACULTY = PROFESSION.FACULTY 
	where PROFESSION_NAME like '%технология%' or PROFESSION_NAME like '%технологии%'

-- ex 4: список аудиторий самых больших вместимостей для каждого типа аудитории. (коррелирующий подзапрос)
select * from AUDITORIUM a
where AUDITORIUM_CAPACITY = (
	select top(1) AUDITORIUM_CAPACITY 
	from AUDITORIUM aa
	where aa.AUDITORIUM_TYPE = a.AUDITORIUM_TYPE 
	order by AUDITORIUM_CAPACITY desc)
order by AUDITORIUM_CAPACITY desc

-- ex 5: список факультетов, на которых нет ни одной кафедры. (предикат EXISTS и коррелирующий подзапрос) 
select FACULTY_NAME as 'Факультет без кафедр' from FACULTY
where not exists (select * from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)

select FACULTY_NAME as 'Факультет с кафедрами' from FACULTY
where exists (select * from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)

-- ex 6: сформировать строку, содержащую средние значения оценок по ОАиП, БД и СУБД (3 некоррелированных подзапроса, агрегатные функции AVG)
select top(1) 
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'ОАиП')[ОАиП],
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'БД')[БД],
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'СУБД')[СУБД]
from PROGRESS

-- ex 7: all (список аудиторий, где вместимость >= макс. из ЛК-К
select AUDITORIUM, AUDITORIUM_TYPE,AUDITORIUM_CAPACITY from AUDITORIUM 
where AUDITORIUM_CAPACITY >= all
	(select AUDITORIUM_CAPACITY from AUDITORIUM
	where AUDITORIUM_TYPE like 'ЛК-К')
order by AUDITORIUM_CAPACITY asc

select max(AUDITORIUM_CAPACITY) as 'макс. вместимость ЛК-К' from AUDITORIUM where AUDITORIUM_TYPE like 'ЛК-К'

-- ex 8: any (список аудиторий, где вместимость > хотя бы 1 из %ЛБ%
select AUDITORIUM, AUDITORIUM_TYPE,AUDITORIUM_CAPACITY from AUDITORIUM 
where AUDITORIUM_CAPACITY > any
	(select AUDITORIUM_CAPACITY from AUDITORIUM
	where AUDITORIUM_TYPE like '%ЛБ%')
order by AUDITORIUM_CAPACITY asc

select min(AUDITORIUM_CAPACITY) as 'мин. вместимость %ЛБ%' from AUDITORIUM where AUDITORIUM_TYPE like '%ЛБ%'

-- ex 10: Найти в таблице STUDENT студентов, у которых день рождения в один день
select a.IDSTUDENT, a.NAME, a.BDAY from STUDENT a
where a.BDAY = any 
	(select aa.BDAY from STUDENT aa 
	where a.IDSTUDENT != aa.IDSTUDENT) 
order by BDAY asc

select distinct s1.IDSTUDENT, s1.NAME, s1.BDAY 
from STUDENT s1 inner join STUDENT s2
	on s1.BDAY = s2.BDAY and s1.IDSTUDENT != s2.IDSTUDENT
order by s1.BDAY asc