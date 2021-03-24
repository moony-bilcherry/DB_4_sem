use [04_UNIVER]

-- ex 1
declare @vchar char(2) = 'hi',
		@vvarchar varchar(9) = 'Note',
		@vdate datetime,
		@vtime time,
		@vint int,
		@vsmall smallint,
		@vtiny tinyint,
		@vnumeric numeric(12,5);

set @vdate = getdate();
select @vtime = '12:59:34';

select @vint = 434635, @vsmall = 3562, @vnumeric  = 1234567.12345;
select @vchar vchar, @vvarchar vvarchar, @vdate vdate, @vtime vtime;

print 'vint = ' + cast(@vint as varchar(10));
print 'vsmall = ' + cast(@vsmall as varchar(10));
print 'vtiny = ' + cast(@vtiny as varchar(10));				-- null
print 'vnumeric = ' + cast(@vnumeric as varchar(20));

-- ex 2: условный оператор

declare @capacity int = (select sum(AUDITORIUM.AUDITORIUM_CAPACITY) from AUDITORIUM),
		@count int,
		@avg numeric(8,2),
		@count_lesser int,
		@percentage numeric (5,2);

if @capacity >= 200 
	begin
		set @count = (select count(*) from AUDITORIUM)
		set @avg = (select avg(AUDITORIUM_CAPACITY) from AUDITORIUM);
		set @count_lesser = (select count(*) from AUDITORIUM where AUDITORIUM_CAPACITY < @avg);
		set @percentage = (cast(@count_lesser as numeric (5,2)) / cast(@count as numeric (5,2))) * 100;
		select @count 'всего аудитории', @avg 'средняя вместимость', 
			@count_lesser 'вместимость < средней', @percentage '% аудиторий меньше средней';
	end
else
	select @capacity 'суммарная вместимость'

-- ex 3: глобальные переменные
print 'Число обработанных строк: ';
print @@ROWCOUNT;
print 'Версия SQL Server: ';
print @@VERSION;
print 'Системный ID процесса: ';
print @@SPID;
print 'Код последней ошибки: ';
print @@ERROR;
print 'Имя сервера: ';
print @@SERVERNAME;
print 'Уровень вложенности транзакции: ';
print @@TRANCOUNT;
print 'Проверка результата считывания строк результирующего набора: ';
print @@FETCH_STATUS;
print 'Уровень вложенности текущей процедуры: ';
print @@NESTLEVEL;

-- ex 4.1: уравнение
declare @zzz float, @ttt float, @xxx float;
select @ttt = 5.37, @xxx = 5.37;

if (@ttt > @xxx) set @zzz = power(sin(@ttt),2);
if (@ttt < @xxx) set @zzz = (4 * (@ttt + @xxx));
if (@ttt = @xxx) set @zzz = (1 - exp(@xxx - 2));
print 'z = ' + cast(@zzz as varchar(10));
select @zzz '4.1. Z = ';

-- ex 4.2: преобразование полного ФИО в фамилия + инициалы
declare @v_fio varchar(100) = (select top 1 STUDENT.NAME from STUDENT);
declare @v_fio_short varchar(50) = substring(@v_fio, 1, charindex(' ', @v_fio))
	+ substring(@v_fio, charindex(' ', @v_fio) + 1, 1) + '.'
	+ substring(@v_fio, charindex(' ', @v_fio, charindex(' ', @v_fio) + 1) + 1, 1) + '.';

select @v_fio '4.2. Оригинальное ФИО:', @v_fio_short 'Сокращенно: ';

-- ex 4.3: поиск студентов, у которых ДР в след. месяце, и определение их возраста;
select STUDENT.NAME as '4.3. ФИО', STUDENT.BDAY as 'Дата рождения',
	(datediff(year, STUDENT.BDAY, getdate())) as 'Возраст'
from STUDENT
	where month(STUDENT.BDAY) = (month(getdate()) + 1);

-- ex 5
if ((select count(*) from AUDITORIUM) > 10)
	print 'Имеется >= 10 аудиторий';
else 
	print 'Имеется < 10 аудиторий';

-- ex 6
select 
	case 
	when PROGRESS.NOTE = 10 then 'Замечательно'
	when PROGRESS.NOTE between 7 and 9 then 'Отлично'
	when PROGRESS.NOTE between 4 and 6 then 'Сойдет'
	else 'Увы'
	end 'Оценка', count(*) 'Количество'
from PROGRESS, STUDENT, GROUPS
where PROGRESS.IDSTUDENT = STUDENT.IDSTUDENT 
	and STUDENT.IDGROUP = GROUPS.IDGROUP
	and GROUPS.FACULTY = 'ИДиП'
group by
	case 
	when PROGRESS.NOTE = 10 then 'Замечательно'
	when PROGRESS.NOTE between 7 and 9 then 'Отлично'
	when PROGRESS.NOTE between 4 and 6 then 'Сойдет'
	else 'Увы'
	end

-- ex 7: временная локальная таблица, заполнение циклом с while
drop table #EX7TABLE
create table #EX7TABLE
	(id int not null,
	name varchar(10) not null,
	age int not null);

set nocount on;
declare @cnt int = 0;
while (@cnt < 10)
	begin
		insert into #EX7TABLE values (@cnt, ('user' + cast(@cnt as varchar(2))), cast((floor(rand()*(60 - 18 + 1)) + 18) as int));
		set @cnt = @cnt + 1;
	end;
select * from #EX7TABLE

-- ex 9: try catch
begin try
	insert into #EX7TABLE values (null, null, null);
	print 'Даные добавлены в таблицу';
end try
begin catch
	print 'ERROR_NUMBER: ' + CONVERT(varchar, ERROR_NUMBER());
	print 'ERROR_MESSAGE: ' + ERROR_MESSAGE();
	print 'ERROR_LINE: ' + CONVERT(varchar, ERROR_LINE());
	print 'ERROR_PROCEDURE: ' + CONVERT(varchar, ERROR_PROCEDURE());
	print 'ERROR_SEVERITY: ' + CONVERT(varchar, ERROR_SEVERITY());
	print 'ERROR_STATE: ' + CONVERT(varchar, ERROR_STATE());
end catch

-- ex 8:
declare @ex8_cnt int = 0;
while @ex8_cnt < 10
	begin
		print 'x = ' + cast(@ex8_cnt as varchar(2));
		if (@ex8_cnt = 5) return;
		set @ex8_cnt = @ex8_cnt + 1;
	end;