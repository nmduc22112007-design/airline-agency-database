-- ================================================================
-- FILE: 12_Stored_Procedures.sql
-- MÔ TẢ :
--   Định nghĩa các Stored Procedure phục vụ xử lý nghiệp vụ
--   cho hệ thống quản lý đặt vé máy bay của đại lý.
--
-- MỤC ĐÍCH:
--   - Đáp ứng yêu cầu lập trình SQL (Stored Procedure) của đề tài
--   - Gom các nghiệp vụ có logic xử lý vào một điểm duy nhất
--   - Mô phỏng cách vận hành của hệ thống thực tế
--
-- ENGINE  : SQL Server 2022
-- GHI CHÚ :
--   - Các thủ tục có kiểm tra nghiệp vụ trước khi thao tác dữ liệu
--   - Không cho phép cập nhật dữ liệu sai luật nghiệp vụ
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   STORED PROCEDURE 01: sp_ThemLichBay
   MÔ TẢ :
   - Thêm mới một lịch bay cho chuyến bay do hãng cung cấp

   THAM SỐ:
   - @MaCB VARCHAR(10)   : mã chuyến bay
   - @NgayBay DATE       : ngày bay
   - @SoHieuMB VARCHAR(20) : số hiệu máy bay

   NGHIỆP VỤ:
   - Chuyến bay phải tồn tại
   - Máy bay phải tồn tại
   - Mỗi chuyến bay chỉ được bố trí tối đa một lần trong một ngày
   ================================================================ */
CREATE OR ALTER PROCEDURE sp_ThemLichBay
    @MaCB VARCHAR(10),
    @NgayBay DATE,
    @SoHieuMB VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM ChuyenBay WHERE MaCB = @MaCB)
    BEGIN
        RAISERROR(N'Chuyến bay không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MayBay WHERE SoHieuMB = @SoHieuMB)
    BEGIN
        RAISERROR(N'Máy bay không tồn tại.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM LichBay
        WHERE MaCB = @MaCB AND NgayBay = @NgayBay
    )
    BEGIN
        RAISERROR(N'Chuyến bay đã có lịch trong ngày này.', 16, 1);
        RETURN;
    END

    INSERT INTO LichBay (MaCB, NgayBay, SoHieuMB)
    VALUES (@MaCB, @NgayBay, @SoHieuMB);
END
GO


/* ================================================================
   STORED PROCEDURE 02: sp_DatCho
   MÔ TẢ :
   - Thực hiện đặt chỗ cho khách hàng theo lịch bay

   THAM SỐ:
   - @MaKH VARCHAR(15) : mã khách hàng
   - @MaCB VARCHAR(10) : mã chuyến bay
   - @NgayDi DATE      : ngày bay

   NGHIỆP VỤ:
   - Khách hàng phải tồn tại
   - Lịch bay phải tồn tại
   - Mỗi khách hàng chỉ được đặt một chỗ cho một chuyến bay trong một ngày
   ================================================================ */
CREATE OR ALTER PROCEDURE sp_DatCho
    @MaKH VARCHAR(15),
    @MaCB VARCHAR(10),
    @NgayDi DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKH = @MaKH)
    BEGIN
        RAISERROR(N'Khách hàng không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (
        SELECT 1 FROM LichBay
        WHERE MaCB = @MaCB AND NgayBay = @NgayDi
    )
    BEGIN
        RAISERROR(N'Lịch bay không tồn tại.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM DatCho
        WHERE MaKH = @MaKH AND MaCB = @MaCB AND NgayDi = @NgayDi
    )
    BEGIN
        RAISERROR(N'Khách hàng đã đặt chỗ cho chuyến bay này.', 16, 1);
        RETURN;
    END

    INSERT INTO DatCho (MaKH, MaCB, NgayDi, TrangThai, NgayDat)
    VALUES (@MaKH, @MaCB, @NgayDi, 1, GETDATE());
END
GO


/* ================================================================
   STORED PROCEDURE 03: sp_HuyDatCho
   MÔ TẢ :
   - Hủy đặt chỗ của khách hàng (soft delete)

   THAM SỐ:
   - @MaKH VARCHAR(15)
   - @MaCB VARCHAR(10)
   - @NgayDi DATE

   NGHIỆP VỤ:
   - Không xóa vật lý dữ liệu
   - Chỉ cập nhật TrangThai = 3
   ================================================================ */
CREATE OR ALTER PROCEDURE sp_HuyDatCho
    @MaKH VARCHAR(15),
    @MaCB VARCHAR(10),
    @NgayDi DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM DatCho
        WHERE MaKH = @MaKH AND MaCB = @MaCB AND NgayDi = @NgayDi
    )
    BEGIN
        RAISERROR(N'Không tồn tại đặt chỗ cần hủy.', 16, 1);
        RETURN;
    END

    UPDATE DatCho
    SET TrangThai = 3
    WHERE MaKH = @MaKH
      AND MaCB = @MaCB
      AND NgayDi = @NgayDi;
END
GO


/* ================================================================
   STORED PROCEDURE 04: sp_ThongKeDatCho_TheoThangNam
   MÔ TẢ :
   - Thống kê tổng số đặt chỗ theo tháng hoặc theo năm

   THAM SỐ:
   - @Nam INT
   - @Thang INT = NULL

   NGHIỆP VỤ:
   - Nếu @Thang có giá trị => thống kê theo tháng
   - Nếu @Thang = NULL     => thống kê toàn bộ năm
   ================================================================ */
CREATE OR ALTER PROCEDURE sp_ThongKeDatCho_TheoThangNam
    @Nam INT,
    @Thang INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        YEAR(NgayDi) AS Nam,
        MONTH(NgayDi) AS Thang,
        COUNT(*) AS TongDatCho
    FROM DatCho
    WHERE YEAR(NgayDi) = @Nam
      AND (@Thang IS NULL OR MONTH(NgayDi) = @Thang)
    GROUP BY YEAR(NgayDi), MONTH(NgayDi)
    ORDER BY Thang;
END
GO


/* ================================================================
   STORED PROCEDURE 05: sp_LayDanhSachHanhKhach
   MÔ TẢ :
   - Lấy danh sách hành khách theo một lịch bay cụ thể

   THAM SỐ:
   - @MaCB VARCHAR(10)
   - @NgayBay DATE

   NGHIỆP VỤ:
   - Chỉ lấy các booking chưa hủy
   - Phục vụ tra cứu hành khách khi làm thủ tục
   ================================================================ */
CREATE OR ALTER PROCEDURE sp_LayDanhSachHanhKhach
    @MaCB VARCHAR(10),
    @NgayBay DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        kh.MaKH,
        kh.TenKH,
        kh.SoDienThoai,
        kh.DiaChi
    FROM DatCho dc
    INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
    WHERE dc.MaCB = @MaCB
      AND dc.NgayDi = @NgayBay
      AND dc.TrangThai <> 3
    ORDER BY kh.TenKH;
END
GO

-- ================================================================
-- END OF FILE: 12_Stored_Procedures.sql
-- ================================================================