-- ================================================================
-- FILE: 14_Triggers.sql
-- MÔ TẢ :
--   Định nghĩa các Trigger để cưỡng chế luật nghiệp vụ
--   cho hệ thống quản lý đặt vé máy bay.
--
-- MỤC ĐÍCH:
--   - Đáp ứng yêu cầu lập trình SQL (Trigger) của đề tài
--   - Đảm bảo toàn vẹn dữ liệu ở mức CSDL
--   - Ngăn chặn các thao tác vi phạm nghiệp vụ
--
-- ENGINE  : SQL Server 2022
-- GHI CHÚ :
--   - Trigger hoạt động tự động sau khi INSERT / UPDATE
--   - Nếu vi phạm luật nghiệp vụ thì hủy thao tác
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   TRIGGER 01: trg_DatCho_KhongTrung
   MÔ TẢ :
   - Không cho phép một khách hàng đặt trùng chỗ
     trên cùng một chuyến bay trong cùng một ngày

   LUẬT NGHIỆP VỤ:
   - (MaKH, MaCB, NgayDi) phải là duy nhất
   ================================================================ */
CREATE OR ALTER TRIGGER trg_DatCho_KhongTrung
ON DatCho
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM DatCho dc
        INNER JOIN inserted i
            ON dc.MaKH = i.MaKH
           AND dc.MaCB = i.MaCB
           AND dc.NgayDi = i.NgayDi
        WHERE dc.TrangThai <> 3
          AND dc.MaKH <> i.MaKH
    )
    BEGIN
        RAISERROR(
            N'Mỗi khách hàng chỉ được đặt một chỗ cho một chuyến bay trong một ngày.',
            16, 1
        );
        ROLLBACK TRANSACTION;
    END
END
GO


/* ================================================================
   TRIGGER 02: trg_DatCho_KhongVuotSoGhe
   MÔ TẢ :
   - Không cho phép đặt chỗ vượt quá số ghế của máy bay

   LUẬT NGHIỆP VỤ:
   - Tổng số booking hợp lệ không được vượt quá SoGhe
   ================================================================ */
CREATE OR ALTER TRIGGER trg_DatCho_KhongVuotSoGhe
ON DatCho
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN LichBay lb
            ON i.MaCB = lb.MaCB
           AND i.NgayDi = lb.NgayBay
        INNER JOIN MayBay mb
            ON lb.SoHieuMB = mb.SoHieuMB
        CROSS APPLY (
            SELECT COUNT(*) AS SoKhach
            FROM DatCho dc
            WHERE dc.MaCB = i.MaCB
              AND dc.NgayDi = i.NgayDi
              AND dc.TrangThai <> 3
        ) x
        WHERE x.SoKhach > mb.SoGhe
    )
    BEGIN
        RAISERROR(
            N'Số chỗ đặt vượt quá số ghế của máy bay.',
            16, 1
        );
        ROLLBACK TRANSACTION;
    END
END
GO


/* ================================================================
   TRIGGER 03: trg_LichBay_KhongTrungNgay
   MÔ TẢ :
   - Không cho phép một chuyến bay có nhiều lịch trong cùng một ngày

   LUẬT NGHIỆP VỤ:
   - Mỗi chuyến bay chỉ được bố trí tối đa một lần cho một ngày
   ================================================================ */
CREATE OR ALTER TRIGGER trg_LichBay_KhongTrungNgay
ON LichBay
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM LichBay lb
        INNER JOIN inserted i
            ON lb.MaCB = i.MaCB
           AND lb.NgayBay = i.NgayBay
        WHERE lb.MaCB <> i.MaCB
    )
    BEGIN
        RAISERROR(
            N'Mỗi chuyến bay chỉ được bố trí tối đa một lần trong một ngày.',
            16, 1
        );
        ROLLBACK TRANSACTION;
    END
END
GO

-- ================================================================
-- END OF FILE: 14_Triggers.sql
-- ================================================================