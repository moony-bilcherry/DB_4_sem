use [02_MyBase];

-- ex 4: READ UNCOMMITTED
				--- B ---	
-- 2
begin tran
select @@SPID
insert into ОТДЕЛЫ values ('Пёсиков', 15); 
update СОТРУДНИКИ set Предел_расхода = 1.52 where Имя_сотрудника = 'Алексей' 
-- 4
rollback tran;

-- ex 5: READ COMMITTED
				--- B ---	
-- 2
begin tran
delete from СОТРУДНИКИ where Имя_сотрудника = 'Алексей'

-- 4
rollback tran;

-- ex 6: REPEATABLE READ
				--- B ---
-- 2
begin tran
delete from СОТРУДНИКИ where Имя_сотрудника = 'Евгений';
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- 5
commit tran;

-- ex 7: SERIALIZABLE
				--- B ---
-- 2
begin tran
insert СОТРУДНИКИ values ('Сергей', 'Продаж', 64.92); 

-- 4
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;
commit tran;