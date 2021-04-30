use [02_MyBase]

select * from ОТДЕЛЫ
select * from СОТРУДНИКИ
select * from РАСХОДЫ
select * from ТОВАРЫ

-- ex 1: список дисциплин на кафедре ИСиТ в одну строку через запятую
declare @sub char(20), @out char(300) = '';
declare EX1_PR cursor 
	for select Имя_сотрудника
	from СОТРУДНИКИ 
	where Отдел='PR'; 

	open EX1_PR
		fetch EX1_PR into @sub;
		print 'Сотрудники отдела PR: ';
		while @@FETCH_STATUS = 0
			begin
				set @out = rtrim(@sub) + ', ' + @out;
				fetch EX1_PR into @sub;
			end;
		print @out;
	close EX1_PR;
	deallocate EX1_PR;

-- ex 2: отличие глобального курсора от локального
declare EX2_LOCAL cursor local
	for select Название_отдела,Количество_сотрудников  
	from ОТДЕЛЫ
declare @aud char(10), @cap int;
	open EX2_LOCAL;
		fetch EX2_LOCAL into @aud, @cap;
		print '[LOCAL] 1. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	go
-- ОШИБКА: курсор EX2_LOCAL не существует
--declare @aud char(10), @cap int;
--		fetch EX2_LOCAL into @aud, @cap;
--		print '[LOCAL] 2. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
--	go

declare EX2_GLOBAL cursor global
	for select Название_отдела,Количество_сотрудников  
	from ОТДЕЛЫ
declare @aud char(10), @cap int;
	open EX2_GLOBAL;
		fetch EX2_GLOBAL into @aud, @cap;
		print '[GLOBAL] 1. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	go
declare @aud char(10), @cap int;
		fetch EX2_GLOBAL into @aud, @cap;
		print '[GLOBAL] 2. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	close EX2_GLOBAL;
	deallocate EX2_GLOBAL;
	go

-- ex 3: отличие статического курсора от динамического
declare EX3_TEACHER cursor local dynamic
	for select Отдел, Предел_расхода, Имя_сотрудника
	from СОТРУДНИКИ
	where Отдел = 'PR';
declare @pul char(10), @gen real, @name char(50);
	open EX3_TEACHER;
		print 'Количество строк: ' + convert(varchar, @@CURSOR_ROWS);
		insert into СОТРУДНИКИ values ('ТЕСТ', 'PR', 1.5);
		update СОТРУДНИКИ set Предел_расхода = 999999 where Имя_сотрудника = 'ТЕСТ';
		fetch EX3_TEACHER into @pul, @gen, @name;
		while @@FETCH_STATUS = 0
		begin
			print rtrim(@pul) + ' ' + convert(varchar, @gen) + ' ' + rtrim(@name);
			fetch EX3_TEACHER into @pul, @gen, @name;
		end;
	close EX3_TEACHER;
delete СОТРУДНИКИ where Имя_сотрудника = 'ТЕСТ';
go

-- ex 4: scroll запрос
declare EX4_SCROLL cursor local dynamic scroll
	for select ROW_NUMBER() over (order by Имя_сотрудника asc) N, Имя_сотрудника
	from СОТРУДНИКИ
declare @num int, @name char(50);
	open EX4_SCROLL;
		fetch last from EX4_SCROLL into @num, @name;
		print char(9) + 'LAST:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch first from EX4_SCROLL into @num, @name;
		print char(9) + 'FIRST:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch next from EX4_SCROLL into @num, @name;
		print char(9) + 'NEXT:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch absolute 5 from EX4_SCROLL into @num, @name;
		print char(9) + 'ABSOLUTE 5:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch relative 2 from EX4_SCROLL into @num, @name;
		print char(9) + 'RELATIVE 2:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch prior from EX4_SCROLL into @num, @name;
		print char(9) + 'PRIOR:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch absolute -7 from EX4_SCROLL into @num, @name;
		print char(9) + 'ABSOLUTE -7:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
		fetch relative -1 from EX4_SCROLL into @num, @name;
		print char(9) + 'RELATIVE -1:' + char(10) + convert(varchar, @num) + ' ' + rtrim(@name);
	close EX4_SCROLL;
go

-- ex 5: current of
insert into ОТДЕЛЫ values ('AAAAAAAA', 500); 

declare EX5_CURRENT cursor local scroll dynamic
	for select Название_отдела, Количество_сотрудников 
	from ОТДЕЛЫ
	for update; 
declare @fac varchar(5), @full varchar(50); 
	open EX5_CURRENT 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		update ОТДЕЛЫ set Количество_сотрудников = 4 where current of EX5_CURRENT; 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		delete ОТДЕЛЫ where current of EX5_CURRENT;
	close EX5_CURRENT;
go

-- ex 6.1: удаляются cотрудники с пределом < 1р
insert into СОТРУДНИКИ values 
	('Биба', 'TEST', 0.28),
	('Боба', 'TEST', 0.92),
	('Лупа', 'TEST', 0.73),
	('Пупа', 'TEST', 0.61)

select Имя_сотрудника, Предел_расхода 
from СОТРУДНИКИ 
	inner join ОТДЕЛЫ on СОТРУДНИКИ.Отдел = ОТДЕЛЫ.Название_отдела
where Предел_расхода < 1

declare EX6_1 cursor local 
	for	select Имя_сотрудника, Предел_расхода 
	from СОТРУДНИКИ 
		inner join ОТДЕЛЫ on СОТРУДНИКИ.Отдел = ОТДЕЛЫ.Название_отдела
	where Предел_расхода < 1
declare @student nvarchar(20), @mark int;  
	open EX6_1;  
		fetch  EX6_1 into @student, @mark;
		while @@FETCH_STATUS = 0
			begin 		
				delete СОТРУДНИКИ where current of EX6_1;	
				fetch  EX6_1 into @student, @mark;  
			end
	close EX6_1;

select Имя_сотрудника, Предел_расхода 
from СОТРУДНИКИ 
	inner join ОТДЕЛЫ on СОТРУДНИКИ.Отдел = ОТДЕЛЫ.Название_отдела
where Предел_расхода < 1
go
		
-- ex 6.2: +1 к оценке конкретного студента (IDSTUDENT) - id 1025
declare EX6_2 cursor local 
	for	select Имя_сотрудника, Предел_расхода 
	from СОТРУДНИКИ
	where Имя_сотрудника = 'Олег'
declare @student nvarchar(20), @mark real;  
	open EX6_2;  
		fetch  EX6_2 into @student, @mark;
		update СОТРУДНИКИ set Предел_расхода += 100 where CURRENT OF EX6_2;
	close EX6_2;

update СОТРУДНИКИ set Предел_расхода -= 100 where Имя_сотрудника = 'Олег';
go