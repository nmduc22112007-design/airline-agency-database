-- ================================================================
-- FILE: 11_Views.sql
-- MÔ TẢ :
--   Định nghĩa các VIEW phục vụ truy vấn báo cáo và nghiệp vụ
--   cho hệ thống quản lý đặt vé máy bay.
--
-- MỤC ĐÍCH:
--   - Đáp ứng yêu cầu lập trình SQL (VIEW) của đề tài
--   - Gom các truy vấn JOIN phức tạp thành đối tượng dùng lại
--   - Hỗ trợ các file:
--       + 09_Report_APIs.sql
--       + 10_Business_Query.sql
--
-- ENGINE  : SQL Server 2022
-- GHI CHÚ :
--   - Các VIEW chỉ đọc dữ liệu, không thay đổi dữ liệu
--   - Chỉ tính booking còn hiệu lực (TrangThai <> 3) khi cần thiết
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   VIEW 01: Vw_LichBay_TongQuan
   MÔ TẢ :
   - Tổng hợp đầy đủ thông tin của một lịch bay

   NỘI DUNG:
   - Mã chuyến bay
   - Ngày bay
   - Sân bay đi / đến
   - Giờ đi / giờ đến
   - Máy bay sử dụng
   - Tổng số ghế

   MỤC ĐÍCH SỬ DỤNG:
   - Dùng cho báo cáo lịch bay
   - Dùng cho tra cứu nghiệp vụ
   ================================================================ */
CREATE OR ALTER VIEW Vw_LichBay_TongQuan
AS
SELECT
    lb.MaCB,
    lb.NgayBay,
    cb.SanBayDi,
    sb_di.TenSB AS TenSanBayDi,
    cb.SanBayDen,
    sb_den.TenSB AS TenSanBayDen,
    cb.GioDi,
    cb.GioDen,
    lb.SoHieuMB,
    mb.SoGhe
FROM LichBay lb
INNER JOIN ChuyenBay cb ON lb.MaCB = cb.MaCB
INNER JOIN SanBay sb_di ON cb.SanBayDi = sb_di.MaSB
INNER JOIN SanBay sb_den ON cb.SanBayDen = sb_den.MaSB
INNER JOIN MayBay mb ON lb.SoHieuMB = mb.SoHieuMB;
GO


/* ================================================================
   VIEW 02: Vw_DatCho_HieuLuc
   MÔ TẢ :
   - Danh sách các đặt chỗ còn hiệu lực

   NGHIỆP VỤ:
   - Chỉ lấy các booking chưa hủy (TrangThai <> 3)

   MỤC ĐÍCH SỬ DỤNG:
   - Dùng cho thống kê
   - Dùng cho báo cáo
   - Tránh lặp điều kiện TrangThai <> 3
   ================================================================ */
CREATE OR ALTER VIEW Vw_DatCho_HieuLuc
AS
SELECT
    dc.MaKH,
    dc.MaCB,
    dc.NgayDi,
    dc.TrangThai,
    dc.NgayDat
FROM DatCho dc
WHERE dc.TrangThai <> 3;
GO


/* ================================================================
   VIEW 03: Vw_ThongKe_ChuyenBay
   MÔ TẢ :
   - Thống kê số khách đã đặt và số chỗ còn trống theo lịch bay

   NGHIỆP VỤ:
   - Mỗi dòng tương ứng một lịch bay (MaCB + NgayBay)
   - Chỉ tính các booking còn hiệu lực

   MỤC ĐÍCH SỬ DỤNG:
   - Dùng cho báo cáo chuyến bay
   - Dùng cho thống kê tải chuyến
   ================================================================ */
CREATE OR ALTER VIEW Vw_ThongKe_ChuyenBay
AS
SELECT
    lb.MaCB,
    lb.NgayBay,
    lb.SoHieuMB,
    mb.SoGhe AS TongSoGhe,
    COUNT(dc.MaKH) AS SoKhachDaDat,
    mb.SoGhe - COUNT(dc.MaKH) AS SoChoConTrong
FROM LichBay lb
INNER JOIN MayBay mb ON lb.SoHieuMB = mb.SoHieuMB
LEFT JOIN DatCho dc
    ON dc.MaCB = lb.MaCB
   AND dc.NgayDi = lb.NgayBay
   AND dc.TrangThai <> 3
GROUP BY
    lb.MaCB,
    lb.NgayBay,
    lb.SoHieuMB,
    mb.SoGhe;
GO


/* ================================================================
   VIEW 04: Vw_KhachHang_TanSuatBay
   MÔ TẢ :
   - Thống kê số chuyến bay của mỗi khách hàng

   NGHIỆP VỤ:
   - Chỉ tính các booking chưa hủy
   - Mỗi dòng tương ứng một khách hàng

   MỤC ĐÍCH SỬ DỤNG:
   - Dùng cho báo cáo khách hàng thân thiết
   - Dùng cho truy vấn "khách hàng bay nhiều nhất"
   ================================================================ */
CREATE OR ALTER VIEW Vw_KhachHang_TanSuatBay
AS
SELECT
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai,
    COUNT(dc.MaCB) AS TongSoChuyenBay
FROM KhachHang kh
LEFT JOIN DatCho dc
    ON kh.MaKH = dc.MaKH
   AND dc.TrangThai <> 3
GROUP BY
    kh.MaKH,
    kh.TenKH,
    kh.SoDienThoai;
GO


/* ================================================================
   VIEW 05: Vw_ChuyenBay_KhongKhach
   MÔ TẢ :
   - Danh sách các lịch bay không có khách đặt chỗ

   NGHIỆP VỤ:
   - Nếu tất cả booking đều đã hủy thì vẫn xem là không có khách

   MỤC ĐÍCH SỬ DỤNG:
   - Dùng cho báo cáo chuyến bay không có khách
   ================================================================ */
CREATE OR ALTER VIEW Vw_ChuyenBay_KhongKhach
AS
SELECT
    lb.MaCB,
    lb.NgayBay,
    lb.SoHieuMB
FROM LichBay lb
WHERE NOT EXISTS (
    SELECT 1
    FROM DatCho dc
    WHERE dc.MaCB = lb.MaCB
      AND dc.NgayDi = lb.NgayBay
      AND dc.TrangThai <> 3
);
GO

-- ================================================================
-- END OF FILE: 11_Views.sql
-- ================================================================