use [04_UNIVER];

-- ex 1: неявная транзакция
set nocount on;
if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	drop table EX1_T;

declare @c int, @flag char = 'r';
set implicit_transactions on;
create table EX1_T (val int);
insert EX1_T values (1), (2), (3);
set @c = (select count(*) from EX1_T);
print 'Кол-во строк в таблице EX1_T: ' + convert(varchar, @c);
if @flag = 'c' 
	commit;
else 
	rollback;
set implicit_transactions off;

if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	print 'Таблица EX1_T есть';
else
	print 'Таблицы EX1_T нет';

if exists (select * from sys.objects where OBJECT_ID = object_id(N'dbo.EX1_T'))
	drop table EX1_T;

-- ex 2: показать свойство атомарности явной транзакции
insert into AUDITORIUM values('666-1','ЛБ-К','15','666-1');

begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '666-1';
		print '* Аудитория удалена';
		insert into AUDITORIUM values('666-1','ЛБ-К','15','666-1');
		print '* Аудитория добавлена';
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='666-1';
		print '* Аудитория изменена';
	commit tran;
end try
begin catch
	print 'ОШИБКА: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%AUDITORIUM_PK%', ERROR_MESSAGE()) > 0
			then 'Дубликат'
			else 'НЕИЗВЕСТНАЯ ОШИБКА: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if @@TRANCOUNT > 0 rollback tran;
end catch;

delete AUDITORIUM where AUDITORIUM_NAME = '666-1';

-- ex 3: