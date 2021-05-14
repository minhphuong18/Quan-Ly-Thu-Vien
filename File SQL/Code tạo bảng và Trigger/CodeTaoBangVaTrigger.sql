﻿Create Database QuanLyThuVien
Go
Use QuanLyThuVien
Go
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

--Trigger kiem tra gender cua ThuThu: 'Nam' or 'Nu'
Create TRIGGER trigg_ThuThu_gender --OK--
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

--Trigger kiem tra: Tiendenbu(CuonSach) nhap vao phai nho hon gia sach(Dau sach)
CREATE TRIGGER trigg_CuonSach_tien_den --OK--
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

--Trigger kiem tra: ngay tra nhap vao phai lon hon ngay muon
CREATE TRIGGER trigg_Muon_ngay_muon ----OK-----
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

--Mot ThuThu chi duoc truc o 1 khu vuc duy nhat
CREATE TRIGGER trigg_KhuVucSach_truc -----OK-----
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

--Thoi gian muon quy dinh ben bang cuon sach phai lon hon thoi gian muon ben ban muon

--Thoi gian cho muon phai nho hon thoi gian toi da

--Co the chinh sua thanh tu dong cap nhat: ngay het han theo ngay bat dau(bang Muon) va so ngay muon(Cuon Sach)
Create TRIGGER trigg_Muon_Thoi_Gian_Muon---------OK----------
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

	IF (DATEDIFF (DAY,@NGAY_MUON, @NGAY_HET_HAN) > @THOI_GIAN_MUON)
		ROLLBACK TRAN;
END
Go

--Trigger cap nhat khu vuc sach cho cuon sach duoc muon
--Cap nhat vao bang Qua Trinh Muon cac thong tin cua bang Muon
CREATE TRIGGER trigg_muon_sach ------OK------
ON MUON
AFTER INSERT 
AS 
BEGIN 
	DECLARE @MA_CUON varchar(20),
			@MA_DOC_GIA varchar(20),
			@NGAY_MUON DATETIME = GETDATE(),
			@NGAY_HET_HAN DATETIME,
			@KHU_VUC_SACH varchar(10)
	
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

CREATE PROCEDURE Proc_Cho_Muon_sach @MA_CUON varchar(20), @MA_DOC_GIA varchar(20), @NGAY_MUON DATETIME, @NGAY_HET_HAN DATETIME, @KHU_VUC_SACH varchar(50)
AS 
BEGIN

	DECLARE @NGAY_TRA DATETIME = NULL, @TINH_TRANG VARCHAR(50) = NULL, @TIEN_DEN INT = NULL
	INSERT INTO QuaTrinhMuon VALUES (@MA_CUON, @MA_DOC_GIA,@NGAY_MUON, @NGAY_HET_HAN,@KHU_VUC_SACH, @NGAY_TRA, @TINH_TRANG, @TIEN_DEN)

	--Cuon sach do hien dang duoc muon
	UPDATE CuonSach
	SET MaKhuVuc = NULL
	WHERE CuonSach.MaCuon = @MA_CUON
END
Go
--Cai nay chiu day
CREATE TRIGGER trigg_tra_sach --------CHUA OK-------
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

--Khi cap nhat Tinh_Trang, Ngay_Muon, Ngay_Tra thi se tu tinh Tien den
CREATE TRIGGER trigg_sua_trang_thai 
ON QUATRINHMUON
AFTER UPDATE 
AS
BEGIN
	DECLARE @TINH_TRANG VARCHAR(50), @MA_CUON varchar(20) , @Ngay_Het_Han DATETIME, @NGAY_TRA DATETIME

	SELECT @TINH_TRANG = inserted.TinhTrang, @Ngay_Het_Han = inserted.NgayHetHan, @NGAY_TRA = inserted.NgayTra, @MA_CUON = inserted.MaCuon
	FROM inserted

	UPDATE QuaTrinhMuon
	SET TienDen = DBO.Func_tinh_tien_den(@MA_CUON, @Ngay_Het_Han, @NGAY_TRA, @TINH_TRANG)
	WHERE QuaTrinhMuon.MaCuon = @MA_CUON

END
Go

--Function tra ve so tien phai den
ALTER FUNCTION Func_tinh_tien_den (@MA_CUON VARCHAR(20), @Ngay_Het_Han DATETIME, @NGAY_TRA DATETIME , @TINH_TRANG VARCHAR(50))
RETURNS INT
AS 
BEGIN
	DECLARE @TIEN_DEN INT, @TIEN_SACH INT
	IF DATEDIFF(DAY,@Ngay_Het_Han, @NGAY_TRA) < 0
		SET @TIEN_DEN +=( DATEDIFF (DAY,@Ngay_Het_Han, @NGAY_TRA)/7)*10000

	SELECT @TIEN_SACH = CuonSach.TienDenBu
	FROM CuonSach
	WHERE CuonSach.MaCuon = @MA_CUON

	IF @TINH_TRANG != 'OK'
		SET @TIEN_DEN += @TIEN_SACH
	RETURN @TIEN_DEN
END
Go

--Trigger kiem tra xem so luong cuon sach co vuot qua so luong sach toi da khong?
CREATE TRIGGER trigg_CuonSach_SLSach
ON CuonSach
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MASACH VARCHAR(10),@TENNXB VARCHAR(50),@SLSACHTOIDA INT,@SLSACHHIENTAI INT
	
	--Lay ra ma dau sach cua cuon sach duoc them vao/chinh sua
	SELECT @MASACH=inserted.MaSach,@TENNXB=inserted.TenNXB
	FROM inserted;
	
	--Lay ra so luong sach toi da tu bang DauSach
	SELECT @SLSACHTOIDA=SoLuongCuon
	FROM DauSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB;

	--Tinh ra so luong sach hien tai tu bang CuonSach
	SELECT @SLSACHHIENTAI=COUNT(*)
	FROM CuonSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB

	IF(@SLSACHHIENTAI>@SLSACHTOIDA)
	BEGIN
		PRINT 'So luong cuon sach da vuot qua so luong sach hien co';
		Rollback Tran;
	END
END

--Trigger kiem tra cuon sach duoc muon co dang bi muon boi DocGia khac khong
CREATE TRIGGER trigg_Muon_CheckMaCuon
ON MUON
AFTER INSERT,UPDATE
AS
BEGIN
	DECLARE @MACUON VARCHAR(10),@SL int
	
	--Lay MaCuon duoc them vao/chinh sua
	SELECT @MACUON=MaCuon
	From inserted

	--Dem so luongTRIGGER trigg_Muon_CheckMaCuon
	SELECT @SL=count(*)
	FROM Muon
	WHERE MaCuon=@MACUON
	--Kiem tra xem cuon sach da duoc muon chua
	IF ( @SL>=2)
	BEGIN
		PRINT 'Cuon sach nay da duoc muon roi. Vui long kiem tra lai MaCuon';
		Rollback Tran;
	END
END;

CREATE TRIGGER trigg_MUON_CheckDangKy
ON MUON
AFTER UPDATE
AS
BEGIN
	DECLARE @MASACH VARCHAR(10),@TENNXB VARCHAR(50),@SLSACHMUON INT,@SLSACHDANGKY INT,@TONGSL INT,@SLMAX INT

	--Lay ra Masach cua CuonSach duocmuon
	SELECT @MASACH=MaSach,@TENNXB=TenNXB
	FROM inserted, CuonSach
	Where inserted.MaCuon=CuonSach.MaCuon;

	--Lay ra SLMax(so luong cuon sach) hien co cua MaSach do
	SELECT @SLMAX=SoLuongCuon
	FROM DauSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB;

	--Lay ra so luong CuonSach dang duoc muon cua MaSach: 
	--Count(*) - 1(Do luot nay cua DocGia hien tai muon)
	SELECT @SLSACHMUON=COUNT(*)
	FROM MUON M,CuonSach CS
	WHERE M.MaCuon=CS.MaCuon AND CS.MaSach=@MASACH AND CS.TenNXB=@TENNXB

	Set @SLSACHMUON-=1;

	--Lay ra so luong CuonSach dang duoc dang ky o bang DangKy
	SELECT @SLSACHDANGKY=COUNT(*)
	FROM DangKy
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB

	--Tinh Tong so luong sach= @SLSachMuon + @SLSachDangKy
	Set @TONGSL=@SLSACHMUON+@SLSACHDANGKY
	--Neu tong @TongSL < @SLMAX thi cho muon
	--Neu be hon thi xet DocGia do co dang ky muon sach nay ko? Xet thu tu dang ky cua DocGia nay
	IF(@TONGSL>=@SLMAX)
	BEGIN
		--Neu toan bo sach deu da duoc Muon roi thi ko cho muon nua
		IF(@SLSACHMUON>=@SLMAX)
		BEGIN
			PRINT 'Toan bo sach da duoc muon';
			ROLLBACK;
		END
		ELSE
		BEGIN
			--Xet xem DocGia co so thu tu dang ky muon sach la bao nhieu?
			-- -->Co duoc muon hay khong?
			--Nguoi ko dang ky truoc --> khong duoc muon
			DECLARE @STT INT, @MADOCGIA varchar(10)

			SELECT @MADOCGIA=inserted.MaDocGia
			FROM inserted;
			
			IF( Not Exists(SELECT * 
						  FROM DangKy
						  Where MaSach=@MASACH and TenNXB=@TENNXB and MaDocGia=@MADOCGIA))
			BEGIN
				PRINT 'Toan bo sach da duoc muon va dang ky.';
				Rollback Tran;
			END
			ELSE
				BEGIN
					--Lay stt dang ky
					SET @STT=dbo.Func_DangKy_BangSTTDangKy(@MASACH,@TENNXB,@MADOCGIA)
					--Truong hop chua den so thu tu dang ky muon sach
					IF(@STT+@SLSACHMUON > @SLMAX)
					BEGIN
						PRINT 'Hien tai chua toi luot muon sach cua ban. Vui long quay lai sau';
						Rollback Tran;
					END
					ELSE
					--Truong hop @STT+@SLSACHMUON <= @SLMAX thi DocGia da dang ky do se duoc muon
					BEGIN
						--Xoa luot dang ky do
						EXEC dbo.Proc_Xoa_DangKy @MASACH,@TENNXB,@MADOCGIA;
					END
				END
		 END
	END
	ELSE
	BEGIN
		IF( Not Exists(SELECT * 
						  FROM DangKy
						  Where MaSach=@MASACH and TenNXB=@TENNXB and MaDocGia=@MADOCGIA))
		EXEC dbo.Proc_Xoa_DangKy @MASACH,@TENNXB,@MADOCGIA;
	END
END;

Create Procedure Proc_Xoa_DangKy
@MaSach varchar(10),
@TenNXB varchar(50),
@MaDocGia varchar(10)
AS
Begin
	Delete DangKy
	Where MaSach=@MaSach and TenNXB=@TenNXB and MaDocGia=@MaDocGia
End
Go


--Function tra ve stt dang ky cua DocGia, MaSach do
Create FUNCTION Func_DangKy_BangSTTDangKy(@MASACH VARCHAR(10),@TENNXB VARCHAR(50),@MADOCGIA varchar(10))
RETURNS INT
AS
Begin
	Declare @Stt int
	
	--Lay so thu tu
	Select @Stt=STT
	From(
	--Gan STT dang ky cua DocGia cho tung MaSach duoc dang ky
	Select ROW_NUMBER() OVER (PARTITION BY MaSach,TenNXB Order by MaSach,TenNXB,NgayDangKy) as STT,
	MaSach,TenNXB,MaDocGia,NgayDangKy,GhiChu
	From DangKy) as KQ
	Where MaSach=@MASACH and TenNXB=@TENNXB and MaDocGia=@MADOCGIA
	
	Return @Stt;
End

----------------------------------------INSERT DU LIEU-----------------------------------------
-----------------------------------------------------------------------------------------------
-------PHUONG--------
----- THU THU ------OK-----
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT01', 'adminTT01', 'adminTT01', 'Nguyen Duc Tri', 'Nam', '0715246852', '05 Thu Duc');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT02', 'adminTT02', 'adminTT02', 'Truong Minh Phuong', 'Nam', '0736985214', '8 Binh Duong');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT03', 'adminTT03', 'adminTT03', 'Nguyen Minh Dang', 'Nam', '0754251599', '07 Go Vap');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT04', 'adminTT04', 'adminTT04', 'Le Quoc Vinh', 'Nam', '0725325236', '161 Dinh Tien Hoang');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT05', 'adminTT05', 'adminTT05', 'Nguyen Phuoc Dang', 'Nam', '0747584710', '7 Quang Dong');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT06', 'adminTT06', 'adminTT06', 'Thach Duong Duy', 'Nam', '0796969658', '2 Hoang Dieu');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT07', 'adminTT07', 'adminTT07', 'Nguyen Quoc Thang', 'Nam', '0723214256', '052 Xom Moi');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT08', 'adminTT08', 'adminTT08', 'Nguyen Hoang Vu', 'Nam', '0765252546', '85647 Le Van Tho');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT09', 'adminTT09', 'adminTT09', 'Nguyen Phuoc Thang', 'Nam', '0731256215', '7277 Le Duc Tho');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT10', 'adminTT10', 'adminTT10', 'Tran Minh Sang', 'Nam', '0752536325', '34251 Hai Ba Trung');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT11', 'adminTT11', 'adminTT11', 'Thach Duong Phuong', 'Nam', '07235462145', '41132 Le Loi');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT12', 'adminTT12', 'adminTT12', 'Dang Nhat Tien', 'Nam', '0126589657', '80 Nguyen Van Luong');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT13', 'adminTT13', 'adminTT13', 'Son Thach', 'Nam', '0965236541', '865 Nguyen Trai');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT14', 'adminTT14', 'adminTT14', 'Nguyen Duc Duc', 'Nam', '0958478586', '4022 Tran Hung Dao');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT15', 'adminTT15', 'adminTT15', 'Do Hong Duc', 'Nam', '0754125250', '222 Dinh Tien Hoang');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT16', 'adminTT16', 'adminTT16', 'Do Duy Tan', 'Nam', '09658625420', '6757 Thong Nhat');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT17', 'adminTT17', 'adminTT17', 'Tran Minh Phong', 'Nam', '0752149634', '460 Quang Trung');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT18', 'adminTT18', 'adminTT18', 'Nguyen Quoc Anh', 'Nam', '0765896525', '53 Hoang Dieu 2');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT19', 'adminTT19', 'adminTT19', 'Le Van Duc', 'Nam', '0754853652', '631 Luong The Vinh');
insert into ThuThu (ID, TaiKhoan, MatKhau, HoVaTen, GioiTinh, SoDienThoai, DiaChiNha) values ('TT20', 'adminTT20', 'adminTT20', 'Nguyen Thi Tuyet', 'Nu', '012654783521', '730 Le Quy Don');

--KhuVucSach-----OK-----
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('A1', 'Giao Duc','TT01');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('A2', 'Thieu Nhi', 'TT02');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('A3', 'Tham Khao', 'TT03');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B1', 'Truyen', 'TT04');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B2', 'Nuoc Ngoai', 'TT05');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B3', 'Phap Luat', 'TT06');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B4', 'Y Hoc', 'TT07');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B5', 'Khoa Hoc Ky Thuat', 'TT08');
insert into KhuVucSach (MaKhuVuc, TenKhuVuc, IDTT) values ('B6', 'Giao Trinh', 'TT09');



--DAU SACH-------OK------
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('VHVN','Van hoc Viet Nam','Kim Dong','Nguyen Minh Dang',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('VHNN','Van hoc nuoc ngoai','Hoi Nha Van','Doan Duc Hieu',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('THVN','Tin hoc Viet Nam','Giao Duc','Nguyen Duc Tri',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('THNN','Tin hoc nuoc ngoai','Giao Duc','Nguyen Duc Tri',5,'Nga',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHQS','Khoa hoc quan su','Khoa hoc tu nhien va Cong nghe','Le Quoc Vinh',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHTG','Khoa hoc the gioi','Khoa hoc tu nhien va Cong nghe','Nelson Mandela',5,'My',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHVN','Khoa hoc Viet Nam','Khoa hoc va Ky thuat','Le Quoc Vinh',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHTH','Y hoc tong hop','Y hoc','Jonh Smith ',5,'Cuba',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHCM','Y hoc chuyen mon','Y hoc','Truong Minh Phuong',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHCT','Y hoc co truyen','Y hoc','Truong Minh Phuong',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('DSTT','Dai so tuyen tinh','Dai hoc Quoc Gia thanh pho Ho Chi Minh','Hong Ha',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN1','Toan 1','Dai hoc Su pham','Nguyen Van Toan',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN2','Toan 2','Dai hoc Su pham','Nguyen Van Toan',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN3','Toan 3','Dai hoc Su pham','Nguyen Van Toan',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KINHTEDC1','Kinh te hoc dai cuong 1','Tri thuc','Do Thanh Nga',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KINHTEDC2','Kinh te hoc dai cuong 2','Tri thuc','Do Thanh Nga',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('NMLT','Nhap mon lap trinh','Khoa hoc tu nhien va Cong nghe','Tran Cong Tu',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KTLT','Ky thuat lap trinh','Khoa hoc va Ky thuat','Tran Cong Tu',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TTLDCN','Tham tu lung danh conan','Kim Dong','Gosho Aoyama',5,'Nhat Ban',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('DL','Deep Learning','Van hoa - Thong tin','Tu hoc IT',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('MCL','Machine Learning','Van hoa - Thong tin','Tu hoc IT',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TTHCM','Tu tuong Ho Chi Minh','Chinh tri Quoc Gia','Phan Dong',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('PLDC','Phap luat dai cuong','Chinh tri Quoc Gia','Phan Dong',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('HP2013','Hien phap 2013','Su That','Chinh Tri gia',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('HP1992','Hien phap 1992','Su That','Chinh Tri gia',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('CTVN','Co tich Viet Nam','Tuoi Tre','Cu Trong Xoay',5,'Viet Nam',50000)
insert into DauSach(MaSach,TenSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TG','Hoi xoay dap xoay','Tuoi Tre','Cu Trong Xoay',5,'Viet Nam',50000)

--Cuon sach--------OK--------
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKVHVN01', 50000, 30, 'A3','VHVN' , 'Kim Dong');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKVHNN01', 50000, 30, 'A3', 'VHNN', 'Hoi Nha Van');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTHVN01', 50000, 30, 'A1', 'THVN', 'Giao Duc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTHNN01', 50000, 30, 'B2','THNN' , 'Giao Duc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHQS01', 50000, 30, 'B5', 'KHQS', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHTG01', 50000, 30, 'B2', 'KHTG', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHVN01', 50000, 30, 'B5', 'KHVN', 'Khoa hoc va Ky thuat');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHTH01', 50000, 30, 'B4', 'YHTH', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHCM01', 50000, 30, 'B4', 'YHCM', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHCT01', 50000, 30, 'B4', 'YHCT', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTDSTT01', 50000, 120, 'B6', 'DSTT', 'Dai hoc Quoc Gia thanh pho Ho Chi Minh');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN101', 50000, 120, 'B6', 'TOAN1', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN201', 50000, 120, 'B6', 'TOAN2', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN301', 50000, 120, 'B6', 'TOAN3', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTKINHTEDC101',50000, 120,'B6','KINHTEDC1', 'Tri thuc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTNMLT01', 50000, 120, 'B6', 'NMLT', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTKTLT01', 50000, 120, 'B6', 'KTLT', 'Khoa hoc va Ky thuat');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTTLDCN01', 50000, 30, 'B2', 'TTLDCN', 'Kim Dong');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKDL01', 50000, 30, 'A3', 'DL', 'Van hoa - Thong tin');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKMCL01', 50000, 30, 'A3', 'MCL', 'Van hoa - Thong tin');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTTHCM01', 50000, 30, 'A3', 'TTHCM', 'Chinh tri Quoc Gia');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKPLDC01', 50000, 30, 'B3', 'PLDC', 'Chinh tri Quoc Gia');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKHP201301', 50000, 30, 'A3', 'HP2013', 'Su That');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKHP199201', 50000, 30, 'A3', 'HP1992', 'Su That');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKCTVN01', 50000, 30, 'A3', 'CTVN', 'Tuoi Tre');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTG01', 50000, 30, 'A3', 'TG', 'Tuoi Tre');


insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKVHVN02', 50000, 30, 'A3','VHVN' , 'Kim Dong');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKVHNN02', 50000, 30, 'A3', 'VHNN', 'Hoi Nha Van');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTHVN02', 50000, 30, 'A1', 'THVN', 'Giao Duc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTHNN02', 50000, 30, 'B2','THNN' , 'Giao Duc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHQS02', 50000, 30, 'B5', 'KHQS', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHTG02', 50000, 30, 'B2', 'KHTG', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKKHVN02', 50000, 30, 'B5', 'KHVN', 'Khoa hoc va Ky thuat');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHTH02', 50000, 30, 'B4', 'YHTH', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHCM02', 50000, 30, 'B4', 'YHCM', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKYHCT02', 50000, 30, 'B4', 'YHCT', 'Y hoc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTDSTT02', 50000, 120, 'B6', 'DSTT', 'Dai hoc Quoc Gia thanh pho Ho Chi Minh');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN102', 50000, 120, 'B6', 'TOAN1', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN202', 50000, 120, 'B6', 'TOAN2', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTTOAN302', 50000, 120, 'B6', 'TOAN3', 'Dai hoc Su pham');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTKINHTEDC102', 50000, 120, 'B6', 'KINHTEDC1', 'Tri thuc');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTNMLT02', 50000, 120, 'B6', 'NMLT', 'Khoa hoc tu nhien va Cong nghe');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('GTKTLT02', 50000, 120, 'B6', 'KTLT', 'Khoa hoc va Ky thuat');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTTLDCN02', 50000, 30, 'B2', 'TTLDCN', 'Kim Dong');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKDL02', 50000, 30, 'A3', 'DL', 'Van hoa - Thong tin');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKMCL02', 50000, 30, 'A3', 'MCL', 'Van hoa - Thong tin');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTTHCM02', 50000, 30, 'A3', 'TTHCM', 'Chinh tri Quoc Gia');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKPLDC02', 50000, 30, 'B3', 'PLDC', 'Chinh tri Quoc Gia');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKHP201302', 50000, 30, 'A3', 'HP2013', 'Su That');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKHP199202', 50000, 30, 'A3', 'HP1992', 'Su That');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKCTVN02', 50000, 30, 'A3', 'CTVN', 'Tuoi Tre');
insert into CuonSach (MaCuon, TienDenBu, ThoiGianMuon, MaKhuVuc, MaSach, TenNXB) values ('TKTG02', 50000, 30, 'A3', 'TG', 'Tuoi Tre');
--------------VINH------------------
--DOC GIA----------OK--------
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG001', 'Nguyen Van A', 'Nam', '01-01-1975', '0376621299','19110029@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG002', 'Nguyen Van B', 'Nam', '01-01-1976', '0376621298','19110030@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG003', 'Nguyen Thi C', 'Nu', '01-01-1977', '0376621297','19110031@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG004', 'Nguyen Van D', 'Nam', '01-01-1978', '0376621296','19110032@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG005', 'Nguyen Van E', 'Nam', '04-15-2002', '0376621295','19110033@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG006', 'Tran Van Mot', 'Nam', '07-18-2003', '0376621294','19110034@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG007', 'Tran Thi Hai', 'Nu', '07-29-2001', '0376621293','19110035@student.hcmute.edu.vn','01 Vo Van Ngan',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG008', 'Tran Thi Ba', 'Nu', '04-15-2003', '0376621292','19110036@student.hcmute.edu.vn','10 Nguyen Trai',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG009', 'Tran Van Tu', 'Nam', '02-28-2003', '0376621291','19110037@student.hcmute.edu.vn','321 Nguyen Binh Khiem',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG010', 'Tran Van Nam', 'Nam', '01-24-2005', '0376621290','19110038@student.hcmute.edu.vn','20 Hang Ngang',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG011', 'Nguyen Tran Thi Van', 'Nam', '05-15-2004', '0376621289','19110039@student.hcmute.edu.vn','03 Khu pho 2',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG012', 'Nguyen Tran Thi Toan', 'Nu', '07-10-1997', '0376621288','19110040@student.hcmute.edu.vn','191 Khu pho 2',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG013', 'Nguyen Tran Thi Hoa', 'Nu', '04-16-2001', '0376621287','19110041@student.hcmute.edu.vn','333 Hang Bia',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG014', 'Nguyen Tran Thi Ly', 'Nu', '04-15-2001', '0376621286','19110042@student.hcmute.edu.vn','334 Hang Bia',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG015', 'Nguyen Tran Thi Sinh', 'Nam', '02-25-1989', '0376621285','19110043@student.hcmute.edu.vn','04 Hai Ba Trung',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG016', 'Le Van Cuong', 'Nam', '12-31-1999', '0376621284','19110044@student.hcmute.edu.vn','06 Hai Ba Trung',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG017', 'Le Van Kien', 'Nam', '04-14-2000', '0376621283','19110045@student.hcmute.edu.vn','10 Hai Ba Trung',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG018', 'Le Hoai Nam', 'Nam', '02-15-2000', '0376621282','19110046@student.hcmute.edu.vn','10 Hai Ba Trung',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG019', 'Le Hoang Tuan', 'Nam', '03-14-1998', '0376621281','19110047@student.hcmute.edu.vn','484 Le Van Viet',NULL)
INSERT INTO DocGia(MaDocGia, HoVaTen, GioiTinh, NgaySinh, SoDienThoai, Email, DiaChi, HinhAnh) values('DG020', 'Le Ngoc Bich', 'Nu', '01-10-1999', '0376621280','19110048@student.hcmute.edu.vn','484 Le Van Viet',NULL)
--DANG KY----------OK---------
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('VHVN', 'Kim Dong', 'DG001', '01-01-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('THVN', 'Giao Duc', 'DG002', '10-01-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHQS', 'Khoa hoc tu nhien va Cong nghe','DG003', '01-01-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHTG', 'Khoa hoc tu nhien va Cong nghe','DG003', '01-01-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHVN','Khoa hoc va Ky thuat', 'DG004', '12-04-2001', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHVN','Khoa hoc va Ky thuat', 'DG005', '12-05-2001', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('YHTH','Y hoc', 'DG005', '12-05-2001', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('YHCM','Y hoc', 'DG005', '12-05-2001', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('YHCT','Y hoc', 'DG005', '12-05-2001', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('DSTT','Dai hoc Quoc Gia thanh pho Ho Chi Minh', 'DG006', '04-07-2015', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('TG','Tuoi Tre', 'DG010', '02-17-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('CTVN','Tuoi Tre', 'DG010', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('HP1992','Su That', 'DG010', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('HP1992','Su That', 'DG011', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('HP2013','Su That', 'DG011', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('TOAN1','Dai hoc Su pham', 'DG012', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KINHTEDC1','Tri thuc', 'DG012', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('DSTT','Dai hoc Quoc Gia thanh pho Ho Chi Minh', 'DG012', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('NMLT','Khoa hoc tu nhien va Cong nghe', 'DG015', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KTLT','Khoa hoc va Ky thuat', 'DG015', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHQS','Khoa hoc tu nhien va Cong nghe', 'DG015', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('VHVN','Kim Dong', 'DG015', '02-18-2020', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('VHVN','Kim Dong', 'DG016', '03-12-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KHVN','Khoa hoc va Ky thuat', 'DG016', '03-12-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('HP2013','Su That', 'DG016', '03-12-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('CTVN','Tuoi Tre', 'DG016', '03-13-2021', 'Khong')	
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('CTVN','Tuoi Tre', 'DG017', '03-13-2021', 'Khong')	
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('HP2013','Su That', 'DG017', '03-12-2021', 'Khong')
INSERT INTO DangKy(MaSach, TenNXB, MaDocGia, NgayDangKy, GhiChu) values('KINHTEDC1','Tri thuc', 'DG017', '03-12-2021', 'Khong')
--------MUON---------
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHVN01', 'DG001','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHNN01', 'DG001','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTHVN01', 'DG001','04-15-2021', '04-30-2021','A1' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHQS01', 'DG002','01-10-2021', '02-01-2021','B5' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHTG01', 'DG002','01-10-2021', '01-31-2021','B2' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHVN01', 'DG003','04-15-2021', '05-14-2021','B5' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHTH01', 'DG003','04-15-2021', '05-15-2021','B4' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHCM01', 'DG004','04-15-2021', '05-01-2021','B4' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHCT01', 'DG005','02-01-2020', '02-28-2020','B4' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTDSTT01', 'DG006','02-01-2021', '02-28-2021','B6' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTTOAN101', 'DG007','04-15-2021', '04-30-2021','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTTOAN201', 'DG007','04-15-2021', '04-30-2021','B6' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTTOAN301', 'DG008','10-02-2020', '10-17-2020','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTKINHTEDC101', 'DG008','10-02-2020', '10-17-2020','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTKINHTEDC101', 'DG009','04-01-2021', '04-30-2021','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTNMLT01', 'DG009','04-01-2021', '04-30-2021','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTKTLT01', 'DG010','04-10-2021', '04-20-2021','B6' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTLDCN01', 'DG010','04-10-2021', '04-20-2021','B2' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKDL01', 'DG011','04-15-2020', '04-30-2020','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKMCL01', 'DG011','04-15-2020', '04-30-2020','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTHCM01', 'DG011','04-30-2021', '05-10-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKPLDC01', 'DG011','04-30-2021', '05-10-2021','B3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201301', 'DG012','07-15-2022', '07-30-2022','A3' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG012','07-15-2022', '07-20-2022','A3' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHVN02', 'DG015','04-15-2022', '04-30-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHNN02', 'DG015','04-15-2022', '04-30-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTHVN02', 'DG015','04-15-2022', '04-30-2022','A1' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTG02', 'DG016','01-03-2021', '02-01-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKCTVN02', 'DG016','01-01-2021', '01-31-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199202', 'DG016','01-01-2021', '01-31-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201302', 'DG016','01-01-2021', '01-31-2021','A3' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTHCM02', 'DG016','04-15-2021', '05-08-2021','A3' )

------QUA TRINH MUON-------

------------DUC TRI-------------
--PROC IN RA DANH SACH QUA HAN SACH
CREATE PROCEDURE PROC_DANH_SACH_QUA_HAN
AS 
BEGIN
	SELECT *
	FROM Muon
	WHERE DATEDIFF(DAY,MUON.NgayHetHan, GETDATE()) > 0
END
EXEC PROC_DANH_SACH_QUA_HAN
--PROC IN RA DANH SACH TOI HAN TRA SACH
CREATE PROCEDURE PROC_DANH_SACH_TOI_HAN_TRA
AS
BEGIN
	SELECT *
	FROM Muon
	WHERE DATEDIFF(DAY,MUON.NgayHetHan, GETDATE()) = 0
END
--a
EXEC PROC_DANH_SACH_TOI_HAN_TRA 

--PROC IN RA CAC MA CUON VA DOC GIA DA MUON THEO MA SACH
CREATE PROCEDURE PROC_DANH_SACH_DA_MUON @MASACH VARCHAR(10)
AS
BEGIN
	SELECT MUON.MaCuon, NgayMuon, NgayHetHan
	FROM MUON, CuonSach
	WHERE MUON.MaCuon = CuonSach.MaCuon AND CuonSach.MaSach = @MASACH
END
EXEC PROC_DANH_SACH_DA_MUON 'TKVHVN01'

-- TAO TAI KHOAN CHO THU THU
CREATE TRIGGER TRIGG_THEM_THU_THU
ON THUTHU
AFTER INSERT
AS 
BEGIN
	DECLARE @MA_TT VARCHAR(10)
	SELECT @MA_TT = inserted.ID
	FROM inserted

	UPDATE ThuThu
	SET TaiKhoan = @MA_TT, MatKhau = '1'
	WHERE ThuThu.ID = @MA_TT
END
-----------------------
-- MẤT SÁCH THÌ SẼ XÓA ĐI MÃ CUỐN ĐÓ BÊN BẢNG MƯỢN VÀ CUỐN SÁCH

ALTER TRIGGER TRIGG_MAT_SACH --------------THANH CONG 50%-----------------
ON QUATRINHMUON
AFTER UPDATE
AS 
BEGIN
	DECLARE @TINH_TRANG VARCHAR(50), @MA_CUON VARCHAR(20), @MA_SACH VARCHAR(20), @DATE_DIE DATETIME, @DATE_START DATETIME
	SELECT @TINH_TRANG =inserted.TinhTrang, @MA_CUON = inserted.MaCuon, @MA_SACH = CuonSach.MaSach, @DATE_DIE = inserted.NgayHetHan, @DATE_START = inserted.NgayMuon
	FROM inserted, CuonSach
	WHERE inserted.MaCuon = CuonSach.MaCuon 

	IF @TINH_TRANG = 'MAT'
	BEGIN
		DELETE Muon
		WHERE Muon.MaCuon = @MA_CUON

		DELETE CuonSach
		WHERE CuonSach.MaCuon = @MA_CUON

		UPDATE DauSach
		SET SoLuongCuon = SoLuongCuon - 1
		WHERE DauSach.MaSach = @MA_SACH

		UPDATE QuaTrinhMuon
		SET TienDen = DBO.Func_tinh_tien_den(@MA_CUON,@DATE_DIE,GETDATE(), @TINH_TRANG)
		WHERE MaCuon = @MA_CUON
	END
END


select * from CUONSACH where MaCuon= 'TKYHCT01'

SELECT *
FROM CuonSach
WHERE CuonSach.MaCuon = 'TKYHCT01'

SELECT *
FROM DauSach




-----------------
-- PROC IN RA SO SACH MA TAT CA DOC GIA ĐÃ MƯỢN
CREATE PROCEDURE PROC_SO_SACH_MUON
AS 
BEGIN
	SELECT DocGia.MaDocGia, DocGia.HoVaTen, COUNT(MaCuon) AS SO_LUON_SACH_DA_MUON
	FROM Muon, DocGia
	WHERE Muon.MaDocGia = DocGia.MaDocGia
	GROUP BY DocGia.MaDocGia, HoVaTen
END
exec PROC_SO_SACH_MUON
CREATE PROCEDURE PROC_DANH_SACH_DA_TRA
AS 
BEGIN
	SELECT MACUON, MaKhuVucSach, TinhTrang
	FROM QuaTrinhMuon
	WHERE QuaTrinhMuon.NgayTra = GETDATE()
END
exec PROC_DANH_SACH_DA_TRA

--so luong sach da muon theo ma sach
alter PROCEDURE PROC_SO_SACH_DA_MUON
AS 
BEGIN
	SELECT CuonSacH.MaSach,DauSach.TENSACH, COUNT(MUON.MaCuon) AS SO_LUON_SACH_DA_MUON
	FROM CuonSach, MUON, DauSach
	WHERE CuonSach.MaCuon = MUON.MaCuon AND DauSach.MaSach = CuonSach.MaSach
	GROUP BY CuonSach.MaSach, DauSach.TENSACH
END
exec PROC_SO_SACH_DA_MUON
--in ra thu thu dang truc theo khu vuc
CREATE PROCEDURE PROC_THU_THU_TRUC @MAKHUVUC VARCHAR(10)
AS 
BEGIN
	SELECT ThuThu.ID, THUTHU.HoVaTen, ThuThu.GioiTinh, ThuThu.SoDienThoai, ThuThu.DiaChiNha
	FROM KhuVucSach, THUTHU
	WHERE KhuVucSach.MaKhuVuc = @MAKHUVUC AND ThuThu.ID = KhuVucSach.IDTT
END

exec PROC_THU_THU_TRUC 'A1'
----------------------MINH DANG PROCEDURE---------------------
--Thu thu
Create Procedure Proc_Them_ThuThu
@ID varchar(10),
@TaiKhoan varchar(50),
@MatKhau varchar(50),
@HoVaTen varchar(50),
@GioiTinh varchar(3),
@SoDienThoai varchar(15),
@DiaChiNha varchar(50)
AS
Begin
	Insert into ThuThu values(@ID, @TaiKhoan,@MatKhau,
	@HoVaTen,@GioiTinh,@SoDienThoai,@DiaChiNha);
End
Go
Exec Proc_Them_ThuThu 'TT01','nmd','123','Nguyen Minh Dang','Nam','0393279375','572k';
Go
Create Procedure Proc_Sua_ThuThu
@ID varchar(10),
@TaiKhoan varchar(50),
@MatKhau varchar(50),
@HoVaTen varchar(50),
@GioiTinh varchar(3),
@SoDienThoai varchar(15),
@DiaChiNha varchar(50)
AS
Begin
	Update ThuThu
	Set TaiKhoan=@TaiKhoan,MatKhau=@MatKhau,HoVaTen=@HoVaTen,
	GioiTinh=@GioiTinh, SoDienThoai=@SoDienThoai, DiaChiNha=@DiaChiNha
	Where ID=@ID
End
Go
Exec Proc_Sua_ThuThu 'TT01','nmd','345','Nguyen Minh Dang','Nam','0393279375','572k ap Ngu Phuc';
Go
Create Procedure Proc_Xoa_ThuThu
@ID varchar(10)
AS
Begin
	Update KhuVucSach
	Set IDTT=NULL
	Where IDTT=@ID

	Delete ThuThu
	Where ID=@ID
End
Go
Exec Proc_Xoa_ThuThu 'TT01';
Go
--Khu Vuc Sach
Create Function Func_Check_KNIDTT(@IDTT varchar(10))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select ID
	From ThuThu
	Where ID=@IDTT)
		Set @check=1;
	return @check;
End
Go
Create Procedure Proc_Them_KhuVucSach
@MaKhuVuc varchar(10),
@TenKhuVuc varchar(50),
@IDTT varchar(10)
AS
Begin
	if(dbo.Func_Check_KNIDTT(@IDTT)=1)
		Insert into KhuVucSach values(@MaKhuVuc,@TenKhuVuc,@IDTT);
	else
		Print 'IDTT khong ton tai';
End
Go
Exec Proc_Them_KhuVucSach 'A01','Tham Khao','TT01';
Go
Create Procedure Proc_Sua_KhuVucSach
@MaKhuVuc varchar(10),
@TenKhuVuc varchar(50),
@IDTT varchar(10)
AS
Begin
	if(dbo.Func_Check_KNIDTT(@IDTT)=1)
		Update KhuVucSach 
		Set TenKhuVuc=@TenKhuVuc, IDTT=@IDTT
		Where MaKhuVuc=@MaKhuVuc;
	else
		Print 'IDTT khong ton tai';
End
Go
Exec Proc_Sua_KhuVucSach 'A01','Giao Trinh','TT01';
Go
Create Procedure Proc_Xoa_KhuVucSach
@MaKhuVuc varchar(10)
As
Begin
	Update CuonSach
	Set MaKhuVuc=null
	Where MaCuon=@MaKhuVuc

	Delete KhuVucSach
	Where MaKhuVuc=@MaKhuVuc
End
Go
Exec Proc_Xoa_KhuVucSach 'A01';
Go
--Dang ky
Create Function Func_Check_KNMaDocGia(@MaDocGia varchar(10))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select MaDocGia
	From DocGia
	Where MaDocGia=@MaDocGia)
		Set @check=1;
	return @check;
End
Go
Create Function Func_Check_KNMaSachTenNXB(@MaSach varchar(10), @TenNXB varchar(50))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select MaSach
	From DauSach
	Where MaSach=@MaSach and TenNXB=@TenNXB)
		Set @check=1;
	return @check;
End
Go
Create Procedure Proc_Them_DangKy
@MaSach varchar(10),
@TenNXB varchar(50),
@MaDocGia varchar(10),
@NgayDangKy datetime,
@GhiChu varchar(150)
AS
Begin
	if(dbo.Func_Check_KNMaDocGia(@MaDocGia)=1)
		if(dbo.Func_Check_KNMaSachTenNXB(@MaSach,@TenNXB)=1)
			Insert into DangKy values(@MaSach,@TenNXB,
			@MaDocGia,@NgayDangKy,@GhiChu);
		else
			Print 'MaSach, TenNXB khong ton tai';
	else
		Print 'MaDocGia khong ton tai';
End
Go
Exec Proc_Them_DangKy 'e','f','2','2001-7-20',null;
Go
Create Procedure Proc_Sua_DangKy
@MaSach varchar(10),
@TenNXB varchar(50),
@MaDocGia varchar(10),
@NgayDangKy datetime,
@GhiChu varchar(150)
AS
Begin
	if(dbo.Func_Check_KNMaDocGia(@MaDocGia)=1)
		if(dbo.Func_Check_KNMaSachTenNXB(@MaSach,@TenNXB)=1)
			Update DangKy
			Set NgayDangKy=@NgayDangKy,GhiChu=@GhiChu
			Where MaDocGia=@MaDocGia and TenNXB=@TenNXB and
			MaSach=@MaSach
		else
			Print 'MaSach, TenNXB khong ton tai';
	else
		Print 'MaDocGia khong ton tai';
End
Go
Exec Proc_Sua_DangKy 'e','f','2','2001-7-10',null;
Go
Create Procedure Proc_Xoa_DangKy
@MaSach varchar(10),
@TenNXB varchar(50),
@MaDocGia varchar(10)
AS
Begin
	Delete DangKy
	Where MaSach=@MaSach and TenNXB=@TenNXB and MaDocGia=@MaDocGia
End
Go
Exec Proc_Xoa_DangKy 'e', 'f','2';
Go
--Muon
Create Function Func_Check_KNMaCuon(@MaCuon varchar(20))
returns bit
AS
Begin
	declare @check bit=0
	if Exists (Select MaCuon
	From CuonSach
	Where MaCuon=@MaCuon)
		Set @check =1;
	return @check;
End
Go
Create Procedure Proc_Them_Muon
@MaCuon varchar(20),
@MaDocGia  varchar(10),
@NgayMuon datetime,
@NgayHetHan datetime
--MaKhuVucSach khong them vao
--Vi se lay o bang Cuon Sach qua
AS
Begin
	if(dbo.Func_Check_KNMaCuon(@MaCuon)=1)
		if(dbo.Func_Check_KNMaDocGia(@MaDocGia)=1)
		Begin
			declare @MaKhuVucSach int
			--Phan nay khong can vi da co trigger trigg_muon_sach 
			--de lay ma khu vuc
			--Select @MaKhuVucSach=MaKhuVuc
			--From CuonSach
			--Where MaCuon=@MaCuon
			Insert into Muon(MaCuon,MaDocGia,NgayMuon,NgayHetHan) values(@MaCuon, @MaDocGia,@NgayMuon,@NgayHetHan);
		End
		else
			Print 'MaDocGia khong ton tai';
	else
		Print 'MaCuon khong ton tai';
End
Go
Exec Proc_Them_Muon 'p2','2',null,null;
Go
Create Function Func_Check_MaKhuVucSach(@MaCuon varchar(20),@MaKhuVucSach varchar(10))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select MaCuon
	From CuonSach
	Where MaCuon=@MaCuon and MaKhuVuc=@MaKhuVucSach)
		Set @check=1;
	return @check;
End
Go
Create Procedure Proc_Sua_Muon
@MaCuon varchar(20),
@MaDocGia  varchar(10),
@NgayMuon datetime,
@NgayHetHan datetime
--@MaKhuVucSach varchar(10)
AS
Begin
	--Cho nhap vao va kiem tra xem co khop hay khong
	--if(dbo.Func_Check_MaKhuVucSach(@MaCuon,@MaKhuVucSach)=1)
	--	Update Muon
	--	Set NgayMuon=@NgayMuon, NgayHetHan=@NgayHetHan,
	--	MaKhuVucSach=@MaKhuVucSach
	--	Where MaCuon=@MaCuon and MaDocGia=@MaDocGia
	--else
	--	Print 'MaKhuVucSach khong khop';
	Update Muon
	Set NgayMuon=@NgayMuon, NgayHetHan=@NgayHetHan
	Where MaCuon=@MaCuon and MaDocGia=@MaDocGia
End
Go
Exec Proc_Sua_Muon 'p2','2','2001-2-2',null;
Go
Create Procedure Proc_Xoa_Muon
@MaCuon varchar(20),
@MaDocGia  varchar(10)
AS
Begin
	Delete Muon
	Where MaCuon=@MaCuon and MaDocGia=@MaDocGia
End
Exec Proc_Xoa_Muon 'p2','2';
-------------------------------------------------

-----------------PROC MINH PHUONG------------------
--Doc Gia
Create Procedure Proc_Them_DocGia
@MaDocGia varchar(10),
@HoVaTen varchar(50),
@GioiTinh varchar(50),
@NgaySinh datetime,
@SoDienThoai varchar(15),
@Email varchar(50),
@DiaChi varchar(50),
@HinhAnh Image
AS
Begin
	Insert into DocGia values(@MaDocGia, @HoVaTen,@GioiTinh,@NgaySinh ,@SoDienThoai,@Email ,@DiaChi ,@HinhAnh);
End
Go
exec dbo.Proc_Them_DocGia'1','a','nam',null,'0123','assss','assss',null;
Create Procedure Proc_Sua_DocGia
@MaDocGia varchar(10),
@HoVaTen varchar(50),
@GioiTinh varchar(50),
@NgaySinh datetime,
@SoDienThoai varchar(15),
@Email varchar(50),
@DiaChi varchar(50),
@HinhAnh Image
AS
Begin
	 Update DocGia 
	 Set HoVaTen= @HoVaTen,GioiTinh =@GioiTinh,NgaySinh= @NgaySinh ,SoDienThoai= @SoDienThoai, Email= @Email ,DiaChi= @DiaChi ,HinhAnh= @HinhAnh
	 Where MaDocGia = @MaDocGia
End
Go
exec dbo.Proc_Sua_DocGia '1','ab','nam',null,'0123','assss','assss',null;
create Procedure Proc_Xoa_DocGia
@MaDocGia varchar(10)
AS
Begin
	Delete DangKy
	Where MaDocGia=@MaDocGia
	Delete QuaTrinhMuon
	Where MaDocGia=@MaDocGia
	Delete Muon
	Where MaDocGia=@MaDocGia
	Delete DocGia
	Where MaDocGia = @MaDocGia
End
Go
--Dau Sach
exec dbo.Proc_Xoa_DocGia '1';
Create Procedure Proc_Sua_DauSach
@MaSach varchar(10),
@TenSach varchar(20),
@TenNXB varchar(50),
@TacGia varchar(50),
@SoLuongCuon int,
@QuocGia varchar(50),
@GiaSach int
AS
Begin
	Update DauSach
	Set TenNXB= @TenNXB , TenSach=@TenSach,TacGia=@TacGia ,SoLuongCuon=@SoLuongCuon , QuocGia=@QuocGia ,GiaSach=@GiaSach
	Where MaSach=@MaSach
	

End
Go
exec dbo.Proc_Sua_DauSach 'p','p','a',2,'a',131654;
create Procedure Proc_Them_DauSach
@MaSach varchar(10),
@TenSach varchar(20),
@TenNXB varchar(50),
@TacGia varchar(50),
@SoLuongCuon int,
@QuocGia varchar(50),
@GiaSach int
AS
Begin
	Insert into DauSach values(@MaSach,@TenSach,@TenNXB ,@TacGia ,@SoLuongCuon ,@QuocGia ,@GiaSach );
End
Go

exec dbo.Proc_Them_DauSach 'p','p','a',5,'a',131654;
--Dang lam
Create Procedure Proc_Xoa_DauSach
@MaSach varchar(10),
@TenNXB varchar(50)
AS
Begin
	declare @temptable table(MaCuon varchar(20));
	--Them toan bo MaCuon vao bang temptable
	Insert Into @temptable
	Select MaCuon
	From CuonSach
	Where MaSach=@MaSach and TenNXB=@TenNXB;
	--Tien hanh xoa du lieu ben bang DangKy
	Delete DangKy
	Where MaSach=@MaSach and TenNXB=@TenNXB;
	--Tien hanh xoa cuon sach
	declare @MaCuon varchar(20)='a';
	While(@MaCuon is not null)
	Begin
		Set @MaCuon=null;

		Set @MaCuon = (Select TOP 1 MaCuon
		From @temptable);

		Exec dbo.Proc_Xoa_CuonSach @MaCuon;

		Delete @temptable
		Where MaCuon=@MaCuon;
	End
	Delete DauSach
	Where MaSach=@MaSach
End
Go
Exec Proc_Xoa_DauSach 'a','b';
--Cuon Sach

Create Function Func_Check_DauSach(@MaSach varchar(10))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select MaSach
	From DauSach
	Where MaSach = @MaSach)
		Set @check=1;
	return @check;
End
Go
Create Function Func_Check_KhuVuc(@MaKhuVuc varchar(10))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select MaKhuVuc
	From KhuVucSach
	Where MaKhuVuc = @MaKhuVuc)
		Set @check=1;
	return @check;
End
Go
Create Function Func_Check_NXB(@TenNXB varchar(50))
returns bit
AS
Begin
	declare @check bit=0
	if Exists(Select TenNXB
	From DauSach
	Where TenNXB = @TenNXB)
		Set @check=1;
	return @check;
End
Go

Create Procedure Proc_Sua_CuonSach
@MaCuon varchar(20),
@TienDenBu int,
@ThoiGianMuon int,
@MaKhuVuc varchar(10),
@MaSach varchar(10),
@TenNXB varchar(50)
AS
Begin
if(dbo.Func_Check_NXB(@TenNXB)=1)
		begin
			if (dbo.Func_Check_KhuVuc(@MaKhuVuc)=1)
				begin
					if(dbo.Func_Check_DauSach(@MaSach) =1)
					begin
						Update CuonSach
						Set TienDenBu=@TienDenBu ,ThoiGianMuon=@ThoiGianMuon ,MaKhuVuc=@MaKhuVuc ,MaSach=@MaSach ,TenNXB=@TenNXB
						Where MaCuon = @MaCuon
					end
					else Print 'Ma Sach khong ton tai';
				end
			else Print 'Ma Khu Vuc khong ton tai';
		end
	else
		Print 'NXB khong ton tai ';

End
Go
exec dbo.Proc_Sua_CuonSach'p2',NULL,149,A,'p','p';
CREATE Procedure Proc_Them_CuonSach
@MaCuon varchar(20),
@TienDenBu int,
@ThoiGianMuon int,
@MaKhuVuc varchar(10),
@MaSach varchar(10),
@TenNXB varchar(50)
AS
Begin
	if(dbo.Func_Check_NXB(@TenNXB)=1)
		begin
			if (dbo.Func_Check_KhuVuc(@MaKhuVuc)=1)
				begin
					if(dbo.Func_Check_DauSach(@MaSach) =1)
					begin
						Insert into CuonSach values(@MaCuon,@TienDenBu ,@ThoiGianMuon ,@MaKhuVuc ,@MaSach ,@TenNXB);
					end
					else Print 'Ma Sach khong ton tai';
				end
			else Print 'Ma Khu Vuc khong ton tai';
		end
	else
		Print 'NXB khong ton tai ';
End
Go
exec dbo.Proc_Them_CuonSach 'p2',NULL,145,A,'p','p';
--
Create Procedure Proc_Xoa_CuonSach
@MaCuon varchar(20)
As
Begin
	Delete QuaTrinhMuon
	Where MaCuon=@MaCuon
	Delete Muon
	Where MaCuon=@MaCuon
	Delete CuonSach
	Where MaCuon=@MaCuon

End
Go
exec dbo.Proc_Xoa_CuonSach 'c1';
---------------------------------------------------


-------PHAN QUYEN--------
use QuanLyThuVien
--Tao quyen cho Quanly
CREATE ROLE Quanly
GRANT SELECT, INSERT, DELETE, UPDATE ON ThuThu TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON CuonSach TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON DangKy TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON DauSach TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON DocGia TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON KhuVucSach TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON Muon TO Quanly
GO
GRANT SELECT, INSERT, DELETE, UPDATE ON QuaTrinhMuon TO Quanly
GO
--CAP QUYEN CAC STORE PROCEDURE CHO QUAN LY
GRANT EXEC, ALTER ON Proc_Cho_Muon_sach TO QuanLy
GRANT EXEC, ALTER ON Proc_tra_sach TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_DangKy TO QuanLy
GRANT EXEC, ALTER ON PROC_DANH_SACH_QUA_HAN TO QuanLy
GRANT EXEC, ALTER ON PROC_DANH_SACH_TOI_HAN_TRA TO QuanLy
GRANT EXEC, ALTER ON PROC_DANH_SACH_DA_MUON TO QuanLy
GRANT EXEC, ALTER ON PROC_THU_THU_TRUC TO QuanLy
--
GRANT EXEC, ALTER ON Proc_Them_ThuThu TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_ThuThu TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_ThuThu TO QuanLy
GRANT EXEC, ALTER ON Proc_Them_KhuVucSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_KhuVucSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_KhuVucSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Them_DangKy TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_DangKy TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_DangKy TO QuanLy
GRANT EXEC, ALTER ON Proc_Them_Muon TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_Muon TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_Muon TO QuanLy
--
GRANT EXEC, ALTER ON Proc_Them_DocGia TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_DocGia TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_DocGia TO QuanLy
GRANT EXEC, ALTER ON Proc_Them_DauSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_DauSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Sua_CuonSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Them_CuonSach TO QuanLy
GRANT EXEC, ALTER ON Proc_Xoa_CuonSach TO QuanLy
--
--CAP QUYEN CAC FUNCTION CHO QUAN LY
GRANT SELECT, ALTER ON Func_tinh_tien_den TO QuanLy	

GRANT SELECT, ALTER ON Func_DangKy_BangSTTDangKy TO QuanLy
GRANT SELECT, ALTER ON Func_Check_KNIDTT TO QuanLy
GRANT SELECT, ALTER ON Func_Check_KNMaDocGia TO QuanLy
GRANT SELECT, ALTER ON Func_Check_MaKhuVucSach TO QuanLy
GRANT SELECT, ALTER ON Func_Check_KNMaSachTenNXB TO QuanLy
GRANT SELECT, ALTER ON Func_Check_KNMaCuon TO QuanLy
GRANT SELECT, ALTER ON Func_Check_DauSach TO QuanLy
GRANT SELECT, ALTER ON Func_Check_KhuVuc TO QuanLy
GRANT SELECT, ALTER ON Func_Check_NXB TO QuanLy

