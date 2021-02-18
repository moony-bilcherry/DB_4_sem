use [03_UNIVER]

select * from Student where Пол = 'ж' and datediff(year, Дата_рождения, Дата_поступления) > 18;