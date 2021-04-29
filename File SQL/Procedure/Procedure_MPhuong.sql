Use QuanLyThuVien
Go
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
@TenNXB varchar(50),
@TacGia varchar(50),
@SoLuongCuon int,
@QuocGia varchar(50),
@GiaSach int
AS
Begin
	Update DauSach
	Set TenNXB= @TenNXB ,TacGia=@TacGia ,SoLuongCuon=@SoLuongCuon , QuocGia=@QuocGia ,GiaSach=@GiaSach
	Where MaSach=@MaSach
	

End
Go
exec dbo.Proc_Sua_DauSach 'p','p','a',2,'a',131654;
Create Procedure Proc_Them_DauSach
@MaSach varchar(10),
@TenNXB varchar(50),
@TacGia varchar(50),
@SoLuongCuon int,
@QuocGia varchar(50),
@GiaSach int
AS
Begin
	Insert into DauSach values(@MaSach,@TenNXB ,@TacGia ,@SoLuongCuon ,@QuocGia ,@GiaSach );
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
alter Procedure Proc_Them_CuonSach
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

