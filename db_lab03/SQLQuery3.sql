use [03_UNIVER]

alter table STUDENT add ��� nchar(1) default '�' check (��� in ('�', '�')); 
alter table STUDENT add ����_����������� varchar(10);
alter table STUDENT	alter column ����_����������� date; 
alter table STUDENT add check (����_�����������<=getdate()); 