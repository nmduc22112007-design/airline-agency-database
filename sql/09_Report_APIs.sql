-- ================================================================
-- QUERY 09: Report APIs
-- MÔ TẢ :
--   Các API báo cáo và thống kê cho hệ thống quản lý đặt vé máy bay
--   (chạy sau file 08_CRUD_APIs.sql)
--
-- DANH SÁCH ENDPOINT:
--   [R01] GET /api/reports/customers/flying?date={date}
--   [R02] GET /api/reports/customers/flying?month={MM}&year={YYYY}
--   [R03] GET /api/reports/customers/inactive?month={MM}&year={YYYY}
--   [R04] GET /api/reports/flights/no-bookings
--   [R05] GET /api/reports/flights/stats?groupBy=airport|hour
--   [R06] GET /api/reports/bookings/count?period=monthly|yearly
--   [R07] GET /api/reports/customers/top-flyers
--   [R08] GET /api/reports/flights/most-least-booked
--   [R09] GET /api/flights/schedules/{MaCB}/{NgayBay}/passengers
--
-- ENGINE  : SQL Server 2022
-- VERSION : 2.0
-- GHI CHÚ :
--   - Áp dụng CASE 2: Có xét chuyến bay qua đêm
--   - NgàyBay / NgàyĐi luôn được hiểu là NGÀY KHỞI HÀNH
--   - Các cột thời gian khi hiển thị ra kết quả đều dùng định dạng 24 giờ: HH:MM:SS
--   - Không hiển thị phần thập phân của giây
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   [R01] GET /api/reports/customers/flying?date={date}
   MÔ TẢ :
   - Lấy danh sách khách hàng bay trong một ngày cụ thể

   THAM SỐ:
   - @R01_Ngay DATE : ngày cần tra cứu

   NGHIỆP VỤ:
   - Chỉ tính booking chưa hủy (TrangThai <> 3)
   - NgàyĐi là ngày KHỞI HÀNH
   - Giờ đi / Giờ đến được hiển thị theo định dạng 24 giờ: HH:MM:SS
   ================================================================ */
DECLARE @R01_Ngay DATE = '2025-05-01';

SELECT
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai,
    kh.DiaChi,
    dc.MaCB,
    sb_di.TenSB AS SanBayDi,
    sb_den.TenSB AS SanBayDen,

    -- Hiển thị giờ theo định dạng 24 giờ, không có phần thập phân của giây
    CONVERT(VARCHAR(8), cb.GioDi, 108) AS GioDi,
    CONVERT(VARCHAR(8), cb.GioDen, 108) AS GioDen,

    CASE
        WHEN cb.GioDen > cb.GioDi THEN N'Cùng ngày'
        ELSE N'Qua đêm'
    END AS LoaiChuyen,
    dc.TrangThai
FROM DatCho dc
INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
INNER JOIN ChuyenBay cb ON dc.MaCB = cb.MaCB
INNER JOIN SanBay sb_di ON cb.SanBayDi = sb_di.MaSB
INNER JOIN SanBay sb_den ON cb.SanBayDen = sb_den.MaSB
WHERE dc.NgayDi = @R01_Ngay
  AND dc.TrangThai <> 3
ORDER BY kh.TenKH, dc.MaCB;
GO


/* ================================================================
   [R02] GET /api/reports/customers/flying?month={MM}&year={YYYY}
   MÔ TẢ :
   - Lấy danh sách khách hàng bay trong một tháng cụ thể

   THAM SỐ:
   - @R02_Thang INT : tháng cần tra cứu
   - @R02_Nam INT   : năm cần tra cứu

   NGHIỆP VỤ:
   - Chỉ tính booking chưa hủy (TrangThai <> 3)
   - Mỗi khách hàng xuất hiện một dòng kèm tổng số chuyến trong tháng đó
   - Dữ liệu được sắp xếp giảm dần theo tổng số chuyến
   ================================================================ */
DECLARE @R02_Thang INT = 5;
DECLARE @R02_Nam INT = 2025;

SELECT
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai,
    COUNT(*) AS TongChuyen
FROM DatCho dc
INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
WHERE MONTH(dc.NgayDi) = @R02_Thang
  AND YEAR(dc.NgayDi) = @R02_Nam
  AND dc.TrangThai <> 3
GROUP BY kh.MaKH, kh.TenKH, kh.SoDienThoai
ORDER BY TongChuyen DESC, kh.TenKH;
GO


/* ================================================================
   [R03] GET /api/reports/customers/inactive?month={MM}&year={YYYY}
   MÔ TẢ :
   - Lấy danh sách khách hàng không bay trong tháng hoặc trong năm

   THAM SỐ:
   - @R03_Thang INT = NULL : tháng cần tra cứu
   - @R03_Nam INT          : năm cần tra cứu

   NGHIỆP VỤ:
   - Nếu @R03_Thang có giá trị => kiểm tra trong THÁNG đó của NĂM đó
   - Nếu @R03_Thang = NULL     => kiểm tra trong TOÀN BỘ NĂM đó
   - Không tính các booking đã hủy
   ================================================================ */
DECLARE @R03_Thang INT = 5;      -- Đặt NULL nếu muốn kiểm tra cả năm
DECLARE @R03_Nam INT = 2025;

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
      AND YEAR(dc.NgayDi) = @R03_Nam
      AND (@R03_Thang IS NULL OR MONTH(dc.NgayDi) = @R03_Thang)
      AND dc.TrangThai <> 3
)
ORDER BY kh.TenKH;
GO


/* ================================================================
   [R04] GET /api/reports/flights/no-bookings
   MÔ TẢ :
   - Lấy danh sách lịch bay không có khách đặt chỗ

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Nếu tất cả booking của lịch bay đều đã hủy thì vẫn xem là không có khách đặt chỗ
   - Giờ đi / Giờ đến được hiển thị theo định dạng 24 giờ: HH:MM:SS
   - Dữ liệu được sắp xếp theo ngày bay và mã chuyến bay
   ================================================================ */
SELECT
    lb.MaCB,
    lb.NgayBay,
    sb_di.TenSB AS SanBayDi,
    sb_den.TenSB AS SanBayDen,

    -- Hiển thị giờ theo định dạng 24 giờ, không có phần thập phân của giây
    CONVERT(VARCHAR(8), cb.GioDi, 108) AS GioDi,
    CONVERT(VARCHAR(8), cb.GioDen, 108) AS GioDen,

    CASE
        WHEN cb.GioDen > cb.GioDi THEN N'Cùng ngày'
        ELSE N'Qua đêm'
    END AS LoaiChuyen,

    lb.SoHieuMB
FROM LichBay lb
INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
INNER JOIN SanBay sb_di ON cb.SanBayDi = sb_di.MaSB
INNER JOIN SanBay sb_den ON cb.SanBayDen = sb_den.MaSB
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
   [R05] GET /api/reports/flights/stats?groupBy=airport|hour
   MÔ TẢ :
   - Thống kê tổng số chuyến bay theo sân bay hoặc theo giờ

   THAM SỐ:
   - @R05_GroupBy VARCHAR(20) : 'airport' hoặc 'hour'

   NGHIỆP VỤ:
   - Nếu @R05_GroupBy = 'airport' => thống kê theo sân bay đi
   - Nếu @R05_GroupBy = 'hour'    => thống kê theo giờ khởi hành
   - Dữ liệu được tính theo lịch bay thực tế (bảng LichBay)
   ================================================================ */
DECLARE @R05_GroupBy VARCHAR(20) = 'airport';  -- 'airport' hoặc 'hour'

IF @R05_GroupBy = 'airport'
BEGIN
    SELECT
        sb.TenSB,
        COUNT(*) AS TongLichBay
    FROM LichBay lb
    INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
    INNER JOIN SanBay sb ON cb.SanBayDi = sb.MaSB
    GROUP BY sb.TenSB
    ORDER BY TongLichBay DESC, sb.TenSB;
END
ELSE IF @R05_GroupBy = 'hour'
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
    RAISERROR(N'Giá trị @R05_GroupBy không hợp lệ. Chỉ chấp nhận: airport | hour', 16, 1);
END
GO


/* ================================================================
   [R06] GET /api/reports/bookings/count?period=monthly|yearly
   MÔ TẢ :
   - Thống kê tổng số đặt chỗ theo tháng hoặc theo năm

   THAM SỐ:
   - @R06_Period VARCHAR(20) : 'monthly' hoặc 'yearly'
   - @R06_Nam INT            : năm cần tra cứu khi thống kê theo tháng

   NGHIỆP VỤ:
   - Nếu @R06_Period = 'monthly' => thống kê tổng đặt chỗ theo từng tháng trong năm @R06_Nam
   - Nếu @R06_Period = 'yearly'  => thống kê tổng đặt chỗ theo từng năm
   - Có tách trạng thái: đã đặt, đã check-in, đã hủy
   ================================================================ */
DECLARE @R06_Period VARCHAR(20) = 'monthly';  -- 'monthly' hoặc 'yearly'
DECLARE @R06_Nam INT = 2025;

IF @R06_Period = 'monthly'
BEGIN
    SELECT
        @R06_Nam AS Nam,
        MONTH(dc.NgayDi) AS Thang,
        COUNT(*) AS TongDatCho,
        SUM(CASE WHEN dc.TrangThai = 1 THEN 1 ELSE 0 END) AS DaDat,
        SUM(CASE WHEN dc.TrangThai = 2 THEN 1 ELSE 0 END) AS DaCheckIn,
        SUM(CASE WHEN dc.TrangThai = 3 THEN 1 ELSE 0 END) AS DaHuy
    FROM DatCho dc
    WHERE YEAR(dc.NgayDi) = @R06_Nam
    GROUP BY MONTH(dc.NgayDi)
    ORDER BY Thang;
END
ELSE IF @R06_Period = 'yearly'
BEGIN
    SELECT
        YEAR(dc.NgayDi) AS Nam,
        COUNT(*) AS TongDatCho,
        SUM(CASE WHEN dc.TrangThai = 1 THEN 1 ELSE 0 END) AS DaDat,
        SUM(CASE WHEN dc.TrangThai = 2 THEN 1 ELSE 0 END) AS DaCheckIn,
        SUM(CASE WHEN dc.TrangThai = 3 THEN 1 ELSE 0 END) AS DaHuy
    FROM DatCho dc
    GROUP BY YEAR(dc.NgayDi)
    ORDER BY Nam;
END
ELSE
BEGIN
    RAISERROR(N'Giá trị @R06_Period không hợp lệ. Chỉ chấp nhận: monthly | yearly', 16, 1);
END
GO


/* ================================================================
   [R07] GET /api/reports/customers/top-flyers
   MÔ TẢ :
   - Lấy danh sách khách hàng có số chuyến bay nhiều nhất

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Chỉ tính booking chưa hủy (TrangThai <> 3)
   - Trả về tất cả khách hàng đồng hạng cao nhất
   - Dữ liệu được sắp xếp theo tên khách hàng
   ================================================================ */
WITH CTE_TopFlyers AS (
    SELECT
        MaKH,
        COUNT(*) AS SoChuyen
    FROM DatCho
    WHERE TrangThai <> 3
    GROUP BY MaKH
)
SELECT
    tf.MaKH,
    kh.TenKH,
    tf.SoChuyen
FROM CTE_TopFlyers tf
INNER JOIN KhachHang kh ON tf.MaKH = kh.MaKH
WHERE tf.SoChuyen = (
    SELECT MAX(SoChuyen)
    FROM CTE_TopFlyers
)
ORDER BY kh.TenKH;
GO


/* ================================================================
   [R08] GET /api/reports/flights/most-least-booked
   MÔ TẢ :
   - Lấy danh sách chuyến bay có nhiều khách đặt nhất và ít khách đặt nhất

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Chỉ tính booking chưa hủy (TrangThai <> 3)
   - Phần “ít nhất” chỉ xét các lịch bay có số khách > 0
   - Lịch bay 0 khách được xử lý riêng ở endpoint no-bookings
   ================================================================ */
WITH CTE_BookingCount AS (
    SELECT
        dc.MaCB,
        dc.NgayDi,
        COUNT(*) AS SoKH
    FROM DatCho dc
    WHERE dc.TrangThai <> 3
    GROUP BY dc.MaCB, dc.NgayDi
)
SELECT
    N'Nhiều nhất' AS Nhom,
    bc.MaCB,
    bc.NgayDi,
    bc.SoKH
FROM CTE_BookingCount bc
WHERE bc.SoKH = (
    SELECT MAX(SoKH)
    FROM CTE_BookingCount
)

UNION ALL

SELECT
    N'Ít nhất (>0)' AS Nhom,
    bc.MaCB,
    bc.NgayDi,
    bc.SoKH
FROM CTE_BookingCount bc
WHERE bc.SoKH = (
    SELECT MIN(SoKH)
    FROM CTE_BookingCount
    WHERE SoKH > 0
)
ORDER BY Nhom DESC, SoKH DESC, NgayDi, MaCB;
GO


/* ================================================================
   [R09] GET /api/flights/schedules/{MaCB}/{NgayBay}/passengers
   MÔ TẢ :
   - Lấy danh sách hành khách theo một lịch bay cụ thể

   THAM SỐ:
   - @R09_MaCB VARCHAR(10) : mã chuyến bay
   - @R09_NgayBay DATE     : ngày bay / ngày khởi hành

   NGHIỆP VỤ:
   - Chỉ hiển thị booking chưa hủy (TrangThai <> 3)
   - Dùng để tra cứu thông tin hành khách theo lịch bay
   - Dữ liệu được sắp xếp theo tên khách hàng
   ================================================================ */
DECLARE @R09_MaCB VARCHAR(10) = 'VN101';
DECLARE @R09_NgayBay DATE = '2025-05-01';

SELECT
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai,
    kh.DiaChi,
    dc.TrangThai
FROM DatCho dc
INNER JOIN KhachHang kh ON dc.MaKH = kh.MaKH
WHERE dc.MaCB = @R09_MaCB
  AND dc.NgayDi = @R09_NgayBay
  AND dc.TrangThai <> 3
ORDER BY kh.TenKH;
GO

-- ================================================================
-- END OF FILE: 09_Report_APIs.sql
-- ================================================================