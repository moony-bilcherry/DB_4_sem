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
		<������� ���="��" ���������="���������" �������="����"/>
		<������� ���="���" ���������="������ ������ ����������" �������="����"/>
		<������� ���="����" ���������="������������ ��������� � �������" �������="����"/>
	</����������>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/����������/�������',0)
	with([���] nvarchar(10), [���������] nvarchar(70), [�������] nvarchar(10))

insert SUBJECT select [���], [���������], [�������]
	from openxml(@h, '/����������/�������',0)
		with([���] nvarchar(10), [���������] nvarchar(70), [�������] nvarchar(10))

select * from SUBJECT
delete SUBJECT where SUBJECT in('��', '���', '����')

exec sp_xml_removedocument @h;
go

-- ex 4
delete STUDENT where NAME = '�������� ��������� ����������';
select * from STUDENT where NAME = '�������� ��������� ����������';

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(17, '�������� ��������� ����������', '1995-04-09',
		'<�������>
		<������� �����="MP" �����="1234567" ����="01.03.2016" />
		<�������>1234567</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>���������</�����>
				<���>1</���>
				<��������>1</��������>
			</�����>
		</�������>');					 												    

update STUDENT set INFO = 
	'<�������>
	<������� �����="MP" �����="1234567" ����="01.03.2016" />
	<�������>1234567</�������>
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>���������</�����>
			<���>1</���>
			<��������>16</��������>
		</�����>
	</�������>'
where STUDENT.INFO.value('(/�������/�����/���)[1]','int') = 1;

select NAME, 
	INFO.value('(�������/�������/@�����)[1]', 'char(2)') '����� ��������',
	INFO.value('(�������/�������/@�����)[1]', 'varchar(10)') '����� ��������',
	INFO.query('/�������/�����') '�����'
from  STUDENT where NAME = '�������� ��������� ����������';
go

-- ex 5:
drop xml schema collection Student
go
create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="�������">  
		<xs:complexType>
			<xs:sequence>
				<xs:element name="�������" maxOccurs="1" minOccurs="1">
					<xs:complexType>
						<xs:attribute name="�����" type="xs:string" use="required" />
						<xs:attribute name="�����" type="xs:unsignedInt" use="required"/>
						<xs:attribute name="����"  use="required" >  
							<xs:simpleType> 
								<xs:restriction base ="xs:string">
									<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
								</xs:restriction>
							</xs:simpleType>
						</xs:attribute>
					</xs:complexType> 
				</xs:element>
				<xs:element maxOccurs="3" name="�������" type="xs:unsignedInt"/>
				<xs:element name="�����">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="������" type="xs:string" />
							<xs:element name="�����" type="xs:string" />
							<xs:element name="�����" type="xs:string" />
							<xs:element name="���" type="xs:string" />
							<xs:element name="��������" type="xs:string" />
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:schema>';

alter table STUDENT alter column INFO xml(Student);
insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'test','01.01.2000',
		'<�������>
			<������� �����="�B" �����="6799765" ����="25.10.2011"/>
			<�������>2434353</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>�����������</�����>
				<���>19</���>
				<��������>416</��������>
			</�����>
		</�������>');
insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'test2','01.01.2000',
		'<�������>
			<������� �����="�B" �����="6799765" ����="25.10.2011"/>
			<�������>2434fffffff353</�������>
			<�����>
				<������>��������</������>
				<�����>�����</�����>
				<�����>�����������</�����>
				<���>19</���>
				<��������>416</��������>
			</�����>
		</�������>');

delete STUDENT where NAME = 'test'
delete STUDENT where NAME = 'test2'
select * from STUDENT
go

-- ex 7: ����� � �����������
select rtrim(FACULTY.FACULTY) as '@���',
	(select COUNT(*) from PULPIT 
		where PULPIT.FACULTY = FACULTY.FACULTY) as '����������_������',
	(select rtrim(PULPIT.PULPIT) as '@���',
		(select rtrim(TEACHER.TEACHER) as '�������������/@���',
			TEACHER.TEACHER_NAME as '�������������'
		from TEACHER where TEACHER.PULPIT = PULPIT.PULPIT
		for xml path(''),type, root('�������������'))
	from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY 
		for xml path('�������'), type, root('�������')) 
from FACULTY
for xml path('���������'), type, root('�����������')
go