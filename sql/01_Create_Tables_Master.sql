/* ============================================================
   QUERY 01 · TẠO CÁC BẢNG DANH MỤC / GỐC
   Chức năng:
   - Tạo bảng SanBay
   - Tạo bảng MayBay
   - Tạo bảng KhachHang
   Lý do tách riêng:
   - Đây là các bảng cha, các bảng sau sẽ tham chiếu đến
   ============================================================ */

CREATE TABLE SanBay (
    MaSB        VARCHAR(10)     NOT NULL,
    TenSB       NVARCHAR(100)   NOT NULL,
    DiaDiem     NVARCHAR(200)   NOT NULL,

    CONSTRAINT PK_SanBay PRIMARY KEY (MaSB),
    CONSTRAINT CHK_SanBay_MaSB
        CHECK (MaSB = UPPER(MaSB))   -- Mã sân bay luôn viết hoa
);
GO

CREATE TABLE MayBay (
    SoHieuMB    VARCHAR(20)     NOT NULL,
    LoaiMayBay  NVARCHAR(50)    NOT NULL,
    SoGhe       INT             NOT NULL,

    CONSTRAINT PK_MayBay PRIMARY KEY (SoHieuMB),
    CONSTRAINT CHK_MayBay_SoGhe
        CHECK (SoGhe > 0 AND SoGhe <= 1000)
);
GO

CREATE TABLE KhachHang (
    MaKH        VARCHAR(15)     NOT NULL,
    TenKH       NVARCHAR(100)   NOT NULL,
    DiaChi      NVARCHAR(200)   NOT NULL,
    SoDienThoai VARCHAR(15)     NOT NULL,

    CONSTRAINT PK_KhachHang PRIMARY KEY (MaKH),

    -- Chỉ cho phép chữ số, khoảng trắng, dấu +, dấu -
    -- Độ dài từ 9 đến 15 ký tự
    CONSTRAINT CHK_KhachHang_SDT
        CHECK (
            LEN(SoDienThoai) BETWEEN 9 AND 15
            AND PATINDEX('%[^0-9 + -]%', SoDienThoai) = 0
        ),

    CONSTRAINT UQ_KhachHang_SDT
        UNIQUE (SoDienThoai)
);
GO