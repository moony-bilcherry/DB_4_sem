use [02_MyBase]
go

-- ex 1: создание XML-дока в режиме PATH из таблицы СОТРУДНИКИ для сотрудников отдела PR
select * from СОТРУДНИКИ
where СОТРУДНИКИ.Отдел = 'PR'
for xml PATH('СОТРУДНИК'), root('СПИСОК_СОТРУДНИКОВ');
go

-- ex 2: режим AUTO, запрос к таблицам AUDITORIUM и AUDITORIUM_TYPE, найти только лекционные
select СОТРУДНИКИ.Имя_сотрудника, СОТРУДНИКИ.Предел_расхода, ОТДЕЛЫ.Название_отдела
from СОТРУДНИКИ inner join ОТДЕЛЫ
	on СОТРУДНИКИ.Отдел = ОТДЕЛЫ.Название_отдела
where ОТДЕЛЫ.Название_отдела like '%PR%'
for xml AUTO, root('ОТДЕЛ_PR'), elements;
go

-- ex 3: xml-док с тремя новыми дисциплинами для добавления
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<Люди>
		<Сотрудник имя="Юлия" отдел="PR" сумма="26.02"/>
		<Сотрудник имя="Аркадий" отдел="Безопасности" сумма="73.12"/>
		<Сотрудник имя="Енисей" отдел="HR" сумма="35.97"/>
	</Люди>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/Люди/Сотрудник',0)
	with([имя] nvarchar(20), [отдел] nvarchar(20), [сумма] real)

insert СОТРУДНИКИ select [имя], [отдел], [сумма]
	from openxml(@h, '/Люди/Сотрудник',0)
		with([имя] nvarchar(20), [отдел] nvarchar(20), [сумма] real)

select * from СОТРУДНИКИ
delete СОТРУДНИКИ where Имя_сотрудника in('Юлия', 'Аркадий', 'Енисей')

exec sp_xml_removedocument @h;
go