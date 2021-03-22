use [04_UNIVER]

-- ex 1
declare @vchar char(2) = 'hi',
		@vvarchar varchar(9) = 'Note',
		@vdate datetime,
		@vtime time,
		@vint int,
		@vsmall smallint,
		@vtiny tinyint,
		@vnumeric numeric(12,5);

set  @vdate = getdate();
select @vtime = '12:59:34';

select @vint = 434635, @vsmall = 3562, @vnumeric  = 1234567.12345;
select @vchar vchar, @vvarchar vvarchar, @vdate vdate, @vtime vtime;

print 'vint = ' + cast(@vint as varchar(10));
print 'vsmall = ' + cast(@vsmall as varchar(10));
print 'vtiny = ' + cast(@vtiny as varchar(10));				-- null
print 'vnumeric = ' + cast(@vnumeric as varchar(20));

-- ex 2: 