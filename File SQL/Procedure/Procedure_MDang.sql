Use QuanLyThuVien
Go
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
