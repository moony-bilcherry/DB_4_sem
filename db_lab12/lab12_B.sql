use [04_UNIVER];

-- ex 5: READ UNCOMMITTED
				--- B ---	
-- 2
begin transaction 
select @@SPID
insert SUBJECT values ('���', '������ ������ ����������', '����'); 
update AUDITORIUM set AUDITORIUM_CAPACITY = 50 where AUDITORIUM = '222-1' 
-- 4
rollback;

-- ex 5: READ COMMITTED
				--- B ---	
-- 2
begin tran
delete from AUDITORIUM where AUDITORIUM = '222-1'

-- 4
rollback tran;

-- ex 6: REPEATABLE READ
				--- B ---
-- 