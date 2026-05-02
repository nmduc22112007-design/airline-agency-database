/* ============================================================
   QUERY 02 · TẠO CÁC BẢNG NGHIỆP VỤ
   Chức năng:
   - Tạo bảng ChuyenBay
   - Tạo bảng LichBay
   - Tạo bảng DatCho
   Lý do tách riêng:
   - Có các khóa ngoại tham chiếu đến bảng gốc
   ============================================================ */

CREATE TABLE ChuyenBay (
    MaCB        VARCHAR(10)     NOT NULL,
    SanBayDi    VARCHAR(10)     NOT NULL,
    SanBayDen   VARCHAR(10)     NOT NULL,
    GioDi       TIME            NOT NULL,
    GioDen      TIME            NOT NULL,

    -- Khóa chính: mã chuyến bay là duy nhất
    CONSTRAINT PK_ChuyenBay PRIMARY KEY (MaCB),

    -- FK: sân bay đi phải tồn tại trong bảng SanBay
    CONSTRAINT FK_ChuyenBay_SanBayDi
        FOREIGN KEY (SanBayDi)
        REFERENCES SanBay(MaSB)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,

    -- FK: sân bay đến phải tồn tại trong bảng SanBay
    CONSTRAINT FK_ChuyenBay_SanBayDen
        FOREIGN KEY (SanBayDen)
        REFERENCES SanBay(MaSB)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,

    -- Ràng buộc nghiệp vụ:
    -- Sân bay đi và sân bay đến không được trùng nhau
    CONSTRAINT CHK_ChuyenBay_DiKhacDen
        CHECK (SanBayDi <> SanBayDen),

    -- Ràng buộc nghiệp vụ CASE 2:
    -- Có xét chuyến bay qua đêm
    -- Nếu GioDen > GioDi  => chuyến bay đến trong cùng ngày
    -- Nếu GioDen < GioDi  => chuyến bay đến vào ngày hôm sau
    -- Không cho phép GioDen = GioDi vì thời lượng bay bằng 0
    CONSTRAINT CHK_ChuyenBay_Gio
        CHECK (GioDi <> GioDen)
);
GO

CREATE TABLE LichBay (
    MaCB        VARCHAR(10)     NOT NULL,
    NgayBay     DATE            NOT NULL,
    SoHieuMB    VARCHAR(20)     NOT NULL,

    -- PK tổng hợp:
    -- Mỗi chuyến bay chỉ được xếp tối đa 1 lần trong 1 ngày
    CONSTRAINT PK_LichBay PRIMARY KEY (MaCB, NgayBay),

    -- FK: Lịch bay phải thuộc về một chuyến bay hợp lệ
    CONSTRAINT FK_LichBay_ChuyenBay
        FOREIGN KEY (MaCB)
        REFERENCES ChuyenBay(MaCB)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    -- FK: Mỗi lịch bay dùng một máy bay hợp lệ
    CONSTRAINT FK_LichBay_MayBay
        FOREIGN KEY (SoHieuMB)
        REFERENCES MayBay(SoHieuMB)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    -- Ràng buộc nghiệp vụ:
    -- Chỉ cho phép lịch bay từ năm 2020 trở đi
    CONSTRAINT CHK_LichBay_NgayBay
        CHECK (NgayBay >= '2020-01-01')
);
GO

CREATE TABLE DatCho (
    MaKH        VARCHAR(15)     NOT NULL,
    MaCB        VARCHAR(10)     NOT NULL,
    NgayDi      DATE            NOT NULL,
    TrangThai   TINYINT         NOT NULL DEFAULT 1,
    NgayDat     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- PK tổng hợp:
    -- Mỗi khách hàng chỉ được đặt tối đa 1 chỗ / chuyến bay / ngày đi
    CONSTRAINT PK_DatCho PRIMARY KEY (MaKH, MaCB, NgayDi),

    -- FK: Đặt chỗ phải thuộc về một khách hàng hợp lệ
    CONSTRAINT FK_DatCho_KhachHang
        FOREIGN KEY (MaKH)
        REFERENCES KhachHang(MaKH)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    -- FK tổng hợp:
    -- Mỗi đặt chỗ phải tham chiếu tới một lịch bay hợp lệ
    -- Lưu ý CASE 2:
    -- NgayDi là ngày KHỞI HÀNH, không phải ngày hạ cánh
    CONSTRAINT FK_DatCho_LichBay
        FOREIGN KEY (MaCB, NgayDi)
        REFERENCES LichBay(MaCB, NgayBay)
        ON UPDATE CASCADE
        ON DELETE NO ACTION,

    -- Ràng buộc nghiệp vụ:
    -- 1 = Đã đặt, 2 = Đã check-in, 3 = Đã hủy
    CONSTRAINT CHK_DatCho_TrangThai
        CHECK (TrangThai IN (1, 2, 3)),

    -- Ràng buộc nghiệp vụ:
    -- Ngày đặt không được sau ngày khởi hành
    -- Dù chuyến bay có qua đêm, NgayDi vẫn là ngày cất cánh
    CONSTRAINT CHK_DatCho_NgayDat
        CHECK (CAST(NgayDat AS DATE) <= NgayDi)
);
GO