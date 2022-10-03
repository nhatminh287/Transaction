--Cau 1
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
create proc ThemTaiKhoan @matk char(10), @ngaylap date, @sodu int, @trangthai bit, @loaitk char(10), @makh char(10)
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
				set @trangthai = 1	
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
DROP PROCEDURE CapNhatThongTin;
GO
create proc CapNhatThongTin @matk char(10), @ngaylap date, @sodu int, @trangthai bit
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

-- Cau 4
CREATE PROC p_XoaTaiKhoan
	@matk char(10),
	@kq int output
AS
BEGIN TRANSACTION
	BEGIN TRY
	--Kiem tra ton tai tai khoan
		IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE MATK = @matk)
			BEGIN
				PRINT '@matk + không tồn tại'
				ROLLBACK TRANSACTION
				RETURN 
			END
		ELSE
		-- Kiem tra tai khoan da thua hien giao dich chua
			BEGIN
				IF EXISTS (SELECT * FROM GiaoDich WHERE MATK = @matk)
					BEGIN
						PRINT 'Tài khoản + @matk + đã thực hiện giao dịch, không thể xóa'
						ROLLBACK TRANSACTION
						RETURN
					END
				ELSE
				-- Xoa tai khoan
					BEGIN
						DELETE FROM TaiKhoan
						WHERE MATK = @matK
					END
			END
	END TRY
	--Xu ly loi
	BEGIN CATCH
		PRINT ' Xóa tài khoản + @matk + không thành công'
		SET @kq = 1
		ROLLBACK TRANSACTION
	END CATCH
	--Xoa tai khoan thanh cong
	PRINT 'Xóa tài khoản + @matk + thành công'
	SET @kq = 0
COMMIT TRANSACTION
GO

