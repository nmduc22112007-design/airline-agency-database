-- ================================================================
-- QUERY 08: CRUD APIs
-- MÔ TẢ :
--   Các API CRUD theo đúng đề tài
--   (chạy sau file 07_Check_Data_Count.sql)
--
-- DANH SÁCH ENDPOINT:
--   [C01] GET  /api/airports
--   [C02] GET  /api/flights?dep={MaSB}&arr={MaSB}
--   [C03] GET  /api/flights/{MaCB}/schedules
--   [C04] POST /api/flights/schedules
--   [C05] PUT  /api/flights/schedules/{MaCB}/{NgayBay}
--   [C06] GET  /api/customers (phân trang)
--   [C07] POST /api/bookings
--   [C08] DEL  /api/bookings/{MaKH}/{MaCB}/{NgayDi}
--
-- ENGINE  : SQL Server 2022
-- VERSION : 2.0
-- GHI CHÚ :
--   - Áp dụng CASE 2: Có xét chuyến bay qua đêm
--   - Nếu Giờ đến > Giờ đi : đến cùng ngày
--   - Nếu Giờ đến < Giờ đi : đến ngày hôm sau
--   - Các cột thời gian khi hiển thị ra kết quả đều dùng định dạng 24 giờ: HH:MM:SS
--   - Không hiển thị phần thập phân của giây
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   [C01] GET /api/airports
   MÔ TẢ :
   - Lấy danh sách tất cả sân bay hiện có trong hệ thống

   THAM SỐ:
   - Không có

   NGHIỆP VỤ:
   - Trả về đầy đủ mã sân bay, tên sân bay và địa điểm
   - Dữ liệu được sắp xếp tăng dần theo mã sân bay
   ================================================================ */
SELECT
    MaSB    AS [MaSanBay],
    TenSB   AS [TenSanBay],
    DiaDiem AS [DiaDiem]
FROM SanBay
ORDER BY MaSB;
GO


/* ================================================================
   [C02] GET /api/flights?dep={MaSB}&arr={MaSB}
   MÔ TẢ :
   - Danh sách chuyến bay theo sân bay đi / sân bay đến

   THAM SỐ:
   - @Dep VARCHAR(10) = NULL  -> không lọc sân bay đi
   - @Arr VARCHAR(10) = NULL  -> không lọc sân bay đến

   NGHIỆP VỤ:
   - Có hỗ trợ chuyến bay qua đêm
   - Nếu Giờ đến < Giờ đi => chuyến bay hạ cánh vào ngày hôm sau
   - Các cột giờ được hiển thị theo định dạng 24 giờ: HH:MM:SS
   ================================================================ */
DECLARE @Dep VARCHAR(10) = 'SGN';   -- Đặt NULL nếu không lọc
DECLARE @Arr VARCHAR(10) = NULL;    -- Đặt NULL nếu không lọc

SELECT
    cb.MaCB AS [Mã Chuyến Bay],
    cb.SanBayDi AS [Mã SânBay Đi],
    sb_di.TenSB AS [Sân Bay Đi],
    cb.SanBayDen AS [Mã SânBay Đến],
    sb_den.TenSB AS [Sân Bay Đến],

    -- Hiển thị giờ theo định dạng 24 giờ, không có phần thập phân của giây
    CONVERT(VARCHAR(8), cb.GioDi, 108) AS [Giờ Đi],
    CONVERT(VARCHAR(8), cb.GioDen, 108) AS [Giờ Đến],

    CASE
        WHEN cb.GioDen > cb.GioDi THEN N'Cùng ngày'
        ELSE N'Qua đêm'
    END AS [Loại Chuyến],

    -- Tính thời gian bay theo phút, có xử lý trường hợp qua đêm
    CASE
        WHEN cb.GioDen > cb.GioDi THEN
            (
                DATEDIFF(SECOND, CAST('00:00:00' AS TIME), cb.GioDen)
                - DATEDIFF(SECOND, CAST('00:00:00' AS TIME), cb.GioDi)
            ) / 60
        ELSE
            (
                86400
                + DATEDIFF(SECOND, CAST('00:00:00' AS TIME), cb.GioDen)
                - DATEDIFF(SECOND, CAST('00:00:00' AS TIME), cb.GioDi)
            ) / 60
    END AS [Thời Gian Bay(Phút)]
FROM ChuyenBay cb
INNER JOIN SanBay sb_di  ON cb.SanBayDi  = sb_di.MaSB
INNER JOIN SanBay sb_den ON cb.SanBayDen = sb_den.MaSB
WHERE (@Dep IS NULL OR cb.SanBayDi = @Dep)
  AND (@Arr IS NULL OR cb.SanBayDen = @Arr)
ORDER BY cb.GioDi, cb.MaCB;
GO


/* ================================================================
   [C03] GET /api/flights/{MaCB}/schedules
   MÔ TẢ :
   - Lấy danh sách lịch bay theo mã chuyến bay cụ thể

   THAM SỐ:
   - @MaCB VARCHAR(10) : mã chuyến bay cần tra cứu

   NGHIỆP VỤ:
   - Trả về các ngày bay của chuyến bay đã chọn
   - Hiển thị máy bay được phân công cho từng lịch bay
   - Tính số chỗ đã đặt và số chỗ còn trống
   - Chỉ tính các booking chưa hủy (TrangThai <> 3)
   ================================================================ */
DECLARE @MaCB VARCHAR(10) = 'VN101';

SELECT
    lb.MaCB,
    lb.NgayBay,
    lb.SoHieuMB,
    mb.SoGhe,
    COUNT(dc.MaKH) AS SoChoDaDat,
    mb.SoGhe - COUNT(dc.MaKH) AS SoChoConTrong
FROM LichBay lb
JOIN MayBay mb ON lb.SoHieuMB = mb.SoHieuMB
LEFT JOIN DatCho dc
    ON dc.MaCB = lb.MaCB
   AND dc.NgayDi = lb.NgayBay
   AND dc.TrangThai <> 3
WHERE lb.MaCB = @MaCB
GROUP BY lb.MaCB, lb.NgayBay, lb.SoHieuMB, mb.SoGhe
ORDER BY lb.NgayBay;
GO


/* ================================================================
   [C04] POST /api/flights/schedules
   MÔ TẢ :
   - Thêm mới một lịch bay cho chuyến bay

   THAM SỐ:
   - @C04_MaCB VARCHAR(10)  : mã chuyến bay
   - @C04_NgayBay DATE      : ngày bay cần thêm
   - @C04_MB VARCHAR(20)    : số hiệu máy bay được phân công

   NGHIỆP VỤ:
   - Chuyến bay phải tồn tại trong bảng ChuyenBay
   - Máy bay phải tồn tại trong bảng MayBay
   - Không được tạo trùng lịch bay cho cùng một chuyến trong cùng một ngày
   - Nếu hợp lệ thì thêm bản ghi mới vào bảng LichBay
   ================================================================ */
DECLARE @C04_MaCB VARCHAR(10) = 'VN101';
DECLARE @C04_NgayBay DATE = '2025-07-01';
DECLARE @C04_MB VARCHAR(20) = 'VN-A321-01';

IF NOT EXISTS (SELECT 1 FROM ChuyenBay WHERE MaCB = @C04_MaCB)
    RAISERROR(N'Chuyến bay không tồn tại', 16, 1);
ELSE IF NOT EXISTS (SELECT 1 FROM MayBay WHERE SoHieuMB = @C04_MB)
    RAISERROR(N'Máy bay không tồn tại', 16, 1);
ELSE IF EXISTS (
    SELECT 1
    FROM LichBay
    WHERE MaCB = @C04_MaCB
      AND NgayBay = @C04_NgayBay
)
    RAISERROR(N'Chuyến bay đã có lịch trong ngày này', 16, 1);
ELSE
BEGIN
    INSERT INTO LichBay (MaCB, NgayBay, SoHieuMB)
    VALUES (@C04_MaCB, @C04_NgayBay, @C04_MB);

    SELECT @@ROWCOUNT AS SoDongAffected;
END
GO


/* ================================================================
   [C05] PUT /api/flights/schedules/{MaCB}/{NgayBay}
   MÔ TẢ :
   - Cập nhật máy bay cho một lịch bay đã tồn tại

   THAM SỐ:
   - @C05_MaCB VARCHAR(10)   : mã chuyến bay
   - @C05_NgayBay DATE       : ngày bay cần cập nhật
   - @C05_MB VARCHAR(20)     : số hiệu máy bay mới

   NGHIỆP VỤ:
   - Lịch bay phải tồn tại trước khi cập nhật
   - Nếu lịch bay tồn tại thì cập nhật lại số hiệu máy bay
   - Trả về số dòng bị ảnh hưởng sau khi cập nhật
   ================================================================ */
DECLARE @C05_MaCB VARCHAR(10) = 'VN101';
DECLARE @C05_NgayBay DATE = '2025-07-01';
DECLARE @C05_MB VARCHAR(20) = 'VN-A321-02';

IF NOT EXISTS (
    SELECT 1
    FROM LichBay
    WHERE MaCB = @C05_MaCB
      AND NgayBay = @C05_NgayBay
)
    RAISERROR(N'Lịch bay không tồn tại', 16, 1);
ELSE
BEGIN
    UPDATE LichBay
    SET SoHieuMB = @C05_MB
    WHERE MaCB = @C05_MaCB
      AND NgayBay = @C05_NgayBay;

    SELECT @@ROWCOUNT AS SoDongAffected;
END
GO


/* ================================================================
   [C06] GET /api/customers (Pagination)
   MÔ TẢ :
   - Lấy danh sách khách hàng có phân trang

   THAM SỐ:
   - @Page INT      : số trang hiện tại
   - @PageSize INT  : số dòng mỗi trang

   NGHIỆP VỤ:
   - Trả về thông tin khách hàng kèm tổng số dòng
   - Dữ liệu được sắp xếp theo tên khách hàng
   - Áp dụng OFFSET / FETCH để phân trang theo chuẩn SQL Server
   ================================================================ */
DECLARE @Page INT = 1;
DECLARE @PageSize INT = 10;

SELECT
    MaKH,
    TenKH,
    DiaChi,
    SoDienThoai,
    COUNT(*) OVER() AS TotalRows
FROM KhachHang
ORDER BY TenKH
OFFSET (@Page - 1) * @PageSize ROWS
FETCH NEXT @PageSize ROWS ONLY;
GO


/* ================================================================
   [C07] POST /api/bookings
   MÔ TẢ :
   - Tạo mới một booking đặt chỗ cho khách hàng

   THAM SỐ:
   - @B_MaKH VARCHAR(15) : mã khách hàng
   - @B_MaCB VARCHAR(10) : mã chuyến bay
   - @B_Ngay DATE        : ngày đi / ngày khởi hành

   NGHIỆP VỤ:
   - Không cho phép tạo trùng khóa chính (MaKH, MaCB, NgayDi)
   - Nếu chưa tồn tại thì thêm mới booking với trạng thái mặc định là 1
   - Trả về số dòng bị ảnh hưởng
   ================================================================ */
DECLARE @B_MaKH VARCHAR(15) = 'KH005';
DECLARE @B_MaCB VARCHAR(10) = 'VN101';
DECLARE @B_Ngay DATE = '2025-06-01';

IF EXISTS (
    SELECT 1
    FROM DatCho
    WHERE MaKH = @B_MaKH
      AND MaCB = @B_MaCB
      AND NgayDi = @B_Ngay
)
    RAISERROR(N'Đặt chỗ đã tồn tại (PK)', 16, 1);
ELSE
BEGIN
    INSERT INTO DatCho (MaKH, MaCB, NgayDi, TrangThai)
    VALUES (@B_MaKH, @B_MaCB, @B_Ngay, 1);

    SELECT @@ROWCOUNT AS SoDongAffected;
END
GO


/* ================================================================
   [C08] DELETE /api/bookings/{MaKH}/{MaCB}/{NgayDi}
   MÔ TẢ :
   - Hủy booking đặt chỗ theo khóa chính

   THAM SỐ:
   - @D_MaKH VARCHAR(15) : mã khách hàng
   - @D_MaCB VARCHAR(10) : mã chuyến bay
   - @D_Ngay DATE        : ngày đi / ngày khởi hành

   NGHIỆP VỤ:
   - Thao tác hủy được thực hiện bằng cách cập nhật TrangThai = 3
   - Không hủy booking đã check-in (TrangThai = 2)
   - Trả về số dòng bị ảnh hưởng sau khi cập nhật
   ================================================================ */
DECLARE @D_MaKH VARCHAR(15) = 'KH005';
DECLARE @D_MaCB VARCHAR(10) = 'VN101';
DECLARE @D_Ngay DATE = '2025-06-01';

UPDATE DatCho
SET TrangThai = 3
WHERE MaKH = @D_MaKH
  AND MaCB = @D_MaCB
  AND NgayDi = @D_Ngay
  AND TrangThai <> 2;

SELECT @@ROWCOUNT AS SoDongAffected;
GO

-- ================================================================
-- END OF FILE: 08_CRUD_APIs.sql
-- ================================================================