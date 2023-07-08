CREATE DATABASE QL_CAPHE
GO

USE QL_CAPHE
GO

--Ban an
--Mon an
--Tai khoan 
--Danh muc mon an
--Hoa don
--Thong tin hoa don

CREATE TABLE BANAN
(
	id INT IDENTITY PRIMARY KEY,
	name nvarchar(max) not null default N'Bàn chưa có tên',
	status nvarchar(100) not null default N'Trống' -- Trong || hoac co nguoi
)
GO

CREATE TABLE TAIKHOAN
(
	tentaikhoan nvarchar(100) primary key,
	tenhienthi nvarchar(max) not null default N'',
	Password nvarchar(max) not null default 0 ,
	type int not null default 0 --1  quan tri vien 0: nhan vien 
)
go

CREATE TABLE DANHMUCMONAN
(
	id INT IDENTITY PRIMARY KEY,
	name nvarchar(max)not null default N''
)
go

CREATE TABLE MONAN
(
	id INT IDENTITY PRIMARY KEY,
	name nvarchar(max) not null default N'',
	idcategory int not null,
	price float not null default 0

	foreign key (idcategory) references dbo.DANHMUCMONAN(id)
)
go

CREATE TABLE HOADON
(
	id INT IDENTITY PRIMARY KEY,
	Datecheckin date not null default getdate(),
	Datecheckout date,
	idtable int not null,
	status int not null default 0--da thanh toan or chua thanh toan

	foreign key (idtable) references dbo.BANAN(id)
)
go

CREATE TABLE THONGTINHOADON
(
	id INT IDENTITY PRIMARY KEY,
	idbill int not null,
	idfood int not null,
	count int not null default 0
	foreign key (idbill) references dbo.HOADON(id),
	foreign key (idFood) references dbo.MONAN(id),
)
GO

insert into dbo.TAIKHOAN
(
	tentaikhoan,
	tenhienthi,
	Password,
	type
)
values
	( N'Nguyen Minh Hieu',N'Hieu',N'1',1 ),
	( N'Nguyen Hoang Minh Nhut',N'Nhut',N'1',2),
	( N'Nguyen Doan Gia Huy',N'HUY',N'1',2);

select * from dbo.TAIKHOAN

create proc dangnhapp
@tentaikhoan nvarchar(100),@matkhau nvarchar(100)
as
	begin
		select * from dbo.TAIKHOAN where tentaikhoan=@tentaikhoan and Password=@matkhau
		end
		go


--Thêm Bàn Ăn
DECLARE @i INT = 0

WHILE @i <= 10
BEGIN
	INSERT dbo.BANAN(name)VALUES  ( N'Bàn ' + CAST(@i AS nvarchar(100)))
	SET @i = @i + 1
END

select * from BANAN

update dbo.BANAN set status=N'Có người rồi nha'where id=8
create proc danhsachbanan
as select * from dbo.BANAN
go

exec danhsachbanan

--Thêm danh mục món ăn
insert into dbo.DANHMUCMONAN(name)
values
	(N'Cơm'),
	(N'Mì'),
	(N'Nuôi'),
	(N'Nước')

--Thêm món ăn
insert into MONAN
values
	(N'Cơm chiên trứng',1,200000),
	(N'Cơm đùi gà',1,250000),
	(N'Cơm mực xào',1,200000),
	(N'Mì trứng 1 vắt',2,150000),
	(N'Mì xúc xích',2,250000),
	(N'Mì thập cẩm',2,200000),
	(N'Nuôi xào bò',3,150000),
	(N'Nuôi xúc xích đức',3,250000),
	(N'Nuôi thập cẩm',3,250000),
	(N'Xì tin',4,150000),
	(N'Bò cụng',4,200000),
	(N'Ép cam',4,250000)

--Thêm bill
insert into HOADON
values
	(GETDATE(),NULL,1,0),
	(GETDATE(),NULL,2,0),
	(GETDATE(),GETDATE(),3,1)

--Thêm Thông tin hóa đơn

insert into THONGTINHOADON(idbill,idfood,count)
values
	(1,4,3),
	(2,4,2),
	(3,4,1),
	(4,4,9),
	(5,2,7),
	(6,9,2)

select * from HOADON
select * from THONGTINHOADON
select * from MONAN
select * from DANHMUCMONAN

select f.name,bi.count,f.price,f.price*bi.count as totalprice from dbo.THONGTINHOADON as bi,dbo.HOADON as b
,dbo.MONAN as f where bi.idbill=b.id and bi.idfood=f.id and b.status=0 and b.idtable=1

select * from MONAN where idcategory=3
select * from DANHMUCMONAN

alter  proc insertbill
@idtable int
as
	begin
	insert into HOADON
   (
	Datecheckin,
	Datecheckout,
	idtable,
	status,	
	discount
	)
	values

	(GETDATE(),
	NULL,
	@idtable,
	0,
	0
	)
	end
go



create proc insertbillinfo
@idbill int,@idfood int,@count int
as
	begin
	declare @isexitbillinfo int;
	declare @foodcount int=1;

	select @isexitbillinfo=id,@foodcount=b.count 
	from THONGTINHOADON as b 
	where idbill=@idbill and idfood=@idfood
	if(@isexitbillinfo>0)
	begin
	declare @newcount int = @foodcount + @count
	if(@newcount>0)
		update THONGTINHOADON set count =@foodcount+@count
		else
		delete THONGTINHOADON where idbill=@idbill and idfood=@idfood 
		end
		else
		begin
		insert THONGTINHOADON(idbill,idfood,count)
		values(@idbill,@idfood,@count)
		end
		end
		go

		
select max(id) from HOADON
select max(id) from HOADON
select * from DANHMUCMONAN
select * from MONAN where idcategory = 3

dELETE dbo.THONGTINHOADON

DELETE dbo.HOADON

alter TRIGGER UpdateBillInfo
on THONGTINHOADON FOR INSERT , UPDATE
AS 
	BEGIN

	DECLARE @idbill int

	select @idbill =idbill from inserted

	declare @idtable int

	select @idtable=idtable from HOADON where id in (select id from HOADON where idtable=@idtable and status=0)
	declare @countbillinfo int
	select count(*) from THONGTINHOADON where idbill=@idbill
	if(@countbillinfo>0)
	update BANAN set status=N'Có Người' where id=@idtable
	else
	update BANAN set status=N'Không Có Người' where id=@idtable
	end
go

 update HOADON set status=1 where id=1
 select *from HOADON

 alter table HOADON
 ADD discount int
 update HOADON set discount=0
 select * from HOADON

 select * from HOADON

 create proc switchtabel
	@idtable1 int,@idtable2 int
as begin
	declare @idfirstbill int
	declare	@idseconrdbill int
	select	@idseconrdbill=id from HOADON where idtable=@idtable2 and status=0
	select @idfirstbill=id from HOADON where idtable=@idtable1 and status=0
	if(@idfirstbill=null)
	begin
		insert HOADON
		(
			Datecheckin,
			Datecheckout,
			idtable,
			status
		)
		values
		(
			GETDATE(),
			null,
			@idtable1, 
			0
		)
		select @idfirstbill=max(id)from HOADON where idtable=@idtable1 and status=0
	end
	if(@idseconrdbill=null)
	begin
		insert HOADON
		(
			Datecheckin,
			Datecheckout,
			idtable,
			status
		)
		values
		(
			GETDATE(),
			null,
			@idtable2, 
			0
		)
		select @idseconrdbill=max(id)from HOADON where idtable=@idtable2 and status=0
	end
	select id into Idbillinfotable from THONGTINHOADON where idbill=@idseconrdbill
	update THONGTINHOADON set idbill=@idseconrdbill where idbill=@idfirstbill
	update THONGTINHOADON set idbill=@idfirstbill where id in (select * from Idbillinfotable)
	drop table Idbillinfotable
	end
go
select * from HOADON
delete THONGTINHOADON

alter table HOADON ADD totalprice float

delete HOADON
select * from HOADON

create proc getlistbillbydate
@checkin date,@checkout date
as
begin
	select  t.name as [Tên Bàn],b.totalprice as [Tổng Tiền],Datecheckin as [Ngày vào],Datecheckout as [Ngày ra],discount as [Giảm giá]
	from HOADON as b,BANAN as t
	where Datecheckin>=@checkin and Datecheckout <=@checkout and b.status=1
	and t.id=b.idtable 
End
go

select * from TAIKHOAN
Select * from TAIKHOAN 

create proc updateaccount
@tentaikhoan nvarchar(100),@tenhienthi nvarchar(100),@password nvarchar(100),@newpassword nvarchar(100)
as
	begin
		declare @isrightpass int=0
		select @isrightpass=count(*) from TAIKHOAN where tentaikhoan=@tentaikhoan and Password=@password
		if(@isrightpass =1)
		begin
			if(@newpassword=null or @newpassword='')
			begin
				update TAIKHOAN set tenhienthi=@tenhienthi where tentaikhoan=@tentaikhoan
			End
			Else
			update TAIKHOAN set tenhienthi=@tenhienthi,Password=@newpassword where tentaikhoan=@tentaikhoan
		End
	end
go
select * from TAIKHOAN

insert MONAN(name,idcategory,price)
values
(N'',0,0.0);

select tentaikhoan,tenhienthi, type from TAIKHOAN
