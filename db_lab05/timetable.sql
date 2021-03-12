use [04_UNIVER]

--drop table TIMETABLE;

create table TIMETABLE (
DAY_NAME char(2) check (DAY_NAME in('��', '��', '��', '��', '��', '��')),
LESSON integer check(LESSON between 1 and 4),
TEACHER char(10)  constraint TIMETABLE_TEACHER_FK  foreign key references TEACHER(TEACHER),
AUDITORIUM char(20) constraint TIMETABLE_AUDITORIUM_FK foreign key references AUDITORIUM(AUDITORIUM),
SUBJECT char(10) constraint TIMETABLE_SUBJECT_FK  foreign key references SUBJECT(SUBJECT),
IDGROUP integer constraint TIMETABLE_GROUP_FK  foreign key references GROUPS(IDGROUP),
)

insert into TIMETABLE values 
('��', 1, '����', '313-1', '����', 2),
('��', 2, '����', '313-1', '����', 4),
('��', 3, '����', '313-1', '����', 11),

('��', 1, '���', '324-1', '����', 6),
('��', 3, '���', '324-1', '���', 4),

('��', 1, '���', '206-1', '���', 10),
('��', 4, '����', '206-1', '����', 3),

('��', 1, '�����', '301-1', '����', 7),
('��', 4, '�����', '301-1', '����', 7),

('��', 2, '�����', '413-1', '����', 8),

('��', 2, '���', '423-1', '����', 7),
('��', 4, '���', '423-1', '����', 2),

('��', 1, '����', '313-1', '����', 2),
('��', 2, '����', '313-1', '����', 4),


('��', 3, '���', '324-1', '���', 4),
('��', 4, '����', '206-1', '����', 3)