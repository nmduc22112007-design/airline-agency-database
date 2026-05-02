/* ============================================================
   QUERY 03 · TẠO INDEX TỐI ƯU TRUY VẤN
   Chức năng:
   - Tạo index cho các cột được lọc / join / group thường xuyên
   ============================================================ */
   
USE AirlineAgency;
GO

CREATE INDEX IDX_LichBay_NgayBay
    ON LichBay (NgayBay);
GO

CREATE INDEX IDX_LichBay_SoHieuMB
    ON LichBay (SoHieuMB);
GO

CREATE INDEX IDX_ChuyenBay_SanBayDi
    ON ChuyenBay (SanBayDi);
GO

CREATE INDEX IDX_ChuyenBay_SanBayDen
    ON ChuyenBay (SanBayDen);
GO

CREATE INDEX IDX_ChuyenBay_GioDi
    ON ChuyenBay (GioDi);
GO

CREATE INDEX IDX_ChuyenBay_GioDen
    ON ChuyenBay (GioDen);
GO

CREATE INDEX IDX_DatCho_NgayDi
    ON DatCho (NgayDi);
GO

CREATE INDEX IDX_DatCho_MaKH
    ON DatCho (MaKH);
GO

CREATE INDEX IDX_DatCho_MaCB_NgayDi
    ON DatCho (MaCB, NgayDi);
GO

CREATE INDEX IDX_DatCho_TrangThai
    ON DatCho (TrangThai);
GO
