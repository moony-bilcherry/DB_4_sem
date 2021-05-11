use [02_MyBase]
go

-- ex 1: �������� XML-���� � ������ PATH �� ������� ���������� ��� ����������� ������ PR
select * from ����������
where ����������.����� = 'PR'
for xml PATH('���������'), root('������_�����������');
go

-- ex 2: ����� AUTO, ������ � �������� AUDITORIUM � AUDITORIUM_TYPE, ����� ������ ����������
select ����������.���_����������, ����������.������_�������, ������.��������_������
from ���������� inner join ������
	on ����������.����� = ������.��������_������
where ������.��������_������ like '%PR%'
for xml AUTO, root('�����_PR'), elements;
go

-- ex 3: xml-��� � ����� ������ ������������ ��� ����������
declare @h int = 0, @text varchar(1000) =
	'<?xml version="1.0" encoding="windows-1251"?>
	<����>
		<��������� ���="����" �����="PR" �����="26.02"/>
		<��������� ���="�������" �����="������������" �����="73.12"/>
		<��������� ���="������" �����="HR" �����="35.97"/>
	</����>';
exec sp_xml_preparedocument @h output, @text;
select * from openxml(@h, '/����/���������',0)
	with([���] nvarchar(20), [�����] nvarchar(20), [�����] real)

insert ���������� select [���], [�����], [�����]
	from openxml(@h, '/����/���������',0)
		with([���] nvarchar(20), [�����] nvarchar(20), [�����] real)

select * from ����������
delete ���������� where ���_���������� in('����', '�������', '������')

exec sp_xml_removedocument @h;
go