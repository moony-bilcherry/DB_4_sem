use [04_UNIVER]
go

drop procedure PSUBJECT;
go
-- ex 1: �������� ��������� ��� ����������, ��������� �������������� ����� �� ������ ������� SUBJECT
create procedure PSUBJECT 
	as begin
		declare @num int = (select count(*) from SUBJECT);
		select * from SUBJECT;
		return @num;
	end;
go

declare @temp_1 int = 0;
exec @temp_1 = PSUBJECT;
print '���������� ���������: ' + convert(varchar, @temp_1);
go

-- ex 2: �������� + ���������
alter procedure PSUBJECT @p varchar(20), @c int output
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print '���������: @p = ' + @p + ', @c = ' + convert (varchar, @c);
		select * from SUBJECT where PULPIT = @p;
		set @c = @@ROWCOUNT;
		return @num;
	end;
go

declare @temp_2 int = 0, @out_2 int = 0;
exec @temp_2 = PSUBJECT '����', @out_2 output;
print '��������� �����: ' + convert(varchar, @temp_2);
print '��������� �� ������� ����: ' + convert(varchar, @out_2);
go

-- ex 3: ��������� ��������� �������, �������� ���������, insert
alter procedure PSUBJECT @p varchar(20)
	as begin
		declare @num int = (select count(*) from SUBJECT);
		print '���������: @p = ' + @p;
		select * from SUBJECT where PULPIT = @p;
	end;
go

drop table #EX3;
create table #EX3 (
	sub nvarchar(10) primary key,
	sub_name nvarchar(50),
	pul nvarchar(50)
)

insert #EX3 exec PSUBJECT '����';
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
		print '����� ������: ' + convert(varchar, error_number());
		print '���������: ' + error_message();
		print '�������: ' + convert(varchar, error_severity());
		print '�����: ' + convert(varchar, error_state());
		print '����� ������: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print '��� ���������: ' + error_procedure();
		return -1;
	end catch;
go

declare @temp_4 int;
exec @temp_4 = PAUDITORIUM_INSERT '131313-1', '13131313131313', 70, '��-�';
print '���� ���������� ���������: ' + convert(varchar, @temp_4);
go

-- ex 5: ������� ���������� �� ������� ����� �������
drop procedure SUBJECT_REPORT
go
create procedure SUBJECT_REPORT
	@p char(10)
	as declare @rc int = 0;
	begin try
		if not exists (select SUBJECT from SUBJECT where PULPIT = @p)
			raiserror('������ � ����������', 11, 1);
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
		print '���������� �� ������� ' + rtrim(@p) + ':';
		print rtrim(@subs_list);
		close SUBJECTS_LAB13;
		deallocate SUBJECTS_LAB13;
		return @rc;
	end try
	begin catch
		print '����� ������: ' + convert(varchar, error_number());
		print '���������: ' + error_message();
		print '�������: ' + convert(varchar, error_severity());
		print '�����: ' + convert(varchar, error_state());
		print '����� ������: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print '��� ���������: ' + error_procedure();
		return @rc;
	end catch;
go

declare @temp_5 int;
exec @temp_5 = SUBJECT_REPORT '����';
print '���������� ���������: ' + convert(varchar, @temp_5);
go

-- ex 6: ���������� serializable; @tn ��� AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
drop procedure PAUDITORIUM_INSERTX;
delete AUDITORIUM where AUDITORIUM_TYPE = '��-�';
delete AUDITORIUM_TYPE where AUDITORIUM_TYPE = '��-�';
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
		print '����� ������: ' + convert(varchar, error_number());
		print '���������: ' + error_message();
		print '�������: ' + convert(varchar, error_severity());
		print '�����: ' + convert(varchar, error_state());
		print '����� ������: ' + convert(varchar, error_line());
		if error_procedure() is not null
			print '��� ���������: ' + error_procedure();
		if @@TRANCOUNT > 0
			rollback tran;
		return -1;
	end catch;
go

declare @temp_6 int;
exec @temp_6 = PAUDITORIUM_INSERTX '136-1', '136-1', 36, '��-�', '�������� ��������� ��� ������';
print '���� ���������� ���������: ' + convert(varchar, @temp_6);
go

select * from AUDITORIUM_TYPE
select * from AUDITORIUM

-- 