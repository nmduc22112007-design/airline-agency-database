/* ============================================================
   QUERY 07 · KIỂM TRA SỐ LƯỢNG BẢN GHI
   Chức năng:
   - Kiểm tra nhanh dữ liệu đã được nạp đủ vào 6 bảng
   - Sau khi bổ sung CASE 2 (chuyến bay qua đêm):
     + SanBay     = 20
     + MayBay     = 20
     + ChuyenBay  = 25
     + KhachHang  = 20
     + LichBay    = 27
     + DatCho     = 32
   ============================================================ */

SELECT 'SanBay'     AS TenBang, COUNT(*) AS SoBanGhi FROM SanBay
UNION ALL
SELECT 'MayBay',    COUNT(*) FROM MayBay
UNION ALL
SELECT 'ChuyenBay', COUNT(*) FROM ChuyenBay
UNION ALL
SELECT 'KhachHang', COUNT(*) FROM KhachHang
UNION ALL
SELECT 'LichBay',   COUNT(*) FROM LichBay
UNION ALL
SELECT 'DatCho',    COUNT(*) FROM DatCho;
GO