use [04_UNIVER];

-- ex 4: READ UNCOMMITTED
				--- B ---	
-- 2
begin tran
select @@SPID
insert SUBJECT values ('ОЗИ', 'Основы защиты информации', 'ИСиТ'); 
update AUDITORIUM set AUDITORIUM_CAPACITY = 50 where AUDITORIUM = '222-1' 
-- 4
rollback tran;

-- ex 5: READ COMMITTED
				--- B ---	
-- 2
begin tran
delete from AUDITORIUM where AUDITORIUM = '222-1'

-- 4
rollback tran;

-- ex 6: REPEATABLE READ
				--- B ---
-- 2
begin tran
delete from AUDITORIUM where AUDITORIUM = '126-1';
select count(*) 'Кол-во аудиторий', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;
--insert AUDITORIUM values ('126-2', 'ЛБ-К', 12,'126-2'); 

-- 5
commit tran;

-- ex 7: SERIALIZABLE
				--- B ---
-- 2
begin tran
insert AUDITORIUM values ('127-1', 'ЛБ-К', 12,'127-1'); 

-- 4
select count(*) 'Кол-во аудиторий', @@TRANCOUNT '@@TRANCOUNT' from AUDITORIUM;
commit tran;