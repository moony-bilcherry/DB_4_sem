use [04_UNIVER]

-- ex 1
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
from AUDITORIUM inner join AUDITORIUM_TYPE
on AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE

-- ex 2
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM inner join AUDITORIUM_TYPE
on AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE and AUDITORIUM_TYPE.AUDITORIUM_TYPENAME like N'%���������%'

-- ex 3
select T1.AUDITORIUM, T2.AUDITORIUM_TYPENAME 
from AUDITORIUM as T1, AUDITORIUM_TYPE T2
where T1.AUDITORIUM_TYPE=T2.AUDITORIUM_TYPE

select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM, AUDITORIUM_TYPE 
where AUDITORIUM.AUDITORIUM_TYPE=AUDITORIUM_TYPE.AUDITORIUM_TYPE and AUDITORIUM_TYPE.AUDITORIUM_TYPENAME like N'%���������%'

-- ex 4 
select	FACULTY.FACULTY as '���������', 
		PULPIT.PULPIT as '�������',
		PROFESSION.PROFESSION as '�������������',
		[SUBJECT].SUBJECT as '����������',
		STUDENT.NAME as '��� ��������',
		case 
			when (PROGRESS.NOTE = 6) then '�����'
			when (PROGRESS.NOTE = 7) then '����'
			when (PROGRESS.NOTE = 8) then '������'
		end '������'
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
select	FACULTY.FACULTY as '���������', 
		PULPIT.PULPIT as '�������',
		PROFESSION.PROFESSION as '�������������',
		[SUBJECT].SUBJECT as '����������',
		STUDENT.NAME as '��� ��������',
		case 
			when (PROGRESS.NOTE = 6) then '�����'
			when (PROGRESS.NOTE = 7) then '����'
			when (PROGRESS.NOTE = 8) then '������'
		end '������'
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

-- ex 6 (������������� ������ ����� ������� - ��� �������)
select PULPIT.PULPIT_NAME as '6. �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT left outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 7.1 (�������� ������� ������� � ������ - ��� ������� � ���������)
select PULPIT.PULPIT_NAME as '7.1 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from TEACHER left outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 7.2 (������ - �� ��, ��� � � 6)
select PULPIT.PULPIT_NAME as '7.2 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from TEACHER right outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.1 (���-�� ���������������)
select PULPIT.PULPIT_NAME as '8.1.1 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

select PULPIT.PULPIT_NAME as '8.1.2 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from TEACHER full outer join PULPIT on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.2 (�������� � ���� inner join)
select PULPIT.PULPIT_NAME as '8.2 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT inner join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 8.3.1 (��� ����� null - ����� ���)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.1 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
where PULPIT.PULPIT_NAME is null and TEACHER.TEACHER_NAME is not null

-- ex 8.3.2 (��� ������ null)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.2 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
where PULPIT.PULPIT_NAME is not null and TEACHER.TEACHER_NAME is null

-- ex 8.3.3 (��� ��� �����-�� ���� �����)
select isnull(PULPIT.PULPIT_NAME , '***') as '8.3.3 �������', isnull(TEACHER.TEACHER_NAME, '***') as '�������������'
from PULPIT full outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT

-- ex 9 (cross join)
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPENAME
from AUDITORIUM cross join AUDITORIUM_TYPE 
where AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE