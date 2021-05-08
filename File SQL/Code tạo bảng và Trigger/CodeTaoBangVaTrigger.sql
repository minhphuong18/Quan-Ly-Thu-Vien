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

--Khi cap nhap Tinh_Trang, Ngay_Muon, Ngay_Tra thi se tu tinh Tien den
CREATE TRIGGER trigg_sua_trang_thai 
ON QUATRINHMUON
AFTER UPDATE 
AS
BEGIN
	DECLARE @TINH_TRANG VARCHAR(50), @MA_CUON varchar(20) , @Ngay_Het_Han DATETIME, @NGAY_TRA DATETIME

	SELECT @TINH_TRANG = inserted.TinhTrang, @Ngay_Het_Han = inserted.NgayHetHan, @NGAY_TRA = inserted.NgayTra, @MA_CUON = inserted.MaCuon
	FROM inserted

	UPDATE QuaTrinhMuon
	SET TienDen = DBO.Func_tinh_tien_den(@MA_CUON, @NGAY_MUON, @NGAY_TRA, @TINH_TRANG)

END
Go

--Function tra ve so tien phai den
CREATE FUNCTION Func_tinh_tien_den (@MA_CUON INT, @Ngay_Het_Han DATETIME, @NGAY_TRA DATETIME , @TINH_TRANG VARCHAR(50))
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
	DECLARE @MACUON VARCHAR(10)
	
	--Lay MaCuon duoc them vao/chinh sua
	SELECT @MACUON=MaCuon
	From inserted

	--Kiem tra xem cuon sach da duoc muon chua
	IF (NOT EXISTS ( SELECT *
			   FROM CuonSach
			   WHERE MaCuon=@MACUON AND MaKhuVuc IS NOT NULL))
	BEGIN
		PRINT 'Cuon sach nay da duoc muon roi. Vui long kiem tra lai MaCuon';
		Rollback Tran;
	END
END;

--Trigger kiem tra xem DocGia co duoc muon cuon sach khong
CREATE TRIGGER trigg_MUON_CheckDangKy
ON MUON
AFTER INSERT,UPDATE
AS
BEGIN
	DECLARE @MASACH VARCHAR(10),@TENNXB VARCHAR(50),@SLSACHMUON INT,@SLSACHDANGKY INT,@TONGSL INT,@SLMAX INT

	--Lay ra Masach cua CuonSach duocmuon
	SELECT @MASACH=MaSach,@TENNXB=CuonSach.TenNXB
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
			ROLLBACK TRAN;
		ELSE
		BEGIN
			--Xet xem DocGia co so thu tu dang ky muon sach la bao nhieu?
			-- -->Co duoc muon hay khong?
			--Nguoi ko dang ky truoc --> khong duoc muon
			DECLARE @STT INT, @MADOCGIA varchar(10)

			SELECT @MADOCGIA=inserted.MaDocGia
			FROM inserted;

			IF(Not Exists(SELECT * 
						  FROM DangKy
						  Where MaSach=@MASACH and TenNXB=@TENNXB and MaDocGia=@MADOCGIA))
			BEGIN
				PRINT 'Toan bo sach da duoc muon va dang ky.';
				Rollback Tran;
			END
			ELSE
				BEGIN
					--Lay stt dang ky
					Select @STT=dbo.Func_DangKy_BangSTTDangKy(@MASACH,@TENNXB,@MADOCGIA)
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
						EXEC dbo.Proc_Xoa_DangKy @MASACH,@TENNXB,@MADOCGIA
					END
				END
		END
	END
END;

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
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('VHVN','Kim Dong','Nguyen Minh Dang',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('VHNN','Hoi Nha Van','Doan Duc Hieu',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('THVN','Giao Duc','Nguyen Duc Tri',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('THNN','Giao Duc','Nguyen Duc Tri',1,'Nga',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHQS','Khoa hoc tu nhien va Cong nghe','Le Quoc Vinh',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHTG','Khoa hoc tu nhien va Cong nghe','Nelson Mandela',1,'My',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KHVN','Khoa hoc va Ky thuat','Le Quoc Vinh',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHTH','Y hoc','Jonh Smith ',1,'Cuba',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHCM','Y hoc','Truong Minh Phuong',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('YHCT','Y hoc','Truong Minh Phuong',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('DSTT','Dai hoc Quoc Gia thanh pho Ho Chi Minh','Hong Ha',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN1','Dai hoc Su pham','Nguyen Van Toan',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN2','Dai hoc Su pham','Nguyen Van Toan',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TOAN3','Dai hoc Su pham','Nguyen Van Toan',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KINHTEDC1','Tri thuc','Do Thanh Nga',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KINHTEDC2','Tri thuc','Do Thanh Nga',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('NMLT','Khoa hoc tu nhien va Cong nghe','Tran Cong Tu',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('KTLT','Khoa hoc va Ky thuat','Tran Cong Tu',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TTLDCN','Kim Dong','Gosho Aoyama',1,'Nhat Ban',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('DL','Van hoa - Thong tin','Tu hoc IT',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('MCL','Van hoa - Thong tin','Tu hoc IT',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TTHCM','Chinh tri Quoc Gia','Phan Dong',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('PLDC','Chinh tri Quoc Gia','Phan Dong',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('HP2013','Su That','Chinh Tri gia',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('HP1992','Su That','Chinh Tri gia',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('CTVN','Tuoi Tre','Cu Trong Xoay',1,'Viet Nam',50000)
insert into DauSach(MaSach, TenNXB, TacGia, SoLuongCuon, QuocGia, GiaSach) values('TG','Tuoi Tre','Cu Trong Xoay',1,'Viet Nam',50000)

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
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHQS01', 'DG002','01-10-2021', '02-28-2021','B5' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHTG01', 'DG002','01-10-2021', '02-28-2021','B2' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKKHVN01', 'DG003','04-15-2021', '05-15-2021','B5' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHTH01', 'DG003','04-15-2021', '05-15-2021','B4' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHCM01', 'DG004','04-15-2021', '05-30-2021','B4' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKYHCT01', 'DG005','02-01-2020', '02-28-2020','B4' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTDSTT01', 'DG006','02-01-2021', '02-28-2021','B6' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('GTDSTT01', 'DG007','04-15-2021', '04-30-2021','B6' )
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
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTHCM01', 'DG011','04-30-2021', '05-31-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKPLDC01', 'DG011','04-30-2021', '05-31-2021','B3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201301', 'DG012','07-15-2022', '08-15-2022','A3' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG012','07-15-2022', '08-15-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG013','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG014','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG015','04-15-2022', '04-30-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHVN02', 'DG015','04-15-2022', '04-30-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHNN02', 'DG015','04-15-2022', '04-30-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTHVN02', 'DG015','04-15-2022', '04-30-2022','A1' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTG02', 'DG016','01-01-2021', '01-01-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKCTVN02', 'DG016','01-01-2021', '01-01-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199202', 'DG016','01-01-2021', '01-01-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201302', 'DG016','01-01-2021', '01-01-2022','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTHCM02', 'DG016','01-01-2021', '01-01-2022','A3' )

INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201301', 'DG001','03-20-2021', '04-15-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG001','03-20-2021', '04-15-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG002','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199201', 'DG004','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHVN02', 'DG004','03-30-2021', '06-01-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKVHNN02', 'DG005','04-15-2021', '04-30-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTHVN02', 'DG006','03-30-2021', '06-01-2021','A1' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTG02', 'DG008','01-10-2021', '02-10-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKCTVN02', 'DG008','01-10-2021', '02-10-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP199202', 'DG008','01-10-2021', '02-10-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKHP201302', 'DG008','01-10-2021', '02-10-2021','A3' )
INSERT INTO Muon(MaCuon, MaDocGia, NgayMuon, NgayHetHan, MaKhuVucSach) values('TKTTHCM02', 'DG009','01-10-2021', '02-10-2021','A3' )
------QUA TRINH MUON-------
