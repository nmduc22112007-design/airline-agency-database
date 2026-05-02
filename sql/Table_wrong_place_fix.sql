/* ================================================================
   XÓA CÁC BẢNG BỊ TẠO NHẦM TRONG DATABASE master
   Đề tài: Hệ thống quản lý đặt vé máy bay

   ENGINE  : SQL Server 2022

   MỤC ĐÍCH:
   - Xóa các bảng:
     + DatCho
     + LichBay
     + ChuyenBay
     + KhachHang
     + MayBay
     + SanBay

   GHI CHÚ:
   - Script này chỉ xóa các bảng trong database master
   - Script sẽ xóa khóa ngoại trước, sau đó mới xóa bảng
   - Không ảnh hưởng đến database AirlineAgency
   ================================================================ */

USE master;
GO

SET XACT_ABORT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    /* ============================================================
       BƯỚC 1: Khai báo danh sách bảng cần xóa
       ============================================================ */
    DECLARE @TargetTables TABLE (
        SchemaName SYSNAME,
        TableName  SYSNAME
    );

    INSERT INTO @TargetTables (SchemaName, TableName)
    VALUES
        (N'dbo', N'DatCho'),
        (N'dbo', N'LichBay'),
        (N'dbo', N'ChuyenBay'),
        (N'dbo', N'KhachHang'),
        (N'dbo', N'MayBay'),
        (N'dbo', N'SanBay');


    /* ============================================================
       BƯỚC 2: Xóa toàn bộ khóa ngoại liên quan đến các bảng này

       Lý do:
       - DatCho tham chiếu KhachHang, LichBay
       - LichBay tham chiếu ChuyenBay, MayBay
       - ChuyenBay tham chiếu SanBay
       - Nếu không xóa FK trước thì DROP TABLE có thể bị lỗi
       ============================================================ */
    DECLARE @SqlDropFK NVARCHAR(MAX) = N'';

    SELECT @SqlDropFK = @SqlDropFK +
        N'ALTER TABLE '
        + QUOTENAME(SCHEMA_NAME(tp.schema_id)) + N'.' + QUOTENAME(tp.name)
        + N' DROP CONSTRAINT ' + QUOTENAME(fk.name) + N';' + CHAR(13)
    FROM sys.foreign_keys fk
    INNER JOIN sys.tables tp
        ON fk.parent_object_id = tp.object_id
    INNER JOIN sys.tables tr
        ON fk.referenced_object_id = tr.object_id
    WHERE EXISTS (
        SELECT 1
        FROM @TargetTables t
        WHERE t.SchemaName = SCHEMA_NAME(tp.schema_id)
          AND t.TableName = tp.name
    )
    OR EXISTS (
        SELECT 1
        FROM @TargetTables t
        WHERE t.SchemaName = SCHEMA_NAME(tr.schema_id)
          AND t.TableName = tr.name
    );

    IF @SqlDropFK <> N''
    BEGIN
        PRINT N'Đang xóa các khóa ngoại liên quan...';
        EXEC sp_executesql @SqlDropFK;
    END
    ELSE
    BEGIN
        PRINT N'Không tìm thấy khóa ngoại cần xóa.';
    END


    /* ============================================================
       BƯỚC 3: Xóa bảng theo thứ tự an toàn

       Thứ tự:
       - Bảng con trước
       - Bảng cha sau
       ============================================================ */

    IF OBJECT_ID(N'dbo.DatCho', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.DatCho;
        PRINT N'Đã xóa bảng dbo.DatCho trong master.';
    END

    IF OBJECT_ID(N'dbo.LichBay', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.LichBay;
        PRINT N'Đã xóa bảng dbo.LichBay trong master.';
    END

    IF OBJECT_ID(N'dbo.ChuyenBay', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.ChuyenBay;
        PRINT N'Đã xóa bảng dbo.ChuyenBay trong master.';
    END

    IF OBJECT_ID(N'dbo.KhachHang', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.KhachHang;
        PRINT N'Đã xóa bảng dbo.KhachHang trong master.';
    END

    IF OBJECT_ID(N'dbo.MayBay', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.MayBay;
        PRINT N'Đã xóa bảng dbo.MayBay trong master.';
    END

    IF OBJECT_ID(N'dbo.SanBay', N'U') IS NOT NULL
    BEGIN
        DROP TABLE dbo.SanBay;
        PRINT N'Đã xóa bảng dbo.SanBay trong master.';
    END

    COMMIT TRANSACTION;

    PRINT N'Hoàn tất: Đã xóa các bảng của đề tài bị tạo nhầm trong master.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT N'Có lỗi xảy ra. Giao dịch đã được rollback.';

    SELECT
        ERROR_NUMBER() AS MaLoi,
        ERROR_MESSAGE() AS ThongBaoLoi,
        ERROR_LINE() AS DongLoi;
END CATCH;
GO
-----
USE master;
GO

SELECT
    TABLE_SCHEMA,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN (
      'SanBay',
      'MayBay',
      'KhachHang',
      'ChuyenBay',
      'LichBay',
      'DatCho'
  );
GO