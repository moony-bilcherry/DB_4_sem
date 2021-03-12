use [04_UNIVER]

-- ex 1: наличие свободных аудиторий на определенную пару
select AUDITORIUM as 'Аудитория, свободные на 1 паре в пн'
from AUDITORIUM a
except 
	(select a.AUDITORIUM
	from TIMETABLE T1, AUDITORIUM a
	where T1.DAY_NAME = 'пн' and T1.LESSON = 1 and a.AUDITORIUM = T1.AUDITORIUM)
order by AUDITORIUM asc

-- ex 2: на определенный день недели

select AUDITORIUM as 'Аудитории, свободные в пн'
from AUDITORIUM a
except 
	(select a.AUDITORIUM
	from TIMETABLE T1, AUDITORIUM a
	where T1.DAY_NAME = 'пн' and a.AUDITORIUM = T1.AUDITORIUM)
order by AUDITORIUM asc

-- ex3: наличие «окон» у преподавателей
select distinct T.TEACHER_NAME as 'Преподаватель', T1.DAY_NAME as 'День недели', T1.LESSON as 'Занятая пара'
from TEACHER T, TIMETABLE T1, TIMETABLE T2
where T.TEACHER = T1.TEACHER and T1.DAY_NAME = T2.DAY_NAME and T1.LESSON != T2.LESSON
order by T.TEACHER_NAME asc, T1.DAY_NAME desc, T1.LESSON asc

select distinct T.TEACHER_NAME as 'Преподаватель', T1.DAY_NAME as 'День недели', T1.LESSON as '"окна"'
from TEACHER T, TIMETABLE T1, TIMETABLE T2
except 
	(select distinct T.TEACHER_NAME, T1.DAY_NAME, T1.LESSON
	from TEACHER T, TIMETABLE T1, TIMETABLE T2
	where T.TEACHER = T1.TEACHER and T1.DAY_NAME = T2.DAY_NAME and T1.LESSON != T2.LESSON)
order by T.TEACHER_NAME asc, T1.DAY_NAME desc, T1.LESSON asc

-- ex 4: окна у групп

select distinct GROUPS.IDGROUP as 'Группа', T1.DAY_NAME as 'День недели', T1.LESSON as 'Занятая пара'
from GROUPS, TIMETABLE T1, TIMETABLE T2
where GROUPS.IDGROUP = T1.IDGROUP and T1.DAY_NAME = T2.DAY_NAME and T1.LESSON != T2.LESSON
order by GROUPS.IDGROUP asc, T1.DAY_NAME desc, T1.LESSON asc

select distinct GROUPS.IDGROUP as 'Группа', T1.DAY_NAME as 'День недели', T1.LESSON as '"окна"'
from GROUPS, TIMETABLE T1, TIMETABLE T2
except
	(select distinct GROUPS.IDGROUP, T1.DAY_NAME, T1.LESSON
	from GROUPS, TIMETABLE T1, TIMETABLE T2
	where GROUPS.IDGROUP = T1.IDGROUP and T1.DAY_NAME = T2.DAY_NAME and T1.LESSON != T2.LESSON)
order by GROUPS.IDGROUP asc, T1.DAY_NAME desc, T1.LESSON asc