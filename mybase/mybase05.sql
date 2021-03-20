use [02_MyBase]

select * from ������� inner join ������ on �������.�����_���� = ������.���

select * from ������� inner join ������ on �������.�����_���� = ������.��� and ������.��������_������ like '%�%';

select * from �������, ������ where �������.�����_���� = ������.���

select * from �������, ������ where �������.�����_���� = ������.��� and ������.��������_������ like '%�%';

select ������.��������_������, ����������.���_����������,
	case 
			when (�������.�����������_����� between 5 and 10) then '5� < x < 10�'
			when (�������.�����������_����� between 5 and 15) then '10� < x < 15�'
			when (�������.�����������_����� >= 15) then '>= 15�'
		end '���������'
from ������ inner join ���������� on ������.��������_������ = ����������.�����
inner join ������� on �������.��������� = ����������.���_����������
where �������.�����������_����� > 5
order by (case 
	when (�������.�����������_����� between 5 and 10) then 1
	when (�������.�����������_����� between 5 and 15) then 2
	when (�������.�����������_����� >= 15) then 3
end)

select isnull(����������.���_����������, '***') as '���������', isnull(�������.�����_����, 99999) as '����� ����'
from ���������� full outer join ������� 
on ����������.���_���������� = �������.���������

select isnull(����������.���_����������, '***') as '���������', isnull(�������.�����_����, 99999) as '����� ����'
from ���������� left outer join ������� 
on ����������.���_���������� = �������.���������

select isnull(����������.���_����������, '***') as '���������', isnull(�������.�����_����, 99999) as '����� ����'
from ���������� right outer join ������� 
on ����������.���_���������� = �������.���������

select isnull(����������.���_����������, '***') as '���������', isnull(�������.�����_����, 99999) as '����� ����'
from ���������� full outer join ������� 
on ����������.���_���������� = �������.��������� 
where ����������.���_���������� is null and �������.�����_���� is not null

select isnull(����������.���_����������, '***') as '���������', isnull(�������.�����_����, 99999) as '����� ����'
from ���������� full outer join ������� 
on ����������.���_���������� = �������.��������� 
where ����������.���_���������� is not null and �������.�����_���� is null

select * from ������� cross join ������ where �������.�����_���� = ������.���