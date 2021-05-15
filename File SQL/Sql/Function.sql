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

Create FUNCTION Func_DangKy_BangSTTDangKy(@MASACH VARCHAR(10),@TENNXB VARCHAR(50),@MADOCGIA varchar(10))
RETURNS INT
AS
Begin
	Declare @Stt int
	Select @Stt=STT
	From(
	Select ROW_NUMBER() OVER (PARTITION BY MaSach,TenNXB Order by MaSach,TenNXB,NgayDangKy) as STT,
	MaSach,TenNXB,MaDocGia,NgayDangKy,GhiChu
	From DangKy) as KQ
	Where MaSach=@MASACH and TenNXB=@TENNXB and MaDocGia=@MADOCGIA
	Return @Stt;
End

CREATE FUNCTION Func_tinh_tien_den (@MA_CUON VARCHAR(20), @Ngay_Het_Han DATETIME, @NGAY_TRA DATETIME , @TINH_TRANG VARCHAR(50))
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

