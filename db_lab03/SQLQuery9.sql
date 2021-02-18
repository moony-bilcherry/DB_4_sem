use [03_UNIVER]

create table RESULTS (
id int primary key identity(1, 1),
student_name varchar(20) not null,

math int,
oop int,
java int,
db int,

aver_value as (math+oop+java+db)/4.0
)