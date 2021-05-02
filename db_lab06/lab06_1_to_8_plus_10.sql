use [04_UNIVER]

-- ex 1: ������ ������, ������� ��������� �� ����������, �������������� ���������� �� ������������� 
-- � "����������" ��� "����������" � ��������. (��������������� ���������)
select FACULTY.FACULTY_NAME as '1. ���������', PULPIT.PULPIT_NAME as '�������'
from FACULTY, PULPIT
where FACULTY.FACULTY = PULPIT.FACULTY and PULPIT.FACULTY in (
	select PROFESSION.FACULTY 
	from PROFESSION 
	where (PROFESSION_NAME like '%����������%' or PROFESSION_NAME like '%����������%'))

-- ex 2 (�� �� � inner join)
select FACULTY.FACULTY_NAME as '2. ���������', PULPIT.PULPIT_NAME as '�������'
from FACULTY inner join PULPIT
on FACULTY.FACULTY = PULPIT.FACULTY and PULPIT.FACULTY in (
	select PROFESSION.FACULTY 
	from PROFESSION 
	where (PROFESSION_NAME like '%����������%' or PROFESSION_NAME like '%����������%'))

-- ex 3 (��� ����������, ������ inner join)
select distinct FACULTY.FACULTY_NAME as '3. ���������', PULPIT.PULPIT_NAME as '�������'
from FACULTY inner join PULPIT
	on FACULTY.FACULTY = PULPIT.FACULTY 
inner join PROFESSION  
	on FACULTY.FACULTY = PROFESSION.FACULTY 
	where PROFESSION_NAME like '%����������%' or PROFESSION_NAME like '%����������%'

-- ex 4: ������ ��������� ����� ������� ������������ ��� ������� ���� ���������. (������������� ���������)
select * from AUDITORIUM a
where AUDITORIUM_CAPACITY = (
	select top(1) AUDITORIUM_CAPACITY 
	from AUDITORIUM aa
	where aa.AUDITORIUM_TYPE = a.AUDITORIUM_TYPE 
	order by AUDITORIUM_CAPACITY desc)
order by AUDITORIUM_CAPACITY desc

-- ex 5: ������ �����������, �� ������� ��� �� ����� �������. (�������� EXISTS � ������������� ���������) 
select FACULTY_NAME as '��������� ��� ������' from FACULTY
where not exists (select * from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)

select FACULTY_NAME as '��������� � ���������' from FACULTY
where exists (select * from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY)

-- ex 6: ������������ ������, ���������� ������� �������� ������ �� ����, �� � ���� (3 ����������������� ����������, ���������� ������� AVG)
select top(1) 
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'����')[����],
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'��')[��],
	(select avg(NOTE) from PROGRESS 
		where PROGRESS.SUBJECT = N'����')[����]
from PROGRESS

-- ex 7: all (������ ���������, ��� ����������� >= ����. �� ��-�
select AUDITORIUM, AUDITORIUM_TYPE,AUDITORIUM_CAPACITY from AUDITORIUM 
where AUDITORIUM_CAPACITY >= all
	(select AUDITORIUM_CAPACITY from AUDITORIUM
	where AUDITORIUM_TYPE like '��-�')
order by AUDITORIUM_CAPACITY asc

select max(AUDITORIUM_CAPACITY) as '����. ����������� ��-�' from AUDITORIUM where AUDITORIUM_TYPE like '��-�'

-- ex 8: any (������ ���������, ��� ����������� > ���� �� 1 �� %��%
select AUDITORIUM, AUDITORIUM_TYPE,AUDITORIUM_CAPACITY from AUDITORIUM 
where AUDITORIUM_CAPACITY > any
	(select AUDITORIUM_CAPACITY from AUDITORIUM
	where AUDITORIUM_TYPE like '%��%')
order by AUDITORIUM_CAPACITY asc

select min(AUDITORIUM_CAPACITY) as '���. ����������� %��%' from AUDITORIUM where AUDITORIUM_TYPE like '%��%'

-- ex 10: ����� � ������� STUDENT ���������, � ������� ���� �������� � ���� ����
select a.IDSTUDENT, a.NAME, a.BDAY from STUDENT a
where a.BDAY = any 
	(select aa.BDAY from STUDENT aa 
	where a.IDSTUDENT != aa.IDSTUDENT) 
order by BDAY asc

select distinct s1.IDSTUDENT, s1.NAME, s1.BDAY 
from STUDENT s1 inner join STUDENT s2
	on s1.BDAY = s2.BDAY and s1.IDSTUDENT != s2.IDSTUDENT
order by s1.BDAY asc