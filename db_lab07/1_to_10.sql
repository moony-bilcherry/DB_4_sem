use [04_UNIVER]

-- ex 1: запрос, вычисляющий максимальную, минимальную, среднюю, суммарную вместимость всех аудиторий и их кол-во
select min(AUDITORIUM_CAPACITY) [мин. вместимость],
	max(AUDITORIUM_CAPACITY) [макс. вместимость],
	avg(AUDITORIUM_CAPACITY) [средняя],
	sum(AUDITORIUM_CAPACITY) [суммарная],
	count(*) [кол-во аудиторий]
from AUDITORIUM

-- ex 2: то же для каждого типа аудиторий
select AUDITORIUM_TYPE.AUDITORIUM_TYPENAME as 'Тип аудитории',
	min(AUDITORIUM_CAPACITY) [мин. вместимость],
	max(AUDITORIUM_CAPACITY) [макс. вместимость],
	avg(AUDITORIUM_CAPACITY) [средняя],
	sum(AUDITORIUM_CAPACITY) [суммарная],
	count(*) [кол-во аудиторий]
from AUDITORIUM inner join AUDITORIUM_TYPE
	on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
group by AUDITORIUM_TYPENAME

-- ex 3: количество экзаменационных оценок в заданном интервале (10, 8-9, 6-7, 4-5)
select * from
	(select case 
		when NOTE = 10 then '10'
		when NOTE in(8, 9) then '8-9'
		when NOTE in(6, 7) then '6-7'
		when NOTE in(4, 5) then '4-5'
		else '<4' end [Оценки], count(*) [Количество]
	from PROGRESS group by case 
		when NOTE = 10 then '10'
		when NOTE in(8, 9) then '8-9'
		when NOTE in(6, 7) then '6-7'
		when NOTE in(4, 5) then '4-5'
		else '<4' end) as A
	order by case [Оценки]
		when '10' then 1
		when '8-9' then 2
		when '6-7' then 3
		when '4-5' then 4
		else 5 end

-- ex 4.1: запрос (FACULTY, GROUPS, STUDENT, PROGRESS) со средней экзаменационной оценкой для каждого курса каждой специальности
select FACULTY.FACULTY as '4.1 Факультет', 
	GROUPS.PROFESSION as 'Специальность', 
	(GROUPS.YEAR_FIRST - 2010 + 1 ) as 'курс',
	round(avg(cast(PROGRESS.NOTE as float(4))), 2) as 'Средний балл'
from STUDENT inner join PROGRESS
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
inner join GROUPS
	on GROUPS.IDGROUP = STUDENT.IDGROUP
inner join FACULTY
	on FACULTY.FACULTY = GROUPS.FACULTY
group by FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
order by 'Средний балл' desc

-- ex 4.2: оценки только по БД и ОАиП
select FACULTY.FACULTY as '4.2 Факультет', 
	GROUPS.PROFESSION as 'Специальность', 
	(GROUPS.YEAR_FIRST - 2010 + 1 ) as 'курс',
	round(avg(cast(PROGRESS.NOTE as float(4))), 2) as 'Средний балл'
from STUDENT inner join PROGRESS
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
inner join GROUPS
	on GROUPS.IDGROUP = STUDENT.IDGROUP
inner join FACULTY
	on FACULTY.FACULTY = GROUPS.FACULTY
where (PROGRESS.SUBJECT = 'БД' or PROGRESS.SUBJECT = 'ОАиП')
group by FACULTY.FACULTY, GROUPS.PROFESSION, GROUPS.YEAR_FIRST
order by 'Средний балл' desc

-- ex 5: специальность, дисциплины и средние оценки при сдаче экзаменов на факультете ТОВ
select GROUPS.FACULTY as '5. Факультет',
	GROUPS.PROFESSION as 'Специальность', 
	PROGRESS.SUBJECT as 'Предмет', 
	round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
from GROUPS inner join STUDENT
	on GROUPS.IDGROUP = STUDENT.IDGROUP
inner join PROGRESS
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where GROUPS.FACULTY = 'ТОВ'
group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT

-- ex 5.1: 5 + rollup
select GROUPS.PROFESSION as '5.1 Специальность', 
	PROGRESS.SUBJECT as 'Предмет', 
	round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
from GROUPS inner join STUDENT
	on GROUPS.IDGROUP = STUDENT.IDGROUP
inner join PROGRESS
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where GROUPS.FACULTY = 'ТОВ'
group by rollup (GROUPS.PROFESSION, PROGRESS.SUBJECT)

-- ex 6: 5 + cube
select GROUPS.PROFESSION as '6. Специальность', 
	PROGRESS.SUBJECT as 'Предмет', 
	round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
from GROUPS inner join STUDENT
	on GROUPS.IDGROUP = STUDENT.IDGROUP
inner join PROGRESS
	on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
where GROUPS.FACULTY = 'ТОВ'
group by cube (GROUPS.PROFESSION, PROGRESS.SUBJECT)

-- ex 7.1: тов + хтит (union)
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ТОВ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT
union
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ХТиТ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT

-- ex 7.2: тов + хтит (union all)
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ТОВ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT
union all
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ХТиТ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT

-- union отличается тем, что исключает строки-дупликаты, типа как distinct. union all - просто механическое объединение

-- ex 8: intersect (пересечений в этих таблицах нет, поэтому пусто)
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ТОВ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT
intersect
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ХТиТ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT

-- ex 9: except (рез. набор = строки 1 таблицы кроме строк 2 таблицы)
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ТОВ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT
except
	select GROUPS.FACULTY,
		GROUPS.PROFESSION as 'Специальность', 
		PROGRESS.SUBJECT as 'Предмет', 
		round(avg(cast(PROGRESS.NOTE as float(4))), 2) [Средний балл]
	from GROUPS inner join STUDENT
		on GROUPS.IDGROUP = STUDENT.IDGROUP
	inner join PROGRESS
		on PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT
	where GROUPS.FACULTY = 'ХТиТ'
	group by GROUPS.FACULTY, GROUPS.PROFESSION, PROGRESS.SUBJECT

-- ex 10: определить для каждой дисциплины кол-во студентов, получивших 8 и 9
select p1.SUBJECT as '10. Предмет', 
	p1.NOTE as 'Оценка', 
	(select count(*) from PROGRESS p2
	where p2.SUBJECT = p1.SUBJECT and p2.NOTE = p1.NOTE) as 'Количество'
from PROGRESS p1
group by p1.SUBJECT, p1.NOTE
having NOTE in (8, 9)

-- ex 12.1: Подсчитать кол-во студентов в каждой группе, на каждом факультете
-- и всего в университете одним запросом
select GROUPS.FACULTY as 'Факультет', 
	STUDENT.IDGROUP as 'Группа',
	count(STUDENT.IDSTUDENT) as 'Кол-во студентов'
from STUDENT, GROUPS
where GROUPS.IDGROUP = STUDENT.IDGROUP
group by rollup (GROUPS.FACULTY, STUDENT.IDGROUP)

-- ex 12.2: Подсчитать кол-во аудиторий по типам и вместимости
-- в корпусах и всего одним запросом
select AUDITORIUM_TYPE as 'Тип аудитории', 
	AUDITORIUM_CAPACITY as 'Вместимость',
	case 
		when AUDITORIUM.AUDITORIUM like '%-1' then '1'
		when AUDITORIUM.AUDITORIUM like '%-2' then '2'
		when AUDITORIUM.AUDITORIUM like '%-3' then '3'
		when AUDITORIUM.AUDITORIUM like '%-3a' then '3a'
		when AUDITORIUM.AUDITORIUM like '%-4' then '4'
		when AUDITORIUM.AUDITORIUM like '%-5' then '5'
	end 'Корпус', 
	count(*) as 'Количество'
from AUDITORIUM 
group by AUDITORIUM_TYPE, AUDITORIUM_CAPACITY,
	case 
		when AUDITORIUM.AUDITORIUM like '%-1' then '1'
		when AUDITORIUM.AUDITORIUM like '%-2' then '2'
		when AUDITORIUM.AUDITORIUM like '%-3' then '3'
		when AUDITORIUM.AUDITORIUM like '%-3a' then '3a'
		when AUDITORIUM.AUDITORIUM like '%-4' then '4'
		when AUDITORIUM.AUDITORIUM like '%-5' then '5'
	end with rollup