use [02_MyBase]

select * from СОТРУДНИКИ
select * from ОТДЕЛЫ

-- ex 2: атомарность (выполняется все или ничего)
delete СОТРУДНИКИ where Имя_сотрудника = 'Александр';
insert into СОТРУДНИКИ values('Александр','Продаж',5.33);

begin try
	begin tran
		delete СОТРУДНИКИ where Имя_сотрудника = 'Александр';
		print '* Сотрудник удален';
		insert into СОТРУДНИКИ values('Александр','Продаж',5.33);
		print '* Сотрудник добавлен';
		update СОТРУДНИКИ set Предел_расхода = 1.99 where Имя_сотрудника='Александр';
		print '* Сотрудник изменен';
	commit tran;
end try
begin catch
	print 'ОШИБКА: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%PK_СОТРУДНИКИ%', ERROR_MESSAGE()) > 0
			then 'Дубликат'
			else 'НЕИЗВЕСТНАЯ ОШИБКА: ' + CAST(ERROR_NUMBER() as varchar(5)) + ERROR_MESSAGE()
		end;
	if @@TRANCOUNT > 0 rollback tran;
end catch;

-- ex 3: save tran
delete ОТДЕЛЫ where Название_отдела = 'Котиков';
insert into ОТДЕЛЫ values('Котиков',12);

declare @point varchar(32);
begin try
	begin tran
		delete ОТДЕЛЫ where Название_отдела = 'Котиков';
		print '* Отдел удален';
		set @point = 'p1'; save tran @point;
		insert into ОТДЕЛЫ values('Котиков',12);
		print '* Отдел добавлен';
		set @point = 'p2'; save tran @point;
		update ОТДЕЛЫ set Количество_сотрудников = 40 where Название_отдела='Котиков';
	commit tran;
end try
begin catch
	print 'ОШИБКА: ' + case
		when ERROR_NUMBER() = 2627 and PATINDEX('%PK_ОТДЕЛЫ%', ERROR_MESSAGE()) > 0
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

-- ex 4: 2 параллельных транзакции, READ UNCOMMITED
delete СОТРУДНИКИ where Имя_сотрудника = 'Алексей';
insert into СОТРУДНИКИ values('Алексей','Продаж',7.09);
				--- A ---
-- 1
set transaction isolation level READ UNCOMMITTED 
begin tran
-- 3
select @@SPID, 'insert ОТДЕЛЫ' 'результат', * 
	from ОТДЕЛЫ where Название_отдела = 'Пёсиков';
select @@SPID, 'update AUDITORIUM'  'результат', *
	from СОТРУДНИКИ where Имя_сотрудника = 'Алексей';
-- 5
commit tran; 

-- ex 5: READ COMMITTED 
				--- A ---
-- 1
set transaction isolation level READ COMMITTED;
begin tran
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- 3
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- 5
commit tran;

-- ex 6: REPEATABLE READ
insert СОТРУДНИКИ values ('Евгений', 'Продаж', 12.4); 
				--- A ---
-- 1
set transaction isolation level  REPEATABLE READ 
begin transaction 
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- 3
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;
commit tran; 

-- 4
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- ex 7: SERIALIZABLE
				--- A ---
-- 1
set transaction isolation level SERIALIZABLE
begin tran
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;

-- 3
select count(*) 'Кол-во сотрудников', @@TRANCOUNT '@@TRANCOUNT' from СОТРУДНИКИ;
commit tran;

delete from СОТРУДНИКИ where Имя_сотрудника = 'Сергей';