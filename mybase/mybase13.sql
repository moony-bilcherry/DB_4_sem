use [02_MyBase]
go

drop procedure PWORKERS;
go
-- ex 1: количество сотрудников
create procedure PWORKERS
	as begin
		declare @num int = (select count(*) from СОТРУДНИКИ);
		select  * from СОТРУДНИКИ;
		return @num;
	end;
go

declare @temp_1 int = 0;
exec @temp_1 = PWORKERS;
print 'Количество сотрудников: ' + convert(varchar, @temp_1);
go

-- ex 2: изменить + параметры
alter procedure PWORKERS @p varchar(20), @c int output
	as begin
		declare @num int = (select count(*) from СОТРУДНИКИ);
		print 'Параметры: @p = ' + @p + ', @c = ' + convert (varchar, @c);
		select * from СОТРУДНИКИ where Отдел = @p;
		set @c = @@ROWCOUNT;
		return @num;
	end;
go

declare @temp_2 int = 0, @out_2 int = 0;
exec @temp_2 = PWORKERS 'PR', @out_2 output;
print 'Сотрудников всего: ' + convert(varchar, @temp_2);
print 'Сотрудников отдела PR: ' + convert(varchar, @out_2);
go

-- ex 3: временная локальная таблица, изменить процедуру, insert
alter procedure PWORKERS @p varchar(20)
	as begin
		declare @num int = (select count(*) from СОТРУДНИКИ);
		print 'Параметры: @p = ' + @p;
		select * from СОТРУДНИКИ where Отдел = @p;
	end;
go

drop table #EX3;
create table #EX3 (
	sub nvarchar(10) primary key,
	sub_name nvarchar(50),
	pul nvarchar(50)
)

insert #EX3 exec PWORKERS 'PR';
select * from #EX3;
go

-- ex 4:
select * from СОТРУДНИКИ
drop procedure PWORKER_INSERT;
delete СОТРУДНИКИ where Имя_сотрудника = 'Ольга';
go
create procedure PWORKER_INSERT
	@name char(20), @tospend real = 0, @dep char(20)
	as begin try
		insert into СОТРУДНИКИ values (@name, @dep, @tospend);
		return 1;
	end try
	begin catch
		print 'Номер ошибки: ' + convert(varchar, error_number());
		print 'Сообщение: ' + error_message();
		print 'Уровень: ' + convert(varchar, error_severity());
		print 'Метка: ' + convert(varchar, error_state());
		print 'Номер строки: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print 'Имя процедуры: ' + error_procedure();
		return -1;
	end catch;
go

declare @temp_4 int;
exec @temp_4 = PWORKER_INSERT 'Ольга', 13.40, 'PR';
print 'Итог выполнения процедуры: ' + convert(varchar, @temp_4);
go

-- ex 5: вывести дисциплины на кафедре через запятую
drop procedure WORKERS_REPORT
go
create procedure WORKERS_REPORT
	@p char(20)
	as declare @rc int = 0;
	begin try
		if not exists (select Имя_сотрудника from СОТРУДНИКИ where Отдел = @p)
			raiserror('Ошибка в параметрах', 11, 1);
		declare @subs_list char(300) = '', @sub char(20);
		declare SUBJECTS_LAB13 cursor for
			select Имя_сотрудника from СОТРУДНИКИ where Отдел = @p;
		open SUBJECTS_LAB13;
			fetch SUBJECTS_LAB13 into @sub;
			while (@@FETCH_STATUS = 0)
				begin
					set @subs_list = rtrim(@sub) + ', ' + @subs_list;
					set @rc += 1;
					fetch SUBJECTS_LAB13 into @sub;
				end;
			print 'Сотрудники отдела ' + rtrim(@p) + ':';
			print rtrim(@subs_list);
		close SUBJECTS_LAB13;
		deallocate SUBJECTS_LAB13;
		return @rc;
	end try
	begin catch
		print 'Номер ошибки: ' + convert(varchar, error_number());
		print 'Сообщение: ' + error_message();
		print 'Уровень: ' + convert(varchar, error_severity());
		print 'Метка: ' + convert(varchar, error_state());
		print 'Номер строки: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print 'Имя процедуры: ' + error_procedure();
		return @rc;
	end catch;
go

declare @temp_5 int;
exec @temp_5 = WORKERS_REPORT 'PR';
print 'Кол-во сотрудников в отделе PR: ' + convert(varchar, @temp_5);
go

-- ex 6: транзакция serializable; @depsize для AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
drop procedure PWORKER_INSERTX;
delete СОТРУДНИКИ where Отдел = 'Какой-то';
delete ОТДЕЛЫ where Название_отдела = 'Какой-то';
go
create procedure PWORKER_INSERTX
	@name char(20), @tospend real = 0, @dep char(20), @depsize int
	as declare @rc int = 1;
	begin try
		set transaction isolation level SERIALIZABLE
		begin tran
			insert into ОТДЕЛЫ values (@dep, @depsize);
			exec @rc = PWORKER_INSERT @name, @tospend, @dep;
		commit tran
		return @rc
	end try
	begin catch
		print 'Номер ошибки: ' + convert(varchar, error_number());
		print 'Сообщение: ' + error_message();
		print 'Уровень: ' + convert(varchar, error_severity());
		print 'Метка: ' + convert(varchar, error_state());
		print 'Номер строки: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print 'Имя процедуры: ' + error_procedure();
		if @@TRANCOUNT > 0
			rollback tran;
		return -1;
	end catch;
go

declare @temp_6 int;
exec @temp_6 = PWORKER_INSERTX 'Валерия', 13.80, 'Какой-то', 24;
print 'Итог выполнения процедуры: ' + convert(varchar, @temp_6);
go

select * from ОТДЕЛЫ
select * from СОТРУДНИКИ