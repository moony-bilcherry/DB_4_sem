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

-- ex 2: показать свойство атомарности явной транзакции (выполняется все или ничего)
delete AUDITORIUM where AUDITORIUM_NAME = '222-1';
insert into AUDITORIUM values('222-1','ЛБ-К','15','222-1');

begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '222-1';
		print '* Аудитория удалена';
		insert into AUDITORIUM values('222-1','ЛБ-К','15','222-1');
		print '* Аудитория добавлена';
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='222-1';
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

-- ex 3: save tran
delete AUDITORIUM where AUDITORIUM_NAME = '333-1';
insert into AUDITORIUM values('333-1','ЛБ-К','15','333-1');

declare @point varchar(32);
begin try
	begin tran
		delete AUDITORIUM where AUDITORIUM_NAME = '333-1';
		print '* Аудитория удалена';
		set @point = 'p1'; save tran @point;
		insert into AUDITORIUM values('333-1','ЛБ-К','15','333-1');
		print '* Аудитория добавлена';
		set @point = 'p2'; save tran @point;
		update AUDITORIUM set AUDITORIUM_CAPACITY = '30' where AUDITORIUM_NAME='333-1';
	commit tran;
end try
begin catch
	print 'ОШИБКА: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%AUDITORIUM_PK%', ERROR_MESSAGE()) > 0
			then 'Дубликат'
			else 'НЕИЗВЕСТНАЯ ОШИБКА: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if (@@TRANCOUNT > 0) 
		begin
			print 'Контрольная точка: ' + @point;
			rollback tran @point;
			commit tran;
		end;
end catch;

-- ex 4: 2 сценария