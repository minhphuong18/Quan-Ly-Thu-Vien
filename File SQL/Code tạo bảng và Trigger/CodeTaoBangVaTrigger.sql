Create Database QuanLyThuVien
Go
Use QuanLyThuVien
Go
Create Table ThuThu(
ID varchar(10) constraint ThuThu_Primarykey_ID primary key,
TaiKhoan varchar(50) constraint ThuThu_TaiKhoan_Unique_NotNULL unique not null,
MatKhau varchar(50) constraint ThuThu_MatKhau_NotNULL not null,
HoVaTen varchar(50),
GioiTinh varchar(3),
SoDienThoai varchar(15), 
DiaChiNha varchar(50)
)
Go
Create Table DauSach(
MaSach varchar(10),
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
	Constraint QuaTrinhMuon_Foreignkey_MaCuonMaDocGia Foreign key (MaCuon, MaDocGia) references Muon (MaCuon, MaDocGia),
	Constraint QuaTrinhMuon_Primarykey Primary key(MaCuon,MaDocGia)
)

alter TRIGGER trigg_gender --OK--
ON THUTHU
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @GENDER VARCHAR(5)

	SELECT @GENDER = inserted.GioiTinh
	FROM inserted

	IF @GENDER != 'NAM' AND @GENDER != 'NU'
		ROLLBACK TRAN
END

GO

CREATE TRIGGER trigg_tien_den --OK--
ON CUONSACH
AFTER INSERT, UPDATE 
AS 
BEGIN
	DECLARE @TIEN_DEN INT, @GIA INT

	SELECT @TIEN_DEN = inserted.TienDenBu, @GIA = DauSach.GiaSach
	FROM inserted, DauSach
	WHERE inserted.MaSach = DauSach.MaSach

	IF @TIEN_DEN > @GIA
		ROLLBACK TRAN
END
Go
----trigger kiem tra so ngay muon (ngay tra - ngay muon)
CREATE TRIGGER trigg_ngay_muon ----OK-----
ON MUON
AFTER INSERT, UPDATE
AS 
BEGIN
	DECLARE @NGAY_MUON DATETIME, @NGAY_TRA DATETIME

	SELECT @NGAY_MUON = inserted.NgayMuon, @NGAY_TRA = inserted.NgayHetHan
	FROM inserted

	IF DATEDIFF(DAY,@NGAY_MUON,@NGAY_TRA ) <= 0
		ROLLBACK TRAN
END
Go

CREATE TRIGGER trigg_truc -----OK-----
ON KHUVUCSACH
AFTER INSERT, UPDATE
AS 
BEGIN
	DECLARE @IDTT varchar(10), @SO_KHU_VUC INT

	SELECT @IDTT = inserted.IDTT
	FROM inserted

	SELECT @SO_KHU_VUC = COUNT(*)
	FROM KhuVucSach
	WHERE KhuVucSach.IDTT = @IDTT

	IF @SO_KHU_VUC != 1
		ROLLBACK TRAN
END

Go

alter TRIGGER trigg_sach-----OK nhung khong can trigger nay-----
ON CUONSACH
AFTER INSERT, UPDATE
AS 
BEGIN
	DECLARE @ID_SACH varchar(20), @SO_KHU_VUC INT

	SELECT @ID_SACH = inserted.MaCuon
	FROM inserted

	SELECT @SO_KHU_VUC = COUNT(*)
	FROM CuonSach
	WHERE CuonSach.MaCuon = @ID_SACH

	IF @SO_KHU_VUC != 1
		ROLLBACK TRAN
END
Go

--Thoi gian muon quy dinh ben bang cuon sach phai lon hon thoi gian muon ben ban muon
ALTER TRIGGER trigg_Thoi_Gian_Muon---------OK----------
ON MUON
AFTER INSERT, UPDATE
AS 
BEGIN
	DECLARE @MA_CUON varchar(20), @NGAY_MUON DATETIME, @NGAY_HET_HAN DATETIME, @THOI_GIAN_MUON INT

	SELECT @MA_CUON = inserted.MaCuon, @NGAY_MUON = inserted.NgayMuon, @NGAY_HET_HAN = inserted.NgayHetHan
	FROM inserted

	SELECT @THOI_GIAN_MUON = CuonSach.ThoiGianMuon
	FROM CuonSach
	WHERE CuonSach.MaCuon = @MA_CUON

	IF DATEDIFF (DAY,@NGAY_MUON, @NGAY_HET_HAN) < @THOI_GIAN_MUON
		ROLLBACK TRAN
END
Go

ALTER TRIGGER trigg_muon_sach ------OK------
ON MUON
AFTER INSERT 
AS 
BEGIN 
	DECLARE @MA_CUON varchar(20),
			@MA_DOC_GIA varchar(20),
			@NGAY_MUON DATETIME = GETDATE(),
			@NGAY_HET_HAN DATETIME,
			@KHU_VUC_SACH varchar(50)

	SELECT @MA_CUON = inserted.MaCuon, @MA_DOC_GIA = inserted.MaDocGia, @NGAY_MUON = inserted.NgayMuon, @NGAY_HET_HAN = inserted.NgayHetHan
	FROM inserted

	SELECT @KHU_VUC_SACH = CuonSach.MaKhuVuc
	FROM CuonSach
	WHERE CuonSach.MaCuon = @MA_CUON

	UPDATE MUON
	SET MaKhuVucSach = @KHU_VUC_SACH
	WHERE MaCuon = @MA_CUON

	EXECUTE Proc_Cho_Muon_sach @MA_CUON, @MA_DOC_GIA, @NGAY_MUON, @NGAY_HET_HAN, @KHU_VUC_SACH
END
Go

ALTER PROCEDURE Proc_Cho_Muon_sach @MA_CUON varchar(20), @MA_DOC_GIA varchar(20), @NGAY_MUON DATETIME, @NGAY_HET_HAN DATETIME, @KHU_VUC_SACH varchar(50)
AS 
BEGIN

	DECLARE @NGAY_TRA DATETIME = NULL, @TINH_TRANG VARCHAR(50) = NULL, @TIEN_DEN INT = NULL
	INSERT INTO QuaTrinhMuon VALUES (@MA_CUON, @MA_DOC_GIA,@NGAY_MUON, @NGAY_HET_HAN,@KHU_VUC_SACH, @NGAY_TRA, @TINH_TRANG, @TIEN_DEN)

	UPDATE CuonSach
	SET MaKhuVuc = NULL
	WHERE CuonSach.MaCuon = @MA_CUON
END
Go


CREATE TRIGGER trigg_tra_sach --------OK-------
ON MUON 
AFTER DELETE
AS 
BEGIN
	DECLARE @MA_CUON varchar(20),
			@MA_DOC_GIA varchar(10),
			@NGAY_MUON DATETIME,
			@NGAY_HET_HAN DATETIME,
			@KHU_VUC_SACH varchar(50)
	SELECT @MA_CUON =deleted.MaCuon, @MA_DOC_GIA = deleted.MaDocGia, @NGAY_MUON = deleted.NgayMuon, @NGAY_HET_HAN = deleted.NgayHetHan, @KHU_VUC_SACH = deleted.MaKhuVucSach
	FROM deleted

	EXECUTE Proc_tra_sach @MA_CUON, @MA_DOC_GIA, @NGAY_MUON, @NGAY_HET_HAN, @KHU_VUC_SACH
END
Go
CREATE PROCEDURE Proc_tra_sach @MA_CUON varchar(20), @MA_DOC_GIA varchar(10), @NGAY_MUON DATETIME, @NGAY_HET_HAN DATETIME, @KHU_VUC_SACH varchar(50)
AS 
BEGIN
	UPDATE QuaTrinhMuon
	SET NgayTra = GETDATE(), TinhTrang = NULL, TienDen = 0

	UPDATE CuonSach
	SET MaKhuVuc = @KHU_VUC_SACH
	WHERE CuonSach.MaCuon = @MA_CUON

END
Go


CREATE TRIGGER trigg_sua_trang_thai 
ON QUATRINHMUON
AFTER UPDATE 
AS
BEGIN
	DECLARE @TINH_TRANG VARCHAR(50), @MA_CUON varchar(20) , @NGAY_MUON DATETIME, @NGAY_TRA DATETIME

	SELECT @TINH_TRANG = inserted.TinhTrang, @NGAY_MUON = inserted.NgayMuon, @NGAY_TRA = inserted.NgayTra, @MA_CUON = inserted.MaCuon
	FROM inserted

	UPDATE QuaTrinhMuon
	SET TienDen = DBO.Func_tinh_tien_den(@MA_CUON, @NGAY_MUON, @NGAY_TRA, @TINH_TRANG)

END
Go
CREATE FUNCTION Func_tinh_tien_den (@MA_CUON INT, @NGAY_MUON DATETIME, @NGAY_TRA DATETIME , @TINH_TRANG VARCHAR(50))
RETURNS INT
AS 
BEGIN
	DECLARE @TIEN_DEN INT, @TIEN_SACH INT
	IF DATEDIFF(DAY,@NGAY_MUON, @NGAY_TRA) < 0
		SET @TIEN_DEN +=( DATEDIFF (DAY,@NGAY_MUON, @NGAY_TRA)/7)*10000

	SELECT @TIEN_SACH = CuonSach.TienDenBu
	FROM CuonSach
	WHERE CuonSach.MaCuon = @MA_CUON

	IF @TINH_TRANG != 'OK'
		SET @TIEN_DEN += @TIEN_SACH
	RETURN @TIEN_DEN
END
Go
