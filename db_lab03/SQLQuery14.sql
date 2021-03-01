use [03_UNIVER]

select * from STUDENT where Пол = 'ж' and datediff(year, Дата_рождения, Дата_поступления) > 18;