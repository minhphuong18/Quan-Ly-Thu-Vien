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


Create Procedure Proc_Xoa_DocGia
@MaDocGia varchar(10)
AS
Begin


	Delete Muon
	Where MaDocGia=@MaDocGia
	Delete DocGia
	Where MaDocGia = @MaDocGia
End
Go

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

Create Procedure Proc_Xoa_DauSach
@MaSach varchar(10),
@TenNXB varchar(50)
AS
Begin
	declare @temptable table(MaCuon varchar(20));
	
	Insert Into @temptable
	Select MaCuon
	From CuonSach
	Where MaSach=@MaSach and TenNXB=@TenNXB;
	
	Delete DangKy
	Where MaSach=@MaSach and TenNXB=@TenNXB;
	
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


Create Procedure Proc_Them_CuonSach
@MaCuon varchar(20),
@TienDenBu int,
@ThoiGianMuon int,
@MaKhuVuc varchar(10),
@MaSach varchar(10),
@TenNXB varchar(50)
AS
Begin
	if(dbo.Func_Check_NXB(@TenNXB)=1 And dbo.Func_Check_KhuVuc(@MaKhuVuc)=1 And dbo.Func_Check_DauSach(@MaSach) =1) 
		Insert into CuonSach values(@MaCuon,@TienDenBu ,@ThoiGianMuon ,@MaKhuVuc ,@MaSach ,@TenNXB);
	else
		Print 'Khong them duoc';
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
	if(dbo.Func_Check_NXB(@TenNXB)=1 And dbo.Func_Check_KhuVuc(@MaKhuVuc)=1 And dbo.Func_Check_DauSach(@MaSach) =1) 
		begin
			Update CuonSach
			Set ThoiGianMuon=@TienDenBu ,ThoiGianMuon=@ThoiGianMuon ,MaKhuVuc=@MaKhuVuc ,MaSach=@MaSach ,TenNXB=@TenNXB
			Where MaCuon = @MaCuon
		end
	else
		Print 'Khong sua duoc';
End
Go

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
CREATE PROCEDURE PROC_THU_THU_TRUC @MAKHUVUC VARCHAR(10)
AS 
BEGIN
	SELECT ThuThu.ID, THUTHU.HoVaTen, ThuThu.GioiTinh, ThuThu.SoDienThoai, ThuThu.DiaChiNha
	FROM KhuVucSach, THUTHU
	WHERE KhuVucSach.MaKhuVuc = @MAKHUVUC AND ThuThu.ID = KhuVucSach.IDTT
END


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

	Create Procedure Proc_Them_Muon
@MaCuon varchar(20),
@MaDocGia  varchar(10),
@NgayMuon datetime,
@NgayHetHan datetime
AS
Begin
	if(dbo.Func_Check_KNMaCuon(@MaCuon)=1)
		if(dbo.Func_Check_KNMaDocGia(@MaDocGia)=1)
		Begin
			declare @MaKhuVucSach int
		
			Insert into Muon(MaCuon,MaDocGia,NgayMuon,NgayHetHan) values(@MaCuon, @MaDocGia,@NgayMuon,@NgayHetHan);
		End
		else
			Print 'MaDocGia khong ton tai';
	else
		Print 'MaCuon khong ton tai';
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
	
	Update Muon
	Set NgayMuon=@NgayMuon, NgayHetHan=@NgayHetHan
	Where MaCuon=@MaCuon and MaDocGia=@MaDocGia
End
Go

Create Procedure Proc_Xoa_Muon
@MaCuon varchar(20),
@MaDocGia  varchar(10)
AS
Begin
	Delete Muon
	Where MaCuon=@MaCuon and MaDocGia=@MaDocGia
End

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


CREATE PROCEDURE PROC_DANH_SACH_QUA_HAN
AS 
BEGIN
	SELECT *
	FROM Muon
	WHERE DATEDIFF(DAY,MUON.NgayHetHan, GETDATE()) > 0
END

CREATE PROCEDURE PROC_DANH_SACH_TOI_HAN_TRA
AS
BEGIN
	SELECT *
	FROM Muon
	WHERE DATEDIFF(DAY,MUON.NgayHetHan, GETDATE()) = 0
END



CREATE PROCEDURE PROC_DANH_SACH_DA_MUON @MASACH VARCHAR(10)
AS
BEGIN
	SELECT MUON.MaCuon, NgayMuon, NgayHetHan
	FROM MUON, CuonSach
	WHERE MUON.MaCuon = CuonSach.MaCuon AND CuonSach.MaSach = @MASACH
END



CREATE PROCEDURE PROC_SO_SACH_MUON
AS 
BEGIN
	SELECT DocGia.MaDocGia, DocGia.HoVaTen, COUNT(MaCuon) AS SO_LUON_SACH_DA_MUON
	FROM Muon, DocGia
	WHERE Muon.MaDocGia = DocGia.MaDocGia
	GROUP BY DocGia.MaDocGia, HoVaTen
END

CREATE PROCEDURE PROC_DANH_SACH_DA_TRA
AS 
BEGIN
	SELECT MACUON, MaKhuVucSach, TinhTrang
	FROM QuaTrinhMuon
	WHERE QuaTrinhMuon.NgayTra = GETDATE()
END

CREATE PROCEDURE PROC_SO_SACH_DA_MUON
AS 
BEGIN
	SELECT CuonSacH.MaSach,DauSach.TENSACH, COUNT(MUON.MaCuon) AS SO_LUON_SACH_DA_MUON
	FROM CuonSach, MUON, DauSach
	WHERE CuonSach.MaCuon = MUON.MaCuon AND DauSach.MaSach = CuonSach.MaSach
	GROUP BY CuonSach.MaSach, DauSach.TENSACH
END

