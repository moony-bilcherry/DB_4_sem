use [04_UNIVER]
go

-- ex 1: �������� XML-���� � ������ PATH �� ������� TEACHER ��� �������������� ������� ����
select * from TEACHER
where TEACHER.PULPIT = '����'
for xml PATH('TEACHER'), root('TEACHER_LIST');
go

-- ex 2: ����� AUTO, ������ � �������� AUDITORIUM � AUDITORIUM_TYPE, ����� ������ ����������
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPE, AUDITORIUM.AUDITORIUM_CAPACITY
from AUDITORIUM inner join AUDITORIUM_TYPE
	on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
where AUDITORIUM.AUDITORIUM_TYPE like '%��%'
for xml AUTO, root('LECTURE_AUDITORIUMS'), elements;
go

-- ex 3: xml-��� � ����� ������ ������������ ��� ����������
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<����������>
		<������� ���="��" ���������="������������� ������" �������="����"/>
		<������� ���="���" ���������="������ ������ ����������" �������="����"/>
		<������� ���="����" ���������="������������ ��������� � �������" �������="����"/>
	</����������>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/����������/�������',0)
	with([���] nvarchar(10), [���������] nvarchar(70), [�������] nvarchar(10))
exec sp_xml_removedocument @h;
go