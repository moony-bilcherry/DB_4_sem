use [04_UNIVER]
go

-- ex 1: ������������� �������������: select � TEACHER � ���. �������: TEACHER, TEACHER_NAME, GENDER, PULPIT
drop view �������������
go
create view �������������
		as select TEACHER.TEACHER [���],
			TEACHER.TEACHER_NAME [���],
			TEACHER.GENDER [���],
			TEACHER.PULPIT [�������]
		from TEACHER
go
select * from ������������� order by �������


-- ex 2: ���������� ������, ������� FACULTY � PULPIT
drop view ����������_������
go
create view ����������_������
		as select FACULTY.FACULTY_NAME [���������],
			count(PULPIT.FACULTY) [����������]
		from FACULTY join PULPIT
			on FACULTY.FACULTY = PULPIT.FACULTY
		group by FACULTY.FACULTY_NAME
go
select * from ����������_������

-- ex 3: ���������, �������� ������������ insert, update, delete
drop view ���������
go
create view ���������
	as select AUDITORIUM.AUDITORIUM [���],
		AUDITORIUM.AUDITORIUM_NAME [������������],
		AUDITORIUM.AUDITORIUM_TYPE [���]
	from AUDITORIUM
	where AUDITORIUM_TYPE like '%��%'
go
select * from ���������;

insert into ��������� values ('test', 'test_name', '��')
select * from ���������;

update ���������
	 set ��� = 'UPDATE' where ������������ = 'test_name'
select * from ���������;

delete from ��������� where ��� = 'UPDATE';
select * from ���������

-- ex 4: �� ��, ��� � 3 ������� + with check option
drop view ���������_��
go
create view ���������_��
	as select AUDITORIUM.AUDITORIUM [���],
		AUDITORIUM.AUDITORIUM_NAME [������������],
		AUDITORIUM.AUDITORIUM_TYPE [���]
	from AUDITORIUM
	where AUDITORIUM_TYPE like '%��%' with check option
go
select * from ���������_��;
-- ��-�� with check option �� �������� ��������� �������� �� ������� ����: '��-�' �� ����. ��� �������
--insert into ���������_�� values ('test', 'test_name', '��-�')

-- ex 5: ����������. top + order by
drop view ����������
go
create view ���������� (���, ����������, ���_�������)
	as select top 50 SUBJECT, SUBJECT_NAME, PULPIT
	from SUBJECT
	order by SUBJECT
go
select * from ����������

-- ex 6: �������� ����������_������ � ������� schemabinding
go
alter view ����������_������ with schemabinding
	as select FACULTY.FACULTY_NAME [���������],
			count(PULPIT.FACULTY) [����������]
		from dbo.FACULTY join dbo.PULPIT
			on FACULTY.FACULTY = PULPIT.FACULTY
		group by FACULTY.FACULTY_NAME
go
select * from ����������_������