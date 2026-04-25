package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class QuanLyDAO {

    // ── TỔNG QUAN ────────────────────────────────────────────────

    /** Tổng giá trị đơn hàng tất cả thời gian */
    public double tongDoanhThu() {
        return queryDouble(
            "SELECT IFNULL(SUM(ct.SoLuong * ct.DonGia), 0) FROM ChiTietDonHang ct");
    }

    /** Tổng số mặt hàng đang quản lý */
    public int tongMatHang() {
        return queryInt("SELECT COUNT(*) FROM VatTu WHERE TrangThai = 1");
    }

    /** Số bộ phận (vai trò khác nhau, trừ ADMIN) */
    public int soBoPhan() {
        return queryInt(
            "SELECT COUNT(DISTINCT VaiTro) FROM TaiKhoan WHERE VaiTro != 'ADMIN' AND TrangThai = 1");
    }

    /** Tổng nhân viên đang hoạt động */
    public int tongNhanVien() {
        return queryInt(
            "SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro != 'ADMIN' AND TrangThai = 1");
    }

    /**
     * Doanh thu theo tháng trong năm hiện tại (cho biểu đồ cột).
     * Trả về Map: tháng (1-12) → tổng giá trị
     */
    public Map<Integer,Double> doanhThuTheoThang() {
        Map<Integer,Double> map = new LinkedHashMap<>();
        for (int i = 1; i <= 6; i++) map.put(i, 0.0); // khởi tạo 6 tháng
        String sql = "SELECT MONTH(dh.NgayTao) AS thang,"
                   + " IFNULL(SUM(ct.SoLuong * ct.DonGia), 0) AS tongTien"
                   + " FROM DonHang dh"
                   + " LEFT JOIN ChiTietDonHang ct ON dh.MaDH = ct.MaDH"
                   + " WHERE YEAR(dh.NgayTao) = YEAR(NOW()) AND MONTH(dh.NgayTao) <= 6"
                   + " GROUP BY MONTH(dh.NgayTao)"
                   + " ORDER BY thang";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("thang"), rs.getDouble("tongTien"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    /**
     * Giá trị tồn kho theo tháng (6 tháng gần nhất từ PhieuNhapKho).
     * Dùng ngày nhập làm mốc thời gian.
     */
    public Map<Integer,Double> tonKhoTheoThang() {
        Map<Integer,Double> map = new LinkedHashMap<>();
        for (int i = 1; i <= 6; i++) map.put(i, 0.0);
        String sql = "SELECT MONTH(pn.NgayNhap) AS thang,"
                   + " IFNULL(SUM(ct.SoLuongNhan), 0) AS tongNhap"
                   + " FROM PhieuNhapKho pn"
                   + " LEFT JOIN ChiTietNhapKho ct ON pn.MaNK = ct.MaNK"
                   + " WHERE YEAR(pn.NgayNhap) = YEAR(NOW()) AND MONTH(pn.NgayNhap) <= 6"
                   + " GROUP BY MONTH(pn.NgayNhap)"
                   + " ORDER BY thang";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getInt("thang"), rs.getDouble("tongNhap"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    // ── BỘ PHẬN ──────────────────────────────────────────────────

    /**
     * Hiệu suất từng bộ phận: đếm nhân sự, đơn hàng/phiếu liên quan.
     */
    public List<Map<String,Object>> hieuSuatBoPhan() {
        List<Map<String,Object>> list = new ArrayList<>();

        // Mua hàng
        list.add(boPhan("Mua hàng", "MUA_HANG",
            queryInt("SELECT COUNT(*) FROM DonHang"),
            queryInt("SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro='MUA_HANG' AND TrangThai=1")));

        // Kho
        list.add(boPhan("Kho", "KHO",
            queryInt("SELECT COUNT(*) FROM PhieuNhapKho") + queryInt("SELECT COUNT(*) FROM PhieuXuatKho"),
            queryInt("SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro='KHO' AND TrangThai=1")));

        // Đối chiếu
        list.add(boPhan("Đối chiếu", "DOI_CHIEU",
            queryInt("SELECT COUNT(*) FROM PhieuDoiChieu"),
            queryInt("SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro='DOI_CHIEU' AND TrangThai=1")));

        // Tài vụ
        list.add(boPhan("Tài vụ", "TAI_VU",
            queryInt("SELECT COUNT(*) FROM ThanhToan"),
            queryInt("SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro='TAI_VU' AND TrangThai=1")));

        // Phân xưởng
        list.add(boPhan("Phân xưởng", "PHAN_XUONG",
            queryInt("SELECT COUNT(*) FROM PhieuDuTru"),
            queryInt("SELECT COUNT(*) FROM TaiKhoan WHERE VaiTro='PHAN_XUONG' AND TrangThai=1")));

        return list;
    }

    // ── THÔNG BÁO ────────────────────────────────────────────────

    /** Vật tư dưới mức tồn kho tối thiểu (< 20) */
    public int soMatHangThieu() {
        return queryInt("SELECT COUNT(*) FROM TonKho WHERE SoLuong < 20 AND SoLuong > 0");
    }

    /** Số đơn hàng đang chờ duyệt */
    public int soDonChoDuyet() {
        return queryInt("SELECT COUNT(*) FROM DonHang WHERE TrangThai = 'MOI'");
    }

    /** Số phiếu nhập có sai lệch */
    public int soPhieuSaiLech() {
        return queryInt("SELECT COUNT(*) FROM PhieuNhapKho WHERE TrangThai = 'SAI_LECH'");
    }

    /** Danh sách thông báo động từ DB */
    public List<Map<String,String>> danhSachThongBao() {
        List<Map<String,String>> list = new ArrayList<>();

        // Cảnh báo tồn kho thấp
        int thieu = soMatHangThieu();
        if (thieu > 0) {
            Map<String,String> m = new LinkedHashMap<>();
            m.put("loai",  "warn");
            m.put("icon",  "⚠️");
            m.put("msg",   thieu + " mặt hàng dưới mức tồn kho tối thiểu");
            m.put("time",  "Vừa cập nhật");
            list.add(m);
        }

        // Đơn hàng chờ duyệt
        int choDuyet = soDonChoDuyet();
        if (choDuyet > 0) {
            Map<String,String> m = new LinkedHashMap<>();
            m.put("loai",  "info");
            m.put("icon",  "ℹ️");
            m.put("msg",   choDuyet + " đơn hàng đang chờ duyệt");
            m.put("time",  "Hôm nay");
            list.add(m);
        }

        // Phiếu nhập sai lệch
        int saiLech = soPhieuSaiLech();
        if (saiLech > 0) {
            Map<String,String> m = new LinkedHashMap<>();
            m.put("loai",  "err");
            m.put("icon",  "❌");
            m.put("msg",   saiLech + " phiếu nhập kho có sai lệch cần xử lý");
            m.put("time",  "Cần xử lý");
            list.add(m);
        }

        // Lấy lịch sử hoạt động gần nhất
        String sql = "SELECT HanhDong, ThoiGian, tk.HoTen"
                   + " FROM LichSuHoatDong ls"
                   + " LEFT JOIN TaiKhoan tk ON ls.MaTK = tk.MaTK"
                   + " ORDER BY ThoiGian DESC LIMIT 3";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("loai",  "ok");
                m.put("icon",  "✅");
                m.put("msg",   rs.getString("HoTen") + ": " + rs.getString("HanhDong"));
                String tg = rs.getString("ThoiGian");
                m.put("time",  tg != null && tg.length() >= 10 ? tg.substring(0, 10) : "");
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }

        // Nếu không có gì
        if (list.isEmpty()) {
            Map<String,String> m = new LinkedHashMap<>();
            m.put("loai", "ok");
            m.put("icon", "✅");
            m.put("msg",  "Hệ thống đang hoạt động bình thường");
            m.put("time", "Hôm nay");
            list.add(m);
        }

        return list;
    }

    // ── BÁO CÁO ──────────────────────────────────────────────────

    /** Tổng giá trị tồn kho hiện tại */
    public double giaTriTonKho() {
        // Tính dựa trên số lượng tồn * đơn giá trung bình từ ChiTietDonHang
        String sql = "SELECT IFNULL(SUM(tk.SoLuong * IFNULL(avg_price.DonGia, 0)), 0)"
                   + " FROM TonKho tk"
                   + " LEFT JOIN ("
                   + "   SELECT MaVT, AVG(DonGia) AS DonGia"
                   + "   FROM ChiTietDonHang GROUP BY MaVT"
                   + " ) avg_price ON tk.MaVT = avg_price.MaVT";
        return queryDouble(sql);
    }

    /** Tổng tiền đã thanh toán */
    public double tongThanhToan() {
        return queryDouble("SELECT IFNULL(SUM(SoTien), 0) FROM ThanhToan");
    }

    /** Số hóa đơn chưa thanh toán */
    public int soHoaDonChuaTT() {
        return queryInt(
            "SELECT COUNT(*) FROM HoaDonNCC WHERE TrangThaiTT != 'DA_THANH_TOAN'");
    }

    // ── Helpers ──────────────────────────────────────────────────

    private Map<String,Object> boPhan(String ten, String vaiTro, int congViec, int nhanSu) {
        Map<String,Object> m = new LinkedHashMap<>();
        m.put("ten",      ten);
        m.put("vaiTro",   vaiTro);
        m.put("nhanSu",   nhanSu);
        m.put("congViec", congViec);
        // Tính hiệu suất đơn giản: có công việc > 0 thì 85-96%, không có thì 0%
        int hs = congViec > 0 ? Math.min(95, 80 + (nhanSu * 2)) : 0;
        m.put("hieuSuat", hs);
        m.put("trangThai", hs >= 90 ? "Tốt" : hs >= 70 ? "Trung bình" : "Cần cải thiện");
        return m;
    }

    private int queryInt(String sql) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }

    private double queryDouble(String sql) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getDouble(1) : 0.0;
        } catch (SQLException e) { e.printStackTrace(); return 0.0; }
    }
}
