--TaiKhoan(MaTK, NgayLap, SoDu, TrangThai, LoaiTK, MaKH)
--LoaiTaiKhoan (MaLoai, TenLoai)
--KhachHang(MaKH, HoTen, NgaySinh, CMND, DiaChi)
--GiaoDich(MaGD, MaTK, SoTien, ThoiGianGD, GhiChu)
 use master 
 go
 alter database ql_giao_dich set single_user with rollback immediate

 drop database ql_giao_dich

drop database if exists ql_giao_dich
go

create database ql_giao_dich
go

use ql_giao_dich
go

create table TaiKhoan
(
	MaTK char(10), 
	NgayLap date, 
	SoDu int, 
	TrangThai nvarchar(30), 
	LoaiTK char(10), 
	MaKH char(10),

	constraint pk_TaiKhoan primary key(MaTK)
)
go

create  table LoaiTaiKhoan 
(
	MaLoai char(10), 
	TenLoai varchar(20),
	
	constraint pk_LoaiTaiKhoan primary key(MaLoai)
)
go

create table KhachHang
(
	MaKH char(10), 
	HoTen nvarchar(30), 
	NgaySinh date, 
	CMND char(10), 
	DiaChi text,
	
	constraint pk_KhachHang primary key(MaKH)
)
go

create table GiaoDich
(
	MaGD char(10), 
	MaTK char(10), 
	SoTien int, 
	ThoiGianGD date, 
	GhiChu text,
	
	constraint pk_GiaoDich primary key(MaGD)
)
go

alter table TaiKhoan
add 
constraint fk_LoaiTK foreign key(LoaiTK) references LoaiTaiKhoan(MaLoai),
constraint fk_MaKH foreign key(MaKH) references KhachHang(MaKH)
go

alter table GiaoDich
add
constraint fk_MaTK foreign key(MaTK) references TaiKhoan(MaTK)
go
insert into LoaiTaiKhoan values ('LTK1', 'Normal');
insert into KhachHang values ('KH1', N'Nguyễn Văn Lợi', '20010110', '123456789', 'HCM');
insert into TaiKhoan values ('TK1', '20221001', 50000, N'Đang hoạt động', 'LTK1', 'KH1');
