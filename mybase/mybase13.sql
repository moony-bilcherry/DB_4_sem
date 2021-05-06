use [02_MyBase]
go

drop procedure PWORKERS;
go
-- ex 1: ���������� �����������
create procedure PWORKERS
	as begin
		declare @num int = (select count(*) from ����������);
		select  * from ����������;
		return @num;
	end;
go

declare @temp_1 int = 0;
exec @temp_1 = PWORKERS;
print '���������� �����������: ' + convert(varchar, @temp_1);
go

-- ex 2: �������� + ���������
alter procedure PWORKERS @p varchar(20), @c int output
	as begin
		declare @num int = (select count(*) from ����������);
		print '���������: @p = ' + @p + ', @c = ' + convert (varchar, @c);
		select * from ���������� where ����� = @p;
		set @c = @@ROWCOUNT;
		return @num;
	end;
go

declare @temp_2 int = 0, @out_2 int = 0;
exec @temp_2 = PWORKERS 'PR', @out_2 output;
print '����������� �����: ' + convert(varchar, @temp_2);
print '����������� ������ PR: ' + convert(varchar, @out_2);
go

-- ex 3: ��������� ��������� �������, �������� ���������, insert
alter procedure PWORKERS @p varchar(20)
	as begin
		declare @num int = (select count(*) from ����������);
		print '���������: @p = ' + @p;
		select * from ���������� where ����� = @p;
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
select * from ����������
drop procedure PWORKER_INSERT;
delete ���������� where ���_���������� = '�����';
go
create procedure PWORKER_INSERT
	@name char(20), @tospend real = 0, @dep char(20)
	as begin try
		insert into ���������� values (@name, @dep, @tospend);
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
exec @temp_4 = PWORKER_INSERT '�����', 13.40, 'PR';
print '���� ���������� ���������: ' + convert(varchar, @temp_4);
go

-- ex 5: ������� ���������� �� ������� ����� �������
drop procedure WORKERS_REPORT
go
create procedure WORKERS_REPORT
	@p char(20)
	as declare @rc int = 0;
	begin try
		if not exists (select ���_���������� from ���������� where ����� = @p)
			raiserror('������ � ����������', 11, 1);
		declare @subs_list char(300) = '', @sub char(20);
		declare SUBJECTS_LAB13 cursor for
			select ���_���������� from ���������� where ����� = @p;
		open SUBJECTS_LAB13;
			fetch SUBJECTS_LAB13 into @sub;
			while (@@FETCH_STATUS = 0)
				begin
					set @subs_list = rtrim(@sub) + ', ' + @subs_list;
					set @rc += 1;
					fetch SUBJECTS_LAB13 into @sub;
				end;
			print '���������� ������ ' + rtrim(@p) + ':';
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
exec @temp_5 = WORKERS_REPORT 'PR';
print '���-�� ����������� � ������ PR: ' + convert(varchar, @temp_5);
go

-- ex 6: ���������� serializable; @depsize ��� AUDITORIUM_TYPE.AUDITORIUM_TYPENAME 
drop procedure PWORKER_INSERTX;
delete ���������� where ����� = '�����-��';
delete ������ where ��������_������ = '�����-��';
go
create procedure PWORKER_INSERTX
	@name char(20), @tospend real = 0, @dep char(20), @depsize int
	as declare @rc int = 1;
	begin try
		set transaction isolation level SERIALIZABLE
		begin tran
			insert into ������ values (@dep, @depsize);
			exec @rc = PWORKER_INSERT @name, @tospend, @dep;
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
exec @temp_6 = PWORKER_INSERTX '�������', 13.80, '�����-��', 24;
print '���� ���������� ���������: ' + convert(varchar, @temp_6);
go

select * from ������
select * from ����������