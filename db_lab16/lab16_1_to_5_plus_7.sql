use [04_UNIVER]
go

-- ex 1: создание XML-дока в режиме PATH из таблицы TEACHER для преподавателей кафедры ИСиТ
select * from TEACHER
where TEACHER.PULPIT = 'ИСиТ'
for xml PATH('TEACHER'), root('TEACHER_LIST');
go

-- ex 2: режим AUTO, запрос к таблицам AUDITORIUM и AUDITORIUM_TYPE, найти только лекционные
select AUDITORIUM.AUDITORIUM, AUDITORIUM_TYPE.AUDITORIUM_TYPE, AUDITORIUM.AUDITORIUM_CAPACITY
from AUDITORIUM inner join AUDITORIUM_TYPE
	on AUDITORIUM.AUDITORIUM_TYPE = AUDITORIUM_TYPE.AUDITORIUM_TYPE
where AUDITORIUM.AUDITORIUM_TYPE like '%ЛК%'
for xml AUTO, root('LECTURE_AUDITORIUMS'), elements;
go

-- ex 3: xml-док с тремя новыми дисциплинами для добавления
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<Дисциплины>
		<Предмет код="ЭК" полностью="Экономика" кафедра="ЭТиМ"/>
		<Предмет код="ОЗИ" полностью="Основы защиты информации" кафедра="ИСиТ"/>
		<Предмет код="КГиГ" полностью="Компьютерная геометрия и графика" кафедра="ИСиТ"/>
	</Дисциплины>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/Дисциплины/Предмет',0)
	with([код] nvarchar(10), [полностью] nvarchar(70), [кафедра] nvarchar(10))

insert SUBJECT select [код], [полностью], [кафедра]
	from openxml(@h, '/Дисциплины/Предмет',0)
		with([код] nvarchar(10), [полностью] nvarchar(70), [кафедра] nvarchar(10))

select * from SUBJECT
delete SUBJECT where SUBJECT in('ЭК', 'ОЗИ', 'КГиГ')

exec sp_xml_removedocument @h;
go

-- ex 4
delete STUDENT where NAME = 'Качанова Анастасия Васильевна';
select * from STUDENT where NAME = 'Качанова Анастасия Васильевна';

insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(17, 'Качанова Анастасия Васильевна', '1995-04-09',
		'<студент>
		<паспорт серия="MP" номер="1234567" дата="01.03.2016" />
		<телефон>1234567</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Свердлова</улица>
				<дом>1</дом>
				<квартира>1</квартира>
			</адрес>
		</студент>');					 												    

update STUDENT set INFO = 
	'<студент>
	<паспорт серия="MP" номер="1234567" дата="01.03.2016" />
	<телефон>1234567</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Минск</город>
			<улица>Свердлова</улица>
			<дом>1</дом>
			<квартира>16</квартира>
		</адрес>
	</студент>'
where STUDENT.INFO.value('(/студент/адрес/дом)[1]','int') = 1;

select NAME, 
	INFO.value('(студент/паспорт/@серия)[1]', 'char(2)') 'Серия паспорта',
	INFO.value('(студент/паспорт/@номер)[1]', 'varchar(10)') 'Номер паспорта',
	INFO.query('/студент/адрес') 'Адрес'
from  STUDENT where NAME = 'Качанова Анастасия Васильевна';
go

-- ex 5:
drop xml schema collection Student
go
create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="студент">  
		<xs:complexType>
			<xs:sequence>
				<xs:element name="паспорт" maxOccurs="1" minOccurs="1">
					<xs:complexType>
						<xs:attribute name="серия" type="xs:string" use="required" />
						<xs:attribute name="номер" type="xs:unsignedInt" use="required"/>
						<xs:attribute name="дата"  use="required" >  
							<xs:simpleType> 
								<xs:restriction base ="xs:string">
									<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
								</xs:restriction>
							</xs:simpleType>
						</xs:attribute>
					</xs:complexType> 
				</xs:element>
				<xs:element maxOccurs="3" name="телефон" type="xs:unsignedInt"/>
				<xs:element name="адрес">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="страна" type="xs:string" />
							<xs:element name="город" type="xs:string" />
							<xs:element name="улица" type="xs:string" />
							<xs:element name="дом" type="xs:string" />
							<xs:element name="квартира" type="xs:string" />
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
		'<студент>
			<паспорт серия="НB" номер="6799765" дата="25.10.2011"/>
			<телефон>2434353</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Белорусская</улица>
				<дом>19</дом>
				<квартира>416</квартира>
			</адрес>
		</студент>');
insert STUDENT(IDGROUP, NAME, BDAY, INFO) values
	(18,'test2','01.01.2000',
		'<студент>
			<паспорт серия="НB" номер="6799765" дата="25.10.2011"/>
			<телефон>2434fffffff353</телефон>
			<адрес>
				<страна>Беларусь</страна>
				<город>Минск</город>
				<улица>Белорусская</улица>
				<дом>19</дом>
				<квартира>416</квартира>
			</адрес>
		</студент>');

delete STUDENT where NAME = 'test'
delete STUDENT where NAME = 'test2'
select * from STUDENT
go

-- ex 7: отчет о факультетах
select rtrim(FACULTY.FACULTY) as '@код',
	(select COUNT(*) from PULPIT 
		where PULPIT.FACULTY = FACULTY.FACULTY) as 'количество_кафедр',
	(select rtrim(PULPIT.PULPIT) as '@код',
		(select rtrim(TEACHER.TEACHER) as 'преподаватель/@код',
			TEACHER.TEACHER_NAME as 'преподаватель'
		from TEACHER where TEACHER.PULPIT = PULPIT.PULPIT
		for xml path(''),type, root('преподаватели'))
	from PULPIT where PULPIT.FACULTY = FACULTY.FACULTY 
		for xml path('кафедра'), type, root('кафедры')) 
from FACULTY
for xml path('факультет'), type, root('университет')
go