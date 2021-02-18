USE [Ерчинская_ПРОДАЖИ]

SELECT *
FROM ЗАКАЗЫ
WHERE (Дата_поставки > CONVERT(DATETIME, '2019-10-14 00:00:00', 102))

SELECT *
FROM ТОВАРЫ
WHERE (Цена BETWEEN 10 AND 40)

SELECT Заказчик, Наименование_товара
FROM ЗАКАЗЫ
WHERE (Наименование_товара = N'The Witcher 3')

SELECT Заказчик, Номер_заказа, Наименование_товара, Дата_поставки
FROM ЗАКАЗЫ
WHERE (Заказчик = N'Steam')
ORDER BY Дата_поставки