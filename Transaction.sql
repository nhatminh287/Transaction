--Cau 1
-- 19120585 - Nguyễn Hải Nhật Minh
CREATE PROC Xemsodu
	@matk char(10)
AS
BEGIN TRANSACTION
	begin try
	--Kiem tra ton tai tai khoan
		IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE MaTK = @matk)
			BEGIN
				PRINT @matk + N'không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
			begin 
				if exists (select * from TaiKhoan where MaTK = @matk and TrangThai = N'Đã khóa')
					begin
						Print N'Tài khoản đã bị khóa'
						ROLLBACK TRANSACTION
						return
					end
				if exists (select * from TaiKhoan where MaTK = @matk and TrangThai != N'Đã khóa')
					begin
						declare @sodu int
						set @sodu = (select tk.SoDu from TaiKhoan tk where tk.MaTK = @matk and tk.TrangThai != N'Đã khóa')
						print 'Số dư của tài khoản là: ' + CAST(@sodu AS VARCHAR)
						commit
					end
			end
		end try
		begin catch
			print N'Đã xảy ra lỗi!'
			rollback transaction
			return 
		end catch
go

--Cau 2
-- 19120565 - Nguyễn Văn Lợi
create proc ThemTaiKhoan @matk char(10), @ngaylap date, @sodu int, @trangthai nvarchar, @loaitk char(10), @makh char(10)
as
	begin transaction
		begin try
			--Kiem tra su ton tai tai khoan
			if @matk in (select TaiKhoan.MaTK from TaiKhoan)
			begin
				print @matk + N'đã tồn tại'
				rollback transaction
				return 1
			end

			--Kiem tra so du dua vao
			if @sodu >= 100000
			begin
				print N'Số dư không hợp lệ!'
				rollback transaction
				return 1
			end

			--Kiem tra trang thai tai khoan
			if @trangthai is null
			begin
				set @trangthai = N'Đang dùng'	
			end

			--Kiem tra loai tai khoan
			if @loaitk not in (select LoaiTaiKhoan.MaLoai from LoaiTaiKhoan)
			begin
				print N'Loại tài khoản ' + @loaitk + N' không tồn tại!'
				rollback transaction
				return 1
			end

			--Kiem tra ma khach hang
			if @makh not in (select KhachHang.MaKH from KhachHang)
			begin
				print N'Mã khách hàng ' + @makh + N' không tồn tại!'
				rollback transaction
				return 1
			end

			--Them tai khoan moi
			insert into TaiKhoan(MaTK, NgayLap, SoDu, TrangThai, LoaiTK, MaKH) 
				values(@matk, @ngaylap, @sodu, @trangthai, @loaitk, @makh);

			print N'Thêm thành công!'
			commit transaction
			return 0
		end try
		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return 1
		end catch
go

--Cau 3
-- Lê Hoàng Chương - 18600033
DROP PROCEDURE CapNhatThongTin;
GO
create proc CapNhatThongTin @matk char(10), @ngaylap date, @sodu int, @trangthai nvarchar
as
	begin transaction
		begin try
		--kiem tra MTK ton tai hay ko
		if @matk != (select TaiKhoan.MaTK from TaiKhoan)
		begin
				print @matk + N'đã tồn tại'
				rollback transaction
				return 1
		end

		--kiem tra ngay lap khac null
		if @ngaylap = null
		begin
				print N'Ngay lap khong hop le'
				rollback transaction
				return 1
		end

		--kiem tra so du lon hon 100000
			if @sodu >= 100000
			begin
				print N'Số dư không hợp lệ!'
				rollback transaction
				return 1
			end

		--kiem tra trang thai
			if @trangthai != (select TaiKhoan.TrangThai from TaiKhoan)
			begin
				print 'trang thai kghong hop le'
				return 1
			end

			--update 
			UPDATE TaiKhoan
			SET NgayLap = @ngaylap, SoDu = @sodu,TrangThai = @trangthai
			WHERE MaTK =  @matk;
		print N'cap nhat thanh cong!'
			commit transaction
			return 0
		end try

		begin catch
			print N'Lỗi hệ thống!'
			rollback transaction
			return 1
		end catch
go

-- Cau 4 Xóa tài khoản
-- 20120289 - Võ Minh Hiếu
CREATE
--ALTER
PROC p_XoaTaiKhoan
	@matk char(10)
AS
BEGIN TRANSACTION
	BEGIN TRY
	--Kiem tra ton tai tai khoan
		IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE MaTK = @matk)
			BEGIN
				PRINT @matk + N'không tồn tại.'
				ROLLBACK TRANSACTION
				RETURN 1
			END
		ELSE
		-- Kiem tra tai khoan da thua hien giao dich chua
			BEGIN
				IF EXISTS (SELECT * FROM GiaoDich WHERE MaTK = @matk)
					BEGIN
						PRINT  @matk + N'đã thực hiện giao dịch, không thể xóa'
						ROLLBACK TRANSACTION
						RETURN 1
					END
				ELSE
				-- Xoa tai khoan
					BEGIN
						DELETE FROM TaiKhoan
						WHERE MaTK = @matK
					END
			END
	END TRY
	--Xu ly loi
	BEGIN CATCH
		PRINT N'Xóa tài khoản không thành công'
		ROLLBACK TRANSACTION
	END CATCH
	--Xoa tai khoan thanh cong
	PRINT N'Xóa tài khoản thành công'
	RETURN 0
COMMIT TRANSACTION
GO

--Phần BTVN


--Bài 2
-- 19120585-Nguyễn Hải Nhật Minh (câu 2.1 -> 2.3)
--2.1.Thêm nguoi thân
create proc ThemNguoiThan
@maGV char(5), @ten nvarchar(20),
@ngSinh datetime, @phai nchar(3)
as
begin transaction
begin try
	if not exists (select * from GIAOVIEN gv 
			where gv.MAGV = @maGV)
		begin
			print 'Lỗi mã giáo viên!'
			rollback transaction
		end
	else
		begin
			insert into NGUOITHAN values(@maGV, @ten, @ngSinh, @phai)
			
		end
end try
begin catch
	print 'Đã xảy ra lỗi'
	rollback transaction
end catch
print 'Thêm thành công'
commit
go

--2.2.Thêm giáo viên
create proc ThemGiaoVien
@maGV char(5), @hoten nvarchar(40), @luong float, @phai nchar(3),
@ngSinh datetime, @diachi nvarchar(100), @gvqlcm char(5),
@mabm nchar(5)
as
begin transaction
begin try
	--Kiểm tra ràng buộc khóa ngoại với GVQLCM
	if not exists (select * from GIAOVIEN gv 
			where gv.MAGV =  @gvqlcm)
		begin
			print 'GVQLCM không hợp lệ!'
			rollback transaction
			return
		end
	--Kiểm tra ràng buộc khóa ngoại với MABM
	if not exists (select * from BOMON bm
			where bm.MABM = @mabm)
		begin
			print 'MABM không hợp lệ!'
			rollback transaction
			return
		end
	--Thêm mới giá trị vào bảng GIAOVIEN
	insert into GIAOVIEN values(@maGV, @hoten , @luong , @phai ,@ngSinh, @diachi , @gvqlcm ,@mabm )
	
end try
begin catch
	print 'Đã xảy ra lỗi'
	rollback transaction
end catch
print 'Thêm thành công'
commit
go
--2.3.Cập nhật trưởng bộ môn
create proc Update_TruongBM
@mabm nchar(5), @truongBM char(5)
as
begin transaction
begin try
	--Kiểm tra @mabm có tồn tại
	if not exists(select * from BOMON bm 
			where bm.mabm = @mabm)
		begin
			print 'MABM không tồn tại!'
			rollback transaction
			return
		end
	--Kiểm tra TRUONGBM cập nhật có hợp lệ?
	if not exists(select * from GIAOVIEN gv
			where gv.MAGV = @truongBM)
		begin
			print 'TRUONGBM không hợp lệ!'
			rollback transaction
			return
		end
	update BOMON 
	set TRUONGBM = @truongBM
	WHERE MABM = @mabm
end try
begin catch
	print 'Đã xảy ra lỗi'
	rollback transaction
end catch
print 'Cập nhật thành công!'
commit
go
