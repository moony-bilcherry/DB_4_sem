use [03_UNIVER]

alter table STUDENT add Пол nchar(1) default 'м' check (Пол in ('м', 'ж')); 
alter table STUDENT add Дата_поступления varchar(10);
alter table STUDENT	alter column Дата_поступления date; 
alter table STUDENT add check (Дата_поступления<=getdate()); 