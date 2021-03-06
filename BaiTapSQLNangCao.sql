create database BaiTapSQLNangCao

use BaiTapSQLNangCao


-- KhachHang
CREATE TABLE KhachHang
(
MaKH nvarchar(10) NOT NULL,
TenKH nvarchar(30),
Email nvarchar(50),
SDT nvarchar(11),
DiaChi nvarchar(255),
CONSTRAINT pk_KhachHang PRIMARY KEY (MaKH)
);

-- DMSanPham
CREATE TABLE DMSanPham
(
MaDM nvarchar(10) NOT NULL, 
TenDanhMuc nvarchar(30),
MoTa nvarchar(50),
CONSTRAINT pk_DMSanPham PRIMARY KEY (MaDM)
);

-- SanPham
CREATE TABLE SanPham
(
MaSP nvarchar(10) NOT NULL,
MaDM nvarchar(10) NOT NULL,
TenSP nvarchar(50),
SoLuong int,
GiaTien money,
XuatXu nvarchar(50),
--CONSTRAINT uc_SanPham UNIQUE (MaSP),
CONSTRAINT pk_SanPham PRIMARY KEY (MaSP),
CONSTRAINT fk_DMSanPham_SanPham FOREIGN KEY (MaDM)
REFERENCES DMSanPham(MaDM)
);

-- ThanhToan
CREATE TABLE ThanhToan
(
MaTT nvarchar(10) NOT NULL, 
PhuongThucTT nvarchar(30),
CONSTRAINT pk_ThanhToan PRIMARY KEY (MaTT)
);

--DonHang
CREATE TABLE DonHang
(
MaDH nvarchar(10) NOT NULL,
MaKH nvarchar(10) NOT NULL,
MaTT nvarchar(10) NOT NULL,
NgayDat Date,
--CONSTRAINT uc_DonHang UNIQUE (MaDH),
CONSTRAINT pk_DonHang PRIMARY KEY (MaDH),
CONSTRAINT fk_KhachHang_DonHang FOREIGN KEY (MaKH)
REFERENCES KhachHang(MaKH),
CONSTRAINT fk_ThanhToan_DonHang FOREIGN KEY (MaTT)
REFERENCES ThanhToan(MaTT)
);

-- ChiTietDonHang
CREATE TABLE ChiTietDonHang
(
MaDH nvarchar(10) NOT NULL,
MaSP nvarchar(10) NOT NULL,
SoLuong int,
TongTien money,
CONSTRAINT pk_ChiTietDonHang PRIMARY KEY (MaDH, MaSP),
CONSTRAINT fk_DonHang_ChiTietDonHang FOREIGN KEY (MaDH)
REFERENCES DonHang(MaDH),
CONSTRAINT fk_SanPham_ChiTietDonHang FOREIGN KEY (MaSP)
REFERENCES SanPham(MaSP)
);


--Cau 1:
	--a
	CREATE View V_KhachHang AS
		SELECT * FROM DonHang WHERE
		DonHang.MaKH IN(SELECT MaKH FROM KhachHang WHERE KhachHang.DiaChi = 'Da Nang')
		AND DonHang.NgayDat < '06/15/2015'
		
	--DROP VIEW V_KhachHang
	SELECT * FROM V_KhachHang

	--b
	UPDATE V_KhachHang
	SET NgayDat='06/15/2015' WHERE NgayDat='06/15/2014'

--Cau 2
	--a
	CREATE PROCEDURE Sp_1
		@MaSP	nvarchar(10) 
	AS
	BEGIN
		DELETE FROM SanPham WHERE MaSP = @MaSP
	END;
	--DROP PROCEDURE  Sp_1
	exec Sp_1 'SP003'
	
	
	--b
	CREATE PROC Sp_2
		@MaDH nvarchar(10),
		@MaSP nvarchar(10),
		@SoLuong INT,
		@TongTien MONEY
	AS 
	BEGIN 
       IF EXISTS (SELECT * FROM ChiTietDonHang WHERE MaDH=@MaDH AND MaSP=@MaSP)
       BEGIN
              PRINT 'TRUNG KHOA CHINH'
              RETURN
       END
       
       IF NOT EXISTS (SELECT * FROM DonHang WHERE MaDH=@MaDH)
       BEGIN
              PRINT 'KHONG TON TAI MADH'
              RETURN
       END
       IF NOT EXISTS (SELECT * FROM SanPham WHERE MaSP=@MaSP)
       BEGIN
              PRINT 'KHONG TON TAI MASP'
              RETURN
       END
       INSERT INTO ChiTietDonHang(MaDH, MaSP, SoLuong, TongTien) 
			VALUES (@MaDH, @MaSP, @SoLuong, @TongTien)
       PRINT 'THEM DU LIEU THANH CONG'
	END
	GO

	EXEC Sp_2 'DH003','SP002',3,56000.0000


--Cau 3
	--a
	CREATE TRIGGER Trigger_1
		ON ChiTietDonHang
		AFTER INSERT
	AS 
	BEGIN
		DECLARE 
		@MaSP nvarchar(10),
		@SoLuong int
		SELECT @MaSP = INSERTED.MaSP, @SoLuong = INSERTED.SoLuong
		FROM INSERTED
		UPDATE SanPham 
		SET SoLuong = SoLuong - @SoLuong
		WHERE MaSP = @MaSP
    END
    GO
    --DROP TRigger Trigger_1
	EXEC Sp_2 'DH001','SP001',5,56000.0000
	
	--b
	CREATE TRIGGER Trigger_2
		ON ChiTietDonHang
		AFTER INSERT
	AS 
	BEGIN
		DECLARE 
		@MaSP nvarchar(10),
		@SoLuong int
		SELECT @MaSP = INSERTED.MaSP, @SoLuong = INSERTED.SoLuong FROM INSERTED
		IF(@SoLuong BETWEEN 1 AND 100)
		BEGIN
			UPDATE SanPham 
			SET SoLuong = SoLuong - @SoLuong
			WHERE MaSP = @MaSP
		END
		ELSE
		BEGIN
			PRINT 'Số lượng sản phẩm được đặt hàng phải nằm trong khoảng giá trị từ 1 đến 100'
			ROLLBACK TRANSACTION
		END
    END
    GO
    --DROP TRigger Trigger_2
	EXEC Sp_2 'DH001','SP001',100,56000.0000