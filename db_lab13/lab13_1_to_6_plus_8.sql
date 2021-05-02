use [04_UNIVER]
go

drop procedure PSUBJECT;
go
-- ex 1: хранимая процедура без параметров, формирует результирующий набор на основе таблицы SUBJECT
create procedure PSUBJECT 
	as begin
		declare @num int = (select count(*) from SUBJECT);
		select * from SUBJECT;
		return @num;
	end;
go

declare @temp_1 int = 0;
exec @temp_1 = PSUBJECT;
print 'Количество дисциплин: ' + convert(varchar, @temp_1);
go

-- ex 2: изменить + параметры
alter procedure PSUBJECT @p varchar(20), @c int output
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print 'Параметры: @p = ' + @p + ', @c = ' + convert (varchar, @c);
		select * from SUBJECT where PULPIT = @p;
		set @c = @@ROWCOUNT;
		return @num;
	end;
go

declare @temp_2 int = 0, @out_2 int = 0;
exec @temp_2 = PSUBJECT 'ИСиТ', @out_2 output;
print 'Дисциплин всего: ' + convert(varchar, @temp_2);
print 'Дисциплин на кафедре ИСиТ: ' + convert(varchar, @out_2);
go

-- ex 3: временная локальная таблица, изменить процедуру, insert
alter procedure PSUBJECT @p varchar(20)
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print 'Параметры: @p = ' + @p;
		select * from SUBJECT where PULPIT = @p;
	end;
go

drop table #EX3;
create table #EX3 (
	sub nvarchar(10) primary key,
	sub_name nvarchar(50),
	pul nvarchar(50)
)

insert #EX3 exec PSUBJECT 'ИСиТ';
select * from #EX3;
go

-- ex 4:
drop procedure PAUDITORIUM_INSERT;
go
create procedure PAUDITORIUM_INSERT
	@a char(20), @n varchar(20), @c int = 0, @t char(10)
	as begin try
		insert into AUDITORIUM values (@a, @n, @c, @t);
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
exec @temp_4 = PAUDITORIUM_INSERT '131313-1', 'ЛК-К', 70, '13131313131313';
print 'Итог выполнения процедуры: ' + convert(varchar, @temp_4);
go

-- ex 5: вывести дисциплины на кафедре через запятую
drop procedure SUBJECT_REPORT
go
create procedure SUBJECT_REPORT
	@p char(10)
	as declare @rc int = 0;
	begin try
		if not exists (select SUBJECT from SUBJECT where PULPIT = @p)
			raiserror('Ошибка в параметрах', 11, 1);
		declare @subs_list char(300) = '', @sub char(10);
		declare SUBJECTS_LAB13 cursor for
			select SUBJECT from SUBJECT where PULPIT = @p;
		open SUBJECTS_LAB13;
		fetch SUBJECTS_LAB13 into @sub;
		while (@@FETCH_STATUS = 0)
			begin
				set @subs_list = rtrim(@sub) + ', ' + @subs_list;
				set @rc += 1;
				fetch SUBJECTS_LAB13 into @sub;
			end;
		print 'Дисциплины на кафедре ' + rtrim(@p) + ':';
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
exec @temp_5 = SUBJECT_REPORT 'ИСиТ';
print 'Количество дисциплин: ' + convert(varchar, @temp_5);
go

-- ex 6: транзакция serializable; @tn для AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
create procedure PAUDITORIUM_INSERTX
	@a char(20), @n varchar(20), @c int = 0, @t char(10), @tn varchar(50)
	as declare @rc int = 1;
	begin try
		
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
