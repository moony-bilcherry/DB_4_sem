USE [���������_�������]

SELECT *
FROM ������
WHERE (����_�������� > CONVERT(DATETIME, '2019-10-14 00:00:00', 102))

SELECT *
FROM ������
WHERE (���� BETWEEN 10 AND 40)

SELECT ��������, ������������_������
FROM ������
WHERE (������������_������ = N'The Witcher 3')

SELECT ��������, �����_������, ������������_������, ����_��������
FROM ������
WHERE (�������� = N'Steam')
ORDER BY ����_��������