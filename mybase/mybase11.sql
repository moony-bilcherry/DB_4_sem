use [02_MyBase]

select * from ������
select * from ����������
select * from �������
select * from ������

-- ex 1: ������ ��������� �� ������� ���� � ���� ������ ����� �������
declare @sub char(20), @out char(300) = '';
declare EX1_PR cursor 
	for select ���_����������
	from ���������� 
	where �����='PR'; 

	open EX1_PR
		fetch EX1_PR into @sub;
		print '���������� ������ PR: ';
		while @@FETCH_STATUS = 0
			begin
				set @out = rtrim(@sub) + ', ' + @out;
				fetch EX1_PR into @sub;
			end;
		print @out;
	close EX1_PR;
	deallocate EX1_PR;

-- ex 2: ������� ����������� ������� �� ����������
declare EX2_LOCAL cursor local
	for select ��������_������,����������_�����������  
	from ������
declare @aud char(10), @cap int;
	open EX2_LOCAL;
		fetch EX2_LOCAL into @aud, @cap;
		print '[LOCAL] 1. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
	go
-- ������: ������ EX2_LOCAL �� ����������
--declare @aud char(10), @cap int;
--		fetch EX2_LOCAL into @aud, @cap;
--		print '[LOCAL] 2. ' + rtrim(@aud) + ' ' + convert(varchar,@cap);
--	go

declare EX2_GLOBAL cursor global
	for select ��������_������,����������_�����������  
	from ������
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

-- ex 3: ������� ������������ ������� �� �������������
declare EX3_TEACHER cursor local dynamic
	for select �����, ������_�������, ���_����������
	from ����������
	where ����� = 'PR';
declare @pul char(10), @gen real, @name char(50);
	open EX3_TEACHER;
		print '���������� �����: ' + convert(varchar, @@CURSOR_ROWS);
		insert into ���������� values ('����', 'PR', 1.5);
		update ���������� set ������_������� = 999999 where ���_���������� = '����';
		fetch EX3_TEACHER into @pul, @gen, @name;
		while @@FETCH_STATUS = 0
		begin
			print rtrim(@pul) + ' ' + convert(varchar, @gen) + ' ' + rtrim(@name);
			fetch EX3_TEACHER into @pul, @gen, @name;
		end;
	close EX3_TEACHER;
delete ���������� where ���_���������� = '����';
go

-- ex 4: scroll ������
declare EX4_SCROLL cursor local dynamic scroll
	for select ROW_NUMBER() over (order by ���_���������� asc) N, ���_����������
	from ����������
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
insert into ������ values ('AAAAAAAA', 500); 

declare EX5_CURRENT cursor local scroll dynamic
	for select ��������_������, ����������_����������� 
	from ������
	for update; 
declare @fac varchar(5), @full varchar(50); 
	open EX5_CURRENT 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		update ������ set ����������_����������� = 4 where current of EX5_CURRENT; 
		fetch first from EX5_CURRENT into @fac, @full; 
		print @fac + ' ' + @full;
		delete ������ where current of EX5_CURRENT;
	close EX5_CURRENT;
go

-- ex 6.1: ��������� c��������� � �������� < 1�
insert into ���������� values 
	('����', 'TEST', 0.28),
	('����', 'TEST', 0.92),
	('����', 'TEST', 0.73),
	('����', 'TEST', 0.61)

select ���_����������, ������_������� 
from ���������� 
	inner join ������ on ����������.����� = ������.��������_������
where ������_������� < 1

declare EX6_1 cursor local 
	for	select ���_����������, ������_������� 
	from ���������� 
		inner join ������ on ����������.����� = ������.��������_������
	where ������_������� < 1
declare @student nvarchar(20), @mark int;  
	open EX6_1;  
		fetch  EX6_1 into @student, @mark;
		while @@FETCH_STATUS = 0
			begin 		
				delete ���������� where current of EX6_1;	
				fetch  EX6_1 into @student, @mark;  
			end
	close EX6_1;

select ���_����������, ������_������� 
from ���������� 
	inner join ������ on ����������.����� = ������.��������_������
where ������_������� < 1
go
		
-- ex 6.2: +1 � ������ ����������� �������� (IDSTUDENT) - id 1025
declare EX6_2 cursor local 
	for	select ���_����������, ������_������� 
	from ����������
	where ���_���������� = '����'
declare @student nvarchar(20), @mark real;  
	open EX6_2;  
		fetch  EX6_2 into @student, @mark;
		update ���������� set ������_������� += 100 where CURRENT OF EX6_2;
	close EX6_2;

update ���������� set ������_������� -= 100 where ���_���������� = '����';
go