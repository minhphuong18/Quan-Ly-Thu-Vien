CREATE TRIGGER trigg_MUON_CheckDangKy
ON MUON
AFTER UPDATE
AS
BEGIN
	DECLARE @MASACH VARCHAR(10),@TENNXB VARCHAR(50),@SLSACHMUON INT,@SLSACHDANGKY INT,@TONGSL INT,@SLMAX INT

	SELECT @MASACH=MaSach,@TENNXB=TenNXB
	FROM inserted, CuonSach
	Where inserted.MaCuon=CuonSach.MaCuon;

	SELECT @SLMAX=SoLuongCuon
	FROM DauSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB;

	SELECT @SLSACHMUON=COUNT(*)
	FROM MUON M,CuonSach CS
	WHERE M.MaCuon=CS.MaCuon AND CS.MaSach=@MASACH AND CS.TenNXB=@TENNXB

	Set @SLSACHMUON-=1;

	SELECT @SLSACHDANGKY=COUNT(*)
	FROM DangKy
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB

	Set @TONGSL=@SLSACHMUON+@SLSACHDANGKY
	
	IF(@TONGSL>=@SLMAX)
	BEGIN
		
		IF(@SLSACHMUON>=@SLMAX)
		BEGIN
			PRINT 'Toan bo sach da duoc muon';
			ROLLBACK;
		END
		ELSE
		BEGIN
			
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
					
					SET @STT=dbo.Func_DangKy_BangSTTDangKy(@MASACH,@TENNXB,@MADOCGIA)
					
					IF(@STT+@SLSACHMUON > @SLMAX)
					BEGIN
						PRINT 'Hien tai chua toi luot muon sach cua ban. Vui long quay lai sau';
						Rollback Tran;
					END
					ELSE
					
					BEGIN
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
Create TRIGGER trigg_Muon_CheckMaCuon
ON MUON
AFTER INSERT,UPDATE
AS
BEGIN
	DECLARE @MACUON VARCHAR(10),@SL int
	
	SELECT @MACUON=MaCuon
	From inserted

	SELECT @SL=count(*)
	FROM Muon
	WHERE MaCuon=@MACUON

	IF ( @SL>=2)
	BEGIN
		PRINT 'Cuon sach nay da duoc muon roi. Vui long kiem tra lai MaCuon';
		Rollback Tran;
	END
END;
CREATE TRIGGER trigg_Muon_ngay_muon
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

Create TRIGGER trigg_Muon_Thoi_Gian_Muon
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

	IF (DATEDIFF (DAY,@NGAY_MUON, @NGAY_HET_HAN) < @THOI_GIAN_MUON)
		ROLLBACK TRAN;
END
Go

CREATE TRIGGER trigg_muon_sach
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


CREATE TRIGGER trigg_tra_sach
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
CREATE TRIGGER trigg_CuonSach_SLSach
ON CuonSach
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @MASACH VARCHAR(10),@TENNXB VARCHAR(50),@SLSACHTOIDA INT,@SLSACHHIENTAI INT
	
	SELECT @MASACH=inserted.MaSach,@TENNXB=inserted.TenNXB
	FROM inserted;
	
	SELECT @SLSACHTOIDA=SoLuongCuon
	FROM DauSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB;

	SELECT @SLSACHHIENTAI=COUNT(*)
	FROM CuonSach
	WHERE MaSach=@MASACH AND TenNXB=@TENNXB

	IF(@SLSACHHIENTAI>@SLSACHTOIDA)
	BEGIN
		PRINT 'So luong cuon sach da vuot qua so luong sach hien co';
		Rollback Tran;
	END
END
