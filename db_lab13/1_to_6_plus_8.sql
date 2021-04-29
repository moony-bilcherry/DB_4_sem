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

-- ex 3: