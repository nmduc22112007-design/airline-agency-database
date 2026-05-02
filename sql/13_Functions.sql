-- ================================================================
-- FILE: 13_Functions.sql
-- MÔ TẢ :
--   Định nghĩa các hàm (Function) phục vụ tính toán nghiệp vụ
--   cho hệ thống quản lý đặt vé máy bay.
--
-- MỤC ĐÍCH:
--   - Đáp ứng yêu cầu lập trình SQL (Function) của đề tài
--   - Gom các phép tính nghiệp vụ dùng lại nhiều lần
--   - Hạn chế lặp logic trong truy vấn và stored procedure
--
-- ENGINE  : SQL Server 2022
-- GHI CHÚ :
--   - Các hàm chỉ trả về giá trị, KHÔNG cập nhật dữ liệu
--   - Chỉ tính các booking còn hiệu lực (TrangThai <> 3)
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   FUNCTION 01: fn_SoKhachDaDat
   MÔ TẢ :
   - Tính số khách đã đặt chỗ cho một lịch bay cụ thể

   THAM SỐ:
   - @MaCB VARCHAR(10) : mã chuyến bay
   - @NgayBay DATE     : ngày bay

   GIÁ TRỊ TRẢ VỀ:
   - INT : số khách đã đặt chỗ

   NGHIỆP VỤ:
   - Chỉ tính các booking chưa hủy (TrangThai <> 3)
   ================================================================ */
CREATE OR ALTER FUNCTION fn_SoKhachDaDat
(
    @MaCB VARCHAR(10),
    @NgayBay DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @SoKhach INT;

    SELECT @SoKhach = COUNT(*)
    FROM DatCho
    WHERE MaCB = @MaCB
      AND NgayDi = @NgayBay
      AND TrangThai <> 3;

    RETURN ISNULL(@SoKhach, 0);
END
GO


/* ================================================================
   FUNCTION 02: fn_SoChoConTrong
   MÔ TẢ :
   - Tính số chỗ còn trống của một lịch bay

   THAM SỐ:
   - @MaCB VARCHAR(10) : mã chuyến bay
   - @NgayBay DATE     : ngày bay

   GIÁ TRỊ TRẢ VỀ:
   - INT : số chỗ còn trống

   NGHIỆP VỤ:
   - Số chỗ còn trống = tổng số ghế - số khách đã đặt
   ================================================================ */
CREATE OR ALTER FUNCTION fn_SoChoConTrong
(
    @MaCB VARCHAR(10),
    @NgayBay DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @TongSoGhe INT;
    DECLARE @SoKhach INT;

    SELECT @TongSoGhe = mb.SoGhe
    FROM LichBay lb
    INNER JOIN MayBay mb ON lb.SoHieuMB = mb.SoHieuMB
    WHERE lb.MaCB = @MaCB
      AND lb.NgayBay = @NgayBay;

    SET @SoKhach = dbo.fn_SoKhachDaDat(@MaCB, @NgayBay);

    RETURN ISNULL(@TongSoGhe, 0) - ISNULL(@SoKhach, 0);
END
GO


/* ================================================================
   FUNCTION 03: fn_TongChuyenBay_KhachHang
   MÔ TẢ :
   - Tính tổng số chuyến bay mà một khách hàng đã đặt

   THAM SỐ:
   - @MaKH VARCHAR(15) : mã khách hàng

   GIÁ TRỊ TRẢ VỀ:
   - INT : tổng số chuyến bay

   NGHIỆP VỤ:
   - Chỉ tính các booking chưa hủy
   ================================================================ */
CREATE OR ALTER FUNCTION fn_TongChuyenBay_KhachHang
(
    @MaKH VARCHAR(15)
)
RETURNS INT
AS
BEGIN
    DECLARE @Tong INT;

    SELECT @Tong = COUNT(*)
    FROM DatCho
    WHERE MaKH = @MaKH
      AND TrangThai <> 3;

    RETURN ISNULL(@Tong, 0);
END
GO


/* ================================================================
   FUNCTION 04: fn_TyLeLapDay_ChuyenBay
   MÔ TẢ :
   - Tính tỷ lệ lấp đầy của một lịch bay

   THAM SỐ:
   - @MaCB VARCHAR(10)
   - @NgayBay DATE

   GIÁ TRỊ TRẢ VỀ:
   - DECIMAL(5,2) : tỷ lệ lấp đầy (%)

   NGHIỆP VỤ:
   - Tỷ lệ = (số khách đã đặt / tổng số ghế) * 100
   - Nếu không có ghế thì trả về 0
   ================================================================ */
CREATE OR ALTER FUNCTION fn_TyLeLapDay_ChuyenBay
(
    @MaCB VARCHAR(10),
    @NgayBay DATE
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @TongSoGhe INT;
    DECLARE @SoKhach INT;
    DECLARE @TyLe DECIMAL(5,2);

    SELECT @TongSoGhe = mb.SoGhe
    FROM LichBay lb
    INNER JOIN MayBay mb ON lb.SoHieuMB = mb.SoHieuMB
    WHERE lb.MaCB = @MaCB
      AND lb.NgayBay = @NgayBay;

    SET @SoKhach = dbo.fn_SoKhachDaDat(@MaCB, @NgayBay);

    IF @TongSoGhe IS NULL OR @TongSoGhe = 0
        SET @TyLe = 0;
    ELSE
        SET @TyLe = (@SoKhach * 100.0) / @TongSoGhe;

    RETURN @TyLe;
END
GO

-- ================================================================
-- END OF FILE: 13_Functions.sql
-- ================================================================