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
delete AUDITORIUM where AUDITORIUM = '131313-1';
go
create procedure PAUDITORIUM_INSERT
	@a char(20), @n varchar(20), @c int = 0, @t char(10)
	as begin try
		insert into AUDITORIUM values (@a, @t, @c, @n);
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
exec @temp_4 = PAUDITORIUM_INSERT '131313-1', '13131313131313', 70, 'ЛК-К';
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
drop procedure PAUDITORIUM_INSERTX;
delete AUDITORIUM where AUDITORIUM_TYPE = 'ЛК-П';
delete AUDITORIUM_TYPE where AUDITORIUM_TYPE = 'ЛК-П';
go
create procedure PAUDITORIUM_INSERTX
	@a char(20), @n varchar(20), @c int = 0, @t char(10), @tn varchar(50)
	as declare @rc int = 1;
	begin try
		set transaction isolation level SERIALIZABLE
		begin tran
			insert into AUDITORIUM_TYPE values (@t, @tn);
			exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;
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
exec @temp_6 = PAUDITORIUM_INSERTX '136-1', '136-1', 36, 'ЛК-П', 'Поточная аудитория для лекций';
print 'Итог выполнения процедуры: ' + convert(varchar, @temp_6);
go

-- ex 8: возвращает количество кафедр в отчете
-- @fac не null и @pul null => отчет для конкретного факультета
-- @fac не null и @pul не null => отчет для конкретного факультета и кафедры
-- @fac null и не @pul null => отчет для кафедры, факультет вычисляется
-- @fac null и @pul null => полный отчет

drop procedure PRINT_REPORT;
go
create procedure PRINT_REPORT
	@fac char(10) = null, @pul char(10) = null
	as declare @faculty char(50), @pulpit char(10), @subject char(10), @cnt_teacher int;
		declare @temp_fac char(50), @temp_pul char(10), @list varchar(100), 
			@DISCIPLINES char(12) = 'Дисциплины: ', @DISCIPLINES_NONE char(16) = 'Дисциплины: нет.';
	begin try
		if (@pul is not null 
			and not exists (select FACULTY from PULPIT where PULPIT = @pul))
			raiserror('Ошибка в параметрах', 11, 1);

		declare @count int = 0;

		declare EX8 cursor local static 
			for select FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT, count(TEACHER.TEACHER)
			from FACULTY 
				inner join PULPIT on FACULTY.FACULTY = PULPIT.FACULTY
				left outer join SUBJECT on PULPIT.PULPIT = SUBJECT.PULPIT
				left outer join TEACHER on PULPIT.PULPIT = TEACHER.PULPIT
			where FACULTY.FACULTY = isnull(@fac, FACULTY.FACULTY)
				and PULPIT.PULPIT = isnull(@pul, PULPIT.PULPIT)
			group by FACULTY.FACULTY, PULPIT.PULPIT, SUBJECT.SUBJECT
			order by FACULTY asc, PULPIT asc, SUBJECT asc;

		open EX8;
			fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
			while @@FETCH_STATUS = 0
				begin 
					print 'Факультет ' + rtrim(@faculty) + ': ';
					set @temp_fac = @faculty;
					while (@faculty = @temp_fac)
						begin
							print char(9) + 'Кафедра ' + rtrim(@pulpit) + ': ';
							set @count += 1;
							print char(9) + char(9) + 'Количество преподавателей: ' + rtrim(@cnt_teacher) + '.';
							set @list = @DISCIPLINES;

							if(@subject is not null)
								begin
									if(@list = @DISCIPLINES)
										set @list += rtrim(@subject);
									else
										set @list += ', ' + rtrim(@subject);
								end;
							if (@subject is null) set @list = @DISCIPLINES_NONE;

							set @temp_pul = @pulpit;
							fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
							while (@pulpit = @temp_pul)
								begin
									if(@subject is not null)
										begin
											if(@list = @DISCIPLINES)
												set @list += rtrim(@subject);
											else
												set @list += ', ' + rtrim(@subject);
										end;
									fetch EX8 into @faculty, @pulpit, @subject, @cnt_teacher;
									if(@@FETCH_STATUS != 0) break;
								end;
							if(@list != @DISCIPLINES_NONE)
								set @list += '.';
							print char(9) + char(9) + @list;
							if(@@FETCH_STATUS != 0) break;
						end;
				end;
		close EX8;
		deallocate EX8;
		return @count;
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

declare @temp_8_1 int;
exec @temp_8_1 = PRINT_REPORT null, null;
select @temp_8_1;

declare @temp_8_2 int;
exec @temp_8_2 = PRINT_REPORT 'ИТ', null;
select @temp_8_2;

declare @temp_8_3 int;
exec @temp_8_3 = PRINT_REPORT null, 'ПОиСОИ';
select @temp_8_3;

declare @temp_8_4 int;
exec @temp_8_4 = PRINT_REPORT null, 'testing';
select @temp_8_4;