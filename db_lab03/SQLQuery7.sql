use [03_UNIVER]

select * from STUDENT where Номер_зачетки between 10 and 18;
select * from STUDENT where Фамилия_студента like '%ов';
select * from STUDENT where Номер_зачетки in (11, 12, 19);
