-- ================================================================
-- QUERY 10: Các truy vấn nghiệp vụ chính
-- MÔ TẢ :
--   Tập hợp các câu truy vấn nghiệp vụ chính cho hệ thống
--   quản lý đặt vé máy bay.
--
-- NỘI DUNG:
--   Q01. Danh sách khách hàng bay trong ngày / tháng
--   Q02. Khách hàng không bay trong tháng / năm
--   Q03. Chuyến bay không có khách đặt chỗ
--   Q04. Tổng số chuyến bay theo sân bay đi hoặc theo giờ khởi hành
--   Q05. Khách hàng có số chuyến bay nhiều nhất
--   Q06. Chuyến bay có nhiều / ít khách đặt chỗ nhất
--   Q07. Danh sách khách hàng theo lịch bay cụ thể
--
-- ENGINE  : SQL Server 2022
-- VERSION : 2.0
-- GHI CHÚ :
--   - Áp dụng CASE 2: Có xét chuyến bay qua đêm
--   - NgàyBay / NgàyĐi đều được hiểu là NGÀY KHỞI HÀNH
--   - Các truy vấn nghiệp vụ chỉ tính booking còn hiệu lực:
--       TrangThai <> 3 (không tính vé đã hủy)
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   Q01. DANH SÁCH KHÁCH HÀNG BAY TRONG NGÀY / THÁNG
   MÔ TẢ :
   - Lấy danh sách khách hàng có lịch bay trong một ngày cụ thể
   - Hoặc trong một tháng / năm cụ thể

   THAM SỐ:
   - @Q01_Date DATE : ngày cần tra cứu
   - @Q01_Year INT  : năm cần tra cứu khi lọc theo tháng
   - @Q01_Month INT : tháng cần tra cứu khi lọc theo tháng

   NGHIỆP VỤ:
   - Chỉ tính booking chưa hủy (TrangThai <> 3)
   - Nếu @Q01_Date có giá trị => lọc theo ngày
   - Nếu @Q01_Date = NULL và có @Q01_Year + @Q01_Month => lọc theo tháng
   ================================================================ */
DECLARE @Q01_Date DATE = '2025-05-01';   -- Đặt NULL nếu muốn lọc theo tháng
DECLARE @Q01_Year INT = 2025;
DECLARE @Q01_Month INT = 5;

IF @Q01_Date IS NOT NULL
BEGIN
    SELECT
        kh.MaKH,
        kh.TenKH,
        kh.SoDienThoai,
        dc.MaCB,
        dc.NgayDi,
        cb.SanBayDi,
        cb.SanBayDen
    FROM DatCho dc
    INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
    INNER JOIN ChuyenBay cb ON dc.MaCB = cb.MaCB
    WHERE dc.NgayDi = @Q01_Date
      AND dc.TrangThai <> 3
    ORDER BY kh.TenKH, dc.MaCB;
END
ELSE
BEGIN
    SELECT
        kh.MaKH,
        kh.TenKH,
        kh.SoDienThoai,
        dc.MaCB,
        dc.NgayDi,
        cb.SanBayDi,
        cb.SanBayDen
    FROM DatCho dc
    INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
    INNER JOIN ChuyenBay cb ON dc.MaCB = cb.MaCB
    WHERE YEAR(dc.NgayDi) = @Q01_Year
      AND MONTH(dc.NgayDi) = @Q01_Month
      AND dc.TrangThai <> 3
    ORDER BY kh.TenKH, dc.NgayDi, dc.MaCB;
END
GO


/* ================================================================
   Q02. KHÁCH HÀNG KHÔNG BAY TRONG THÁNG / NĂM
   MÔ TẢ :
   - Tìm các khách hàng không có chuyến bay trong một tháng cụ thể
   - Hoặc trong toàn bộ một năm

   THAM SỐ:
   - @Q02_Year INT  : năm cần tra cứu
   - @Q02_Month INT : tháng cần tra cứu
                      Đặt NULL nếu muốn kiểm tra cả năm

   NGHIỆP VỤ:
   - Nếu @Q02_Month có giá trị => kiểm tra trong tháng / năm đó
   - Nếu @Q02_Month = NULL     => kiểm tra toàn bộ năm
   - Không tính booking đã hủy
   ================================================================ */
DECLARE @Q02_Year INT = 2025;
DECLARE @Q02_Month INT = 5;     -- Đặt NULL nếu muốn kiểm tra cả năm

SELECT
    kh.MaKH,
    kh.TenKH,
    kh.DiaChi,
    kh.SoDienThoai
FROM KhachHang kh
WHERE NOT EXISTS (
    SELECT 1
    FROM DatCho dc
    WHERE dc.MaKH = kh.MaKH
      AND YEAR(dc.NgayDi) = @Q02_Year
      AND (@Q02_Month IS NULL OR MONTH(dc.NgayDi) = @Q02_Month)
      AND dc.TrangThai <> 3
)
ORDER BY kh.TenKH;
GO


/* ================================================================
   Q03. CHUYẾN BAY KHÔNG CÓ KHÁCH ĐẶT CHỖ
   MÔ TẢ :
   - Liệt kê các lịch bay không có khách đặt chỗ thực tế

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Nếu tất cả booking của lịch bay đều đã hủy, vẫn xem là
     "không có khách"
   - Chỉ xét booking có TrangThai <> 3
   ================================================================ */
SELECT
    lb.MaCB,
    lb.NgayBay,
    cb.SanBayDi,
    cb.SanBayDen,
    lb.SoHieuMB
FROM LichBay lb
INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
WHERE NOT EXISTS (
    SELECT 1
    FROM DatCho dc
    WHERE dc.MaCB = lb.MaCB
      AND dc.NgayDi = lb.NgayBay
      AND dc.TrangThai <> 3
)
ORDER BY lb.NgayBay, lb.MaCB;
GO


/* ================================================================
   Q04. TỔNG SỐ CHUYẾN BAY THEO SÂN BAY ĐI HOẶC THEO GIỜ
   MÔ TẢ :
   - Thống kê tổng số lịch bay theo sân bay đi
   - Hoặc theo giờ khởi hành

   THAM SỐ:
   - @Q04_GroupBy VARCHAR(20) : 'airport' hoặc 'hour'

   NGHIỆP VỤ:
   - Dữ liệu được thống kê theo LichBay (lịch thực tế)
   - @Q04_GroupBy = 'airport' => nhóm theo sân bay đi
   - @Q04_GroupBy = 'hour'    => nhóm theo giờ khởi hành
   ================================================================ */
DECLARE @Q04_GroupBy VARCHAR(20) = 'airport';  -- 'airport' hoặc 'hour'

IF @Q04_GroupBy = 'airport'
BEGIN
    SELECT
        cb.SanBayDi,
        COUNT(lb.MaCB) AS TongSoCB
    FROM LichBay lb
    INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
    GROUP BY cb.SanBayDi
    ORDER BY TongSoCB DESC, cb.SanBayDi;
END
ELSE IF @Q04_GroupBy = 'hour'
BEGIN
    SELECT
        DATEPART(HOUR, cb.GioDi) AS GioKhoiHanh,
        COUNT(*) AS SoChuyen
    FROM LichBay lb
    INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
    GROUP BY DATEPART(HOUR, cb.GioDi)
    ORDER BY GioKhoiHanh;
END
ELSE
BEGIN
    RAISERROR(N'Giá trị @Q04_GroupBy không hợp lệ. Chỉ chấp nhận: airport | hour.', 16, 1);
END
GO


/* ================================================================
   Q05. KHÁCH HÀNG CÓ SỐ CHUYẾN BAY NHIỀU NHẤT
   MÔ TẢ :
   - Tìm tất cả khách hàng có số chuyến bay cao nhất

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Không tính vé đã hủy
   - Trả về tất cả khách hàng đồng hạng cao nhất
   ================================================================ */
WITH FlightCount AS (
    SELECT
        dc.MaKH,
        COUNT(dc.MaCB) AS TongChuyen
    FROM DatCho dc
    WHERE dc.TrangThai <> 3
    GROUP BY dc.MaKH
)
SELECT
    kh.MaKH,
    kh.TenKH,
    fc.TongChuyen
FROM FlightCount fc
INNER JOIN KhachHang kh ON fc.MaKH = kh.MaKH
WHERE fc.TongChuyen = (
    SELECT MAX(TongChuyen)
    FROM FlightCount
)
ORDER BY kh.TenKH;
GO


/* ================================================================
   Q06. CHUYẾN BAY CÓ NHIỀU / ÍT KHÁCH ĐẶT CHỖ NHẤT
   MÔ TẢ :
   - Liệt kê các lịch bay có nhiều khách nhất
   - Và các lịch bay có ít khách nhất (nhưng > 0)

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Không tính vé đã hủy
   - Lịch bay 0 khách không đưa vào nhóm "ít nhất"
   - Vì lịch bay 0 khách đã được xử lý riêng ở Query 03
   ================================================================ */
WITH BookingCount AS (
    SELECT
        dc.MaCB,
        dc.NgayDi,
        COUNT(dc.MaKH) AS SoKhach
    FROM DatCho dc
    WHERE dc.TrangThai <> 3
    GROUP BY dc.MaCB, dc.NgayDi
)
SELECT
    N'NHIỀU NHẤT' AS Nhom,
    bc.MaCB,
    bc.NgayDi,
    bc.SoKhach,
    cb.SanBayDi,
    cb.SanBayDen
FROM BookingCount bc
INNER JOIN ChuyenBay cb ON bc.MaCB = cb.MaCB
WHERE bc.SoKhach = (
    SELECT MAX(SoKhach)
    FROM BookingCount
)

UNION ALL

SELECT
    N'ÍT NHẤT (>0)' AS Nhom,
    bc.MaCB,
    bc.NgayDi,
    bc.SoKhach,
    cb.SanBayDi,
    cb.SanBayDen
FROM BookingCount bc
INNER JOIN ChuyenBay cb ON bc.MaCB = cb.MaCB
WHERE bc.SoKhach = (
    SELECT MIN(SoKhach)
    FROM BookingCount
    WHERE SoKhach > 0
)
ORDER BY Nhom DESC, SoKhach DESC, NgayDi, MaCB;
GO


/* ================================================================
   Q07. THÔNG TIN KHÁCH HÀNG THEO LỊCH BAY CỤ THỂ
   MÔ TẢ :
   - Lấy danh sách khách hàng của một lịch bay cụ thể

   THAM SỐ:
   - @Q07_MaCB VARCHAR(10) : mã chuyến bay
   - @Q07_NgayDi DATE      : ngày đi / ngày khởi hành

   NGHIỆP VỤ:
   - Chỉ lấy booking chưa hủy
   - Dùng để xem danh sách hành khách theo MaCB + NgayDi
   ================================================================ */
DECLARE @Q07_MaCB VARCHAR(10) = 'VN101';
DECLARE @Q07_NgayDi DATE = '2025-05-01';

SELECT
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai,
    kh.DiaChi,
    dc.NgayDat,
    dc.TrangThai
FROM DatCho dc
INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
WHERE dc.MaCB = @Q07_MaCB
  AND dc.NgayDi = @Q07_NgayDi
  AND dc.TrangThai <> 3
ORDER BY kh.TenKH;
GO

-- ================================================================
-- END OF FILE: 10_Business_Query.sql
-- ================================================================