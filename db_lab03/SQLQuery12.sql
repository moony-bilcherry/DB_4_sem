use [03_UNIVER]

create table STUDENT (
�����_������� int primary key identity(1, 1),
��� nvarchar(30) not null,
����_�������� date not null,
��� nchar(1) default '�' check (��� in ('�', '�')),
����_����������� date not null
);