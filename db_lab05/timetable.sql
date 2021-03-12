use [04_UNIVER]

--drop table TIMETABLE;

create table TIMETABLE (
DAY_NAME char(2) check (DAY_NAME in('ОМ', 'БР', 'ЯП', 'ВР', 'ОР', 'ЯА')),
LESSON integer check(LESSON between 1 and 4),
TEACHER char(10)  constraint TIMETABLE_TEACHER_FK  foreign key references TEACHER(TEACHER),
AUDITORIUM char(20) constraint TIMETABLE_AUDITORIUM_FK foreign key references AUDITORIUM(AUDITORIUM),
SUBJECT char(10) constraint TIMETABLE_SUBJECT_FK  foreign key references SUBJECT(SUBJECT),
IDGROUP integer constraint TIMETABLE_GROUP_FK  foreign key references GROUPS(IDGROUP),
)

insert into TIMETABLE values 
('ОМ', 1, 'ялкб', '313-1', 'ясад', 2),
('ОМ', 2, 'ялкб', '313-1', 'нюХо', 4),
('ОМ', 3, 'ялкб', '313-1', 'нюХо', 11),

('ОМ', 1, 'лпг', '324-1', 'ясад', 6),
('ОМ', 3, 'спа', '324-1', 'охя', 4),

('ОМ', 1, 'спа', '206-1', 'охя', 10),
('ОМ', 4, 'ялкб', '206-1', 'нюХо', 3),

('ОМ', 1, 'апйбв', '301-1', 'ясад', 7),
('ОМ', 4, 'апйбв', '301-1', 'нюХо', 7),

('ОМ', 2, 'апйбв', '413-1', 'ясад', 8),

('ОМ', 2, 'дрй', '423-1', 'ясад', 7),
('ОМ', 4, 'дрй', '423-1', 'нюХо', 2),

('БР', 1, 'ялкб', '313-1', 'ясад', 2),
('БР', 2, 'ялкб', '313-1', 'нюХо', 4),


('БР', 3, 'спа', '324-1', 'охя', 4),
('БР', 4, 'ялкб', '206-1', 'нюХо', 3)