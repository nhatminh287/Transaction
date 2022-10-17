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
--Võ Minh Hiếu
-- 20120289
--Bài 1
--1. Thêm công việc
CREATE 
--ALTER
PROC USP_THEMCONGVIEC
	@madt char(3),
	@sott int,
	@tencv nvarchar(40),
	@ngaybd datetime,
	@ngaykt datetime
AS
BEGIN TRAN
	BEGIN TRY
		IF @madt = NULL OR @sott = NULL OR @tencv = NULL OR @ngaybd = NULL OR @ngaykt = NULL
			BEGIN
				PRINT N'Thông tin nhập vào không được chứa giá trị rỗng'
				ROLLBACK TRAN
				RETURN 1
			END
	
		IF EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @madt AND SOTT = @sott)
			BEGIN
				PRINT @madt +' + ' + CAST (@sott AS varchar) + N' đã tồn tại công việc'
				ROLLBACK TRAN
				RETURN 1
			END

		IF EXISTS (SELECT * FROM CONGVIEC WHERE TENCV = @tencv )
			BEGIN
				PRINT @tencv + N'Đã tồn tại'
				ROLLBACK TRAN
				RETURN 1
			END
		 
		 IF EXISTS (SELECT * FROM DETAI DT WHERE DT.NGAYBD > @ngaybd OR @ngaybd > DT.NGAYKT)
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải sau ngày bắt đầu đề tài và trước ngày kết thúc đề tài'
				ROLLBACK TRAN
				RETURN 1
			END

		IF @ngaybd > @ngaykt
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải trước ngày kết thúc công việc'
				ROLLBACK TRAN
				RETURN 1
			END

		INSERT INTO CONGVIEC
		VALUES (@madt, @sott, @tencv, @ngaybd, @ngaykt)
	END TRY

	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO

--2. Cập nhật công việc
CREATE 
--ALTER
PROC USP_CAPNHATCONGVIEC
	@madt char(3),
	@sott int,
	@tencv nvarchar(40),
	@ngaybd datetime,
	@ngaykt datetime
AS
BEGIN TRAN
	BEGIN TRY
		IF @madt = NULL OR @sott = NULL OR @tencv = NULL OR @ngaybd = NULL OR @ngaykt = NULL
			BEGIN
				PRINT N'Thông tin nhập vào không được chứa giá trị rỗng'
				ROLLBACK TRAN
				RETURN 1
			END
	
		IF NOT EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @madt AND SOTT = @sott)
			BEGIN
				PRINT @madt +' + ' + CAST (@sott AS varchar) + N' không tồn tại công việc'
				ROLLBACK TRAN
				RETURN 1
			END

		IF EXISTS (SELECT * FROM CONGVIEC WHERE TENCV = @tencv AND  MADT = @madt AND SOTT = @sott AND @ngaybd = NGAYBD AND @ngaykt = NGAYKT)
			BEGIN
				PRINT N'Thông tin ngoài khóa phải có sự thay đổi so với thông tin ban đầu'
				ROLLBACK TRAN
				RETURN 1
			END
		 
		 IF EXISTS (SELECT * FROM DETAI DT WHERE DT.NGAYBD > @ngaybd OR @ngaybd > DT.NGAYKT)
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải sau ngày bắt đầu đề tài và trước ngày kết thúc đề tài'
				ROLLBACK TRAN
				RETURN 1
			END

		IF @ngaybd > @ngaykt
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải trước ngày kết thúc công việc'
				ROLLBACK TRAN
				RETURN 1
			END

		UPDATE CONGVIEC
		SET TENCV = @tencv, NGAYBD = @ngaybd, NGAYKT = @ngaykt
		WHERE MADT = @madt AND SOTT = @sott
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO


--3. Xóa công việc
CREATE 
--ALTER
PROC USP_XOACONGVIEC
	@madt char(3),
	@stt int
AS
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM CONGVIEC WHERE MADT = @madt AND SOTT = @stt)
			BEGIN
				PRINT @madt +' + ' + CAST (@stt AS varchar) + N' không tồn tại công việc'
				ROLLBACK TRAN
				RETURN 1
			END
		IF EXISTS (SELECT * FROM THAMGIADT WHERE MADT = @madt AND STT = @stt)
			BEGIN
				PRINT N'Công việc đã được phân công'
				ROLLBACK TRAN
				RETURN 1
			END

		DELETE FROM CONGVIEC
		WHERE MADT = @madt AND SOTT = @stt

		DELETE FROM DETAI
		WHERE MADT NOT IN (SELECT MADT FROM CONGVIEC)
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO

--4. Thêm đề tài
CREATE
--ALTER
PROC USP_THEMDETAI
	@madt char(3),
	@tendt nvarchar(100),
	@capql nvarchar(40),
	@kp float,
	@ngaybd datetime,
	@ngaykt datetime,
	@macd nchar(4),
	@gvcndt char(5)
AS
BEGIN TRAN
	BEGIN TRY
		IF @madt = NULL OR @tendt = NULL OR @capql = NULL OR @kp = NULL OR @ngaybd = NULL OR @ngaykt = NULL OR @macd = NULL OR @gvcndt = NULL
			BEGIN
				PRINT N'Thông tin nhập vào không được chứa giá trị rỗng'
				ROLLBACK TRAN
				RETURN 1
			END

		IF NOT EXISTS (SELECT * FROM CHUDE WHERE MACD = @macd)
			BEGIN
				PRINT @madt + N' không tồn tại mã chủ đề'
				ROLLBACK TRAN
				RETURN 1
			END
		IF NOT EXISTS (SELECT * FROM GIAOVIEN WHERE MAGV = @gvcndt)
			BEGIN
				PRINT @gvcndt + N' không tồn tại mã giáo viên'
				ROLLBACK TRAN
				RETURN 1
			END
		IF @ngaybd > @ngaykt
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải trước ngày kết thúc công việc'
				ROLLBACK TRAN
				RETURN 1
			END
		IF EXISTS (SELECT * FROM DETAI WHERE MADT = @madt)
			BEGIN
				PRINT @madt + N' đã tồn tại mã đề tài'
				ROLLBACK TRAN
				RETURN 1
			END
		IF EXISTS (SELECT * FROM DETAI WHERE TENDT = @tendt)
			BEGIN
				PRINT @tendt + N' đã tồn tại tên đề tài'
				ROLLBACK TRAN
				RETURN 1
			END
		IF NOT EXISTS (SELECT * FROM BOMON BM, KHOA K WHERE BM.TRUONGBM = @gvcndt OR K.TRUONGKHOA = @gvcndt)
			BEGIN
				PRINT N'GVCNDT phải là trưởng bộ môn hoặc trưởng khoa'
				ROLLBACK TRAN
				RETURN 1
			END
		IF  @capql = N'ĐHQG' AND @kp < (SELECT KINHPHI FROM DETAI WHERE CAPQL = N'Trường')
			BEGIN
				PRINT N'Cấp quản lý ĐHQG phải có kinh phí cao hơn cấp trường'
				ROLLBACK TRAN
				RETURN 1
			END
		IF  @capql = N'Nhà nước' AND @kp < (SELECT KINHPHI FROM DETAI WHERE CAPQL = N'Trường' OR CAPQL = N'ĐHQG')
			BEGIN
				PRINT N'Cấp quản lý Nhà nước phải có kinh phí cao hơn cấp trường hoặc cấp ĐHQG'
				ROLLBACK TRAN
				RETURN 1
			END
		INSERT INTO DETAI
		VALUES (@madt, @tendt, @capql, @kp, @ngaybd, @ngaykt, @macd, @gvcndt)
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO

--5.Cập nhật đề tài
CREATE
--ALTER
PROC USP_CAPNHATDETAI
	@madt char(3),
	@tendt nvarchar(100),
	@capql nvarchar(40),
	@kp float,
	@ngaybd datetime,
	@ngaykt datetime,
	@macd nchar(4),
	@gvcndt char(5)
AS
BEGIN TRAN
	BEGIN TRY
		IF @madt = NULL OR @tendt = NULL OR @capql = NULL OR @kp = NULL OR @ngaybd = NULL OR @ngaykt = NULL OR @macd = NULL OR @gvcndt = NULL
			BEGIN
				PRINT N'Thông tin nhập vào không được chứa giá trị rỗng'
				ROLLBACK TRAN
				RETURN 1
			END

		IF NOT EXISTS (SELECT * FROM CHUDE WHERE MACD = @macd)
			BEGIN
				PRINT @madt + N' không tồn tại mã chủ đề'
				ROLLBACK TRAN
				RETURN 1
			END
		IF NOT EXISTS (SELECT * FROM GIAOVIEN WHERE MAGV = @gvcndt)
			BEGIN
				PRINT @gvcndt + N' không tồn tại mã giáo viên'
				ROLLBACK TRAN
				RETURN 1
			END
		IF @ngaybd > @ngaykt
			BEGIN
				PRINT N'Ngày bắt đầu công việc phải trước ngày kết thúc công việc'
				ROLLBACK TRAN
				RETURN 1
			END
		IF NOT EXISTS (SELECT * FROM DETAI WHERE MADT = @madt)
			BEGIN
				PRINT @madt + N' không tồn tại mã đề tài'
				ROLLBACK TRAN
				RETURN 1
			END
		IF EXISTS (SELECT * FROM DETAI WHERE MADT = @madt AND TENDT = @tendt AND CAPQL = @capql AND KINHPHI = @kp AND NGAYBD = @ngaybd AND NGAYKT = @ngaykt
													AND MACD = @macd AND GVCNDT = @gvcndt)
			BEGIN
				PRINT N'Thông tin ngoài khóa phải có sự thay đổi so với thông tin ban đầu'
				ROLLBACK TRAN
				RETURN 1
			END
		IF NOT EXISTS (SELECT * FROM BOMON BM, KHOA K WHERE BM.TRUONGBM = @gvcndt OR K.TRUONGKHOA = @gvcndt)
			BEGIN
				PRINT N'GVCNDT phải là trưởng bộ môn hoặc trưởng khoa'
				ROLLBACK TRAN
				RETURN 1
			END
		IF  @capql = N'ĐHQG' AND @kp < (SELECT KINHPHI FROM DETAI WHERE CAPQL = N'Trường')
			BEGIN
				PRINT N'Cấp quản lý ĐHQG phải có kinh phí cao hơn cấp trường'
				ROLLBACK TRAN
				RETURN 1
			END
		IF  @capql = N'Nhà nước' AND @kp < (SELECT KINHPHI FROM DETAI WHERE CAPQL = N'Trường' OR CAPQL = N'ĐHQG')
			BEGIN
				PRINT N'Cấp quản lý Nhà nước phải có kinh phí cao hơn cấp trường hoặc cấp ĐHQG'
				ROLLBACK TRAN
				RETURN 1
			END
		IF @capql = N'Trường' AND EXISTS (SELECT * FROM DETAI WHERE MADT = @madt AND CAPQL != N'Trường')
			BEGIN
				PRINT N'Cấp quản lý chỉ được nâng lên không được hạ xuống'
				ROLLBACK TRAN
				RETURN 1
			END
		IF @capql = N'ĐHQG' AND EXISTS (SELECT * FROM DETAI WHERE MADT = @madt AND CAPQL = N'Nhà nước')
			BEGIN
				PRINT N'Cấp quản lý chỉ được nâng lên không được hạ xuống'
				ROLLBACK TRAN
				RETURN 1
			END
		UPDATE DETAI
		SET TENDT = @tendt, CAPQL = @capql, KINHPHI = @kp, NGAYBD = @ngaybd, NGAYKT = @ngaykt, MACD = @macd, GVCNDT = @gvcndt
		WHERE MADT = @madt
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO

--6. Xóa đề tài
CREATE 
--ALTER
PROC USP_XOADETAI
	@madt char(3)
AS 
BEGIN TRAN
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM DETAI WHERE MADT = @madt)
			BEGIN
				PRINT @madt + N' không tồn tại mã đề tài'
				ROLLBACK TRAN
				RETURN 1
			END
		IF EXISTS (SELECT * FROM THAMGIADT WHERE MADT = @madt)
			BEGIN
				PRINT N'Đề tài đã được tham gia'
				ROLLBACK TRAN
				RETURN 1
			END
		IF GETDATE() < (SELECT NGAYKT FROM DETAI WHERE MADT = @madt)
			BEGIN
				PRINT N'Đề tài chưa kết thúc'
				ROLLBACK TRAN
				RETURN 1
			END
		DELETE FROM DETAI
		WHERE MADT = @madt
	END TRY
	BEGIN CATCH
		PRINT N'Lỗi hệ thống'
		ROLLBACK TRAN
	END CATCH
COMMIT TRAN
RETURN 0
GO

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
