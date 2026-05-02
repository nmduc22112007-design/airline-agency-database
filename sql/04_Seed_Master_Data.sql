/* ============================================================
   QUERY 04 · SEED DỮ LIỆU DANH MỤC / NỀN
   Chức năng:
   - Nạp dữ liệu cho SanBay
   - Nạp dữ liệu cho MayBay
   - Nạp dữ liệu cho KhachHang
   ============================================================ */

INSERT INTO SanBay (MaSB, TenSB, DiaDiem) VALUES
('SGN', N'Sân bay Quốc tế Tân Sơn Nhất',  N'Quận Tân Bình, TP. Hồ Chí Minh'),
('HAN', N'Sân bay Quốc tế Nội Bài',       N'Huyện Sóc Sơn, Hà Nội'),
('DAD', N'Sân bay Quốc tế Đà Nẵng',       N'Quận Hải Châu, Đà Nẵng'),
('CXR', N'Sân bay Quốc tế Cam Ranh', N'TP. Cam Ranh, Khánh Hòa'),
('HPH', N'Sân bay Quốc tế Cát Bi',        N'Quận Hải An, Hải Phòng'),
('HUI', N'Sân bay Quốc tế Phú Bài',       N'Thị xã Hương Thủy, Thừa Thiên Huế'),
('VCA', N'Sân bay Quốc tế Cần Thơ',       N'Quận Bình Thủy, TP. Cần Thơ'),
('PQC', N'Sân bay Quốc tế Phú Quốc',      N'Huyện Phú Quốc, Kiên Giang'),
('VII', N'Sân bay Vinh',                  N'TP. Vinh, Nghệ An'),
('DLI', N'Sân bay Liên Khương',           N'Huyện Đức Trọng, Lâm Đồng'),
('BMV', N'Sân bay Buôn Ma Thuột',         N'TP. Buôn Ma Thuột, Đắk Lắk'),
('VCL', N'Sân bay Chu Lai',               N'Huyện Núi Thành, Quảng Nam'),
('UIH', N'Sân bay Phù Cát',               N'Huyện Phù Cát, Bình Định'),
('TBB', N'Sân bay Tuy Hòa',               N'TP. Tuy Hòa, Phú Yên'),
('VKG', N'Sân bay Rạch Giá',              N'TP. Rạch Giá, Kiên Giang'),
('CAH', N'Sân bay Cà Mau',                N'TP. Cà Mau, Cà Mau'),
('DIN', N'Sân bay Điện Biên Phủ',         N'TP. Điện Biên Phủ, Điện Biên'),
('VDH', N'Sân bay Đồng Hới',              N'TP. Đồng Hới, Quảng Bình'),
('PXU', N'Sân bay Pleiku',                N'TP. Pleiku, Gia Lai'),
('THD', N'Sân bay Thọ Xuân',              N'Huyện Thọ Xuân, Thanh Hóa');
GO

INSERT INTO MayBay (SoHieuMB, LoaiMayBay, SoGhe) VALUES
('VN-A321-01', N'Airbus A321',    220),
('VN-A321-02', N'Airbus A321',    220),
('VN-A320-01', N'Airbus A320',    180),
('VN-A320-02', N'Airbus A320',    180),
('VN-B787-01', N'Boeing 787-9',   294),
('VN-B787-02', N'Boeing 787-9',   294),
('VJ-A320-01', N'Airbus A320',    180),
('VJ-A320-02', N'Airbus A320',    180),
('BL-A320-01', N'Airbus A320neo', 186),
('BL-A320-02', N'Airbus A320neo', 186),
('VN-A321-03', N'Airbus A321',    220),
('VN-A321-04', N'Airbus A321',    220),
('VN-A320-03', N'Airbus A320',    180),
('VN-A320-04', N'Airbus A320',    180),
('VN-B787-03', N'Boeing 787-9',   294),
('VN-A350-01', N'Airbus A350-900',305),
('VJ-A321-01', N'Airbus A321',    230),
('VJ-A321-02', N'Airbus A321',    230),
('QH-E190-01', N'Embraer E190',   100),
('VASCO-ATR72-01', N'ATR 72-500', 68);
GO

INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SoDienThoai) VALUES
('KH001', N'Nguyễn Văn An',      N'12 Lý Thường Kiệt, Hà Nội',              '0912345001'),
('KH002', N'Trần Thị Bình',      N'45 Nguyễn Huệ, TP. Hồ Chí Minh',         '0912345002'),
('KH003', N'Lê Hoàng Cường',     N'78 Trần Phú, Đà Nẵng',                   '0912345003'),
('KH004', N'Phạm Thị Dung',      N'23 Phan Đình Phùng, Huế',                '0912345004'),
('KH005', N'Hoàng Văn Em',       N'56 Lê Lợi, Nha Trang',                   '0912345005'),
('KH006', N'Vũ Thị Phương',      N'89 Hai Bà Trưng, Hải Phòng',             '0912345006'),
('KH007', N'Đặng Minh Giang',    N'34 Đinh Tiên Hoàng, Cần Thơ',            '0912345007'),
('KH008', N'Bùi Thị Hoa',        N'67 Nguyễn Đình Chiểu, Đà Lạt',           '0912345008'),
('KH009', N'Ngô Văn Hùng',       N'90 Trường Chinh, Pleiku',                '0912345009'),
('KH010', N'Dương Thị Lan',      N'11 Lê Duẩn, Buôn Ma Thuột',              '0912345010'),
('KH011', N'Trịnh Văn Mạnh',     N'44 Quang Trung, Vinh',                   '0912345011'),
('KH012', N'Nguyễn Thị Nga',     N'77 Hoàng Văn Thụ, Đồng Hới',             '0912345012'),
('KH013', N'Lý Hoàng Phúc',      N'22 Nguyễn Trãi, Tuy Hòa',                '0912345013'),
('KH014', N'Phan Thị Quỳnh',     N'55 Lý Tự Trọng, Quy Nhơn',               '0912345014'),
('KH015', N'Mai Văn Sơn',        N'88 Đinh Bộ Lĩnh, Rạch Giá',              '0912345015'),
('KH016', N'Cao Thị Thu',        N'33 Phan Chu Trinh, Cà Mau',              '0912345016'),
('KH017', N'Đinh Văn Tuấn',      N'66 Trần Hưng Đạo, Điện Biên Phủ',        '0912345017'),
('KH018', N'Lê Thị Uyên',        N'99 Nguyễn Công Trứ, Thanh Hóa',          '0912345018'),
('KH019', N'Phùng Văn Vinh',     N'15 Bà Triệu, Phú Quốc',                  '0912345019'),
('KH020', N'Tạ Thị Xuân',        N'48 Chu Văn An, Chu Lai',                 '0912345020');
GO