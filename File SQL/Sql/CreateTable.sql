Create Table ThuThu(
ID varchar(10) constraint ThuThu_Primarykey_ID primary key,
TaiKhoan varchar(50) constraint ThuThu_TaiKhoan_Unique unique,
MatKhau varchar(50),
HoVaTen varchar(50),
GioiTinh varchar(3),
SoDienThoai varchar(15), 
DiaChiNha varchar(50)
)
Go
Create Table DauSach(
MaSach varchar(10),
TenSach nvarchar(100),
TenNXB varchar(50),
TacGia varchar(50),
SoLuongCuon int constraint DauSach_SoLuongCuon_Duong check (SoLuongCuon>0),
QuocGia varchar(50),
GiaSach int,
Constraint DauSach_Primarykey_MaSach_TenNXB 
	Primary key(MaSach,TenNXB)
)
Go
Create Table DocGia(
MaDocGia varchar(10) constraint DocGia_Primarykey_MaDocGia primary key,
HoVaTen varchar(50),
GioiTinh varchar(3),
NgaySinh datetime,
SoDienThoai varchar(15) constraint DocGia_SoDienThoai_NotNULL not null,
Email varchar(50) constraint DocGia_Email_NotNULL not null,
DiaChi varchar(50),
HinhAnh Image
)
Go
Create Table DangKy(
MaSach varchar(10),
TenNXB varchar(50),
MaDocGia varchar(10) constraint DangKy_Foreignkey_MaDocGia references DocGia(MaDocGia),
NgayDangKy datetime constraint DangKy_NgayDangKy_NotNULL not null,
GhiChu varchar(150),
Constraint DangKy_Primarykey 
	Primary key(MaSach, TenNXB, MaDocGia),
Constraint DangKy_Foreignkey_MaSachTenNXB 
	Foreign key(MaSach, TenNXB) references DauSach(MaSach, TenNXB)
)
Go
Create Table KhuVucSach(
MaKhuVuc varchar(10) constraint KhuVucSach_Primarykey_MaKhuVuc primary key,
TenKhuVuc varchar(50),
IDTT varchar(10) constraint KhuVucSach_Foreignkey_IDTT references ThuThu(ID),
)
Go
Create Table CuonSach(
MaCuon varchar(20) constraint CuonSach_Primarykey_MaCuon primary key,
TienDenBu int,
ThoiGianMuon int,
MaKhuVuc varchar(10) constraint CuonSach_Foreignkey_MaKhuVuc references KhuVucSach(MaKhuVuc),
MaSach varchar(10),
TenNXB varchar(50),
Constraint CuonSach_Foreignkey_MaSachTenNXB 
	Foreign key(MaSach, TenNXB) references DauSach(MaSach, TenNXB)
)
Go
Create Table Muon(
MaCuon varchar(20) constraint Muon_Foreignkey_MaCuon references CuonSach(MaCuon),
MaDocGia varchar(10) constraint Muon_Foreignkey_MaDocGia references DocGia(MaDocGia),
NgayMuon datetime,
NgayHetHan datetime,
MaKhuVucSach varchar(10), 
Constraint Muon_Primarykey Primary key(MaCuon,MaDocGia)
)
Go

CREATE TABLE QuaTrinhMuon 
(
	MaCuon varchar(20),
	MaDocGia varchar(10),
	NgayMuon datetime,
	NgayHetHan datetime,
	MaKhuVucSach varchar(50),
	NgayTra datetime,
	TinhTrang varchar(50),
	TienDen int,
	Constraint QuaTrinhMuon_Primarykey Primary key(MaCuon,MaDocGia)
)
