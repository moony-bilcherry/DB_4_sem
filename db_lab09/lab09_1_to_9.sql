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