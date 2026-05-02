/* ============================================================
   QUERY 00 · KHỞI TẠO DATABASE
   Chức năng:
   - Xóa database cũ nếu đã tồn tại
   - Tạo mới database AirlineAgency
   - Chuyển ngữ cảnh sang database mới
   ============================================================ */

USE master;
GO

IF DB_ID(N'AirlineAgency') IS NOT NULL
BEGIN
    ALTER DATABASE AirlineAgency SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AirlineAgency;
END
GO

CREATE DATABASE AirlineAgency;
GO

USE AirlineAgency;
GO
