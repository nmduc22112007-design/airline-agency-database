-- ================================================================
-- FILE: 15_Constraints_And_Integrity.sql
-- MÔ TẢ :
--   Định nghĩa các ràng buộc toàn vẹn (CHECK / UNIQUE)
--   cho hệ thống quản lý đặt vé máy bay.
--
-- MỤC ĐÍCH:
--   - Cưỡng chế luật nghiệp vụ ngay tại mức CSDL
--   - Giảm phụ thuộc vào trigger
--   - Tăng độ an toàn và tính chặt chẽ của dữ liệu
--
-- ENGINE  : SQL Server 2022
-- ================================================================

USE AirlineAgency;
GO

/* ================================================================
   RÀNG BUỘC 01: Trạng thái đặt chỗ hợp lệ
   ================================================================ */
ALTER TABLE DatCho
ADD CONSTRAINT CK_DatCho_TrangThai
CHECK (TrangThai IN (1, 2, 3));
GO


/* ================================================================
   RÀNG BUỘC 02: Không cho sân bay đi trùng sân bay đến
   ================================================================ */
ALTER TABLE ChuyenBay
ADD CONSTRAINT CK_ChuyenBay_SanBay
CHECK (SanBayDi <> SanBayDen);
GO


/* ================================================================
   RÀNG BUỘC 03: Giờ đi phải khác giờ đến
   ================================================================ */
ALTER TABLE ChuyenBay
ADD CONSTRAINT CK_ChuyenBay_Gio
CHECK (GioDi <> GioDen);
GO


/* ================================================================
   RÀNG BUỘC 04: Một khách hàng chỉ được đặt
   một chỗ cho một chuyến bay trong một ngày
   ================================================================ */
ALTER TABLE DatCho
ADD CONSTRAINT UQ_DatCho_KhachHang_ChuyenNgay
UNIQUE (MaKH, MaCB, NgayDi);
GO


/* ================================================================
   RÀNG BUỘC 05: Một chuyến bay chỉ có một lịch trong một ngày
   ================================================================ */
