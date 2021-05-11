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
		<Предмет код="ЭТ" полностью="Экономическая теория" кафедра="ЭТиМ"/>
		<Предмет код="ОЗИ" полностью="Основы защиты информации" кафедра="ИСиТ"/>
		<Предмет код="КГиГ" полностью="Компьютерная геометрия и графика" кафедра="ИСиТ"/>
	</Дисциплины>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/Дисциплины/Предмет',0)
	with([код] nvarchar(10), [полностью] nvarchar(70), [кафедра] nvarchar(10))
exec sp_xml_removedocument @h;
go