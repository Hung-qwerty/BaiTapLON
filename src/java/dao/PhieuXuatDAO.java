package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class PhieuXuatDAO {

    public List<Map<String,String>> getAll() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT px.MaXK, px.MaKho, px.MaPX, px.NgayXuat, px.TrangThai, px.GhiChu,"
                   + " pxuong.TenPX"
                   + " FROM PhieuXuatKho px"
                   + " LEFT JOIN PhanXuong pxuong ON px.MaPX = pxuong.MaPX"
                   + " ORDER BY px.NgayXuat DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maXK",         rs.getString("MaXK"));
                m.put("maKho",        nvl(rs.getString("MaKho"),    ""));
                m.put("maPX",         nvl(rs.getString("MaPX"),     ""));
                m.put("tenPX",        nvl(rs.getString("TenPX"),    rs.getString("MaPX")));
                m.put("ngayXuat",     date10(rs.getString("NgayXuat")));
                m.put("trangThaiRaw", nvl(rs.getString("TrangThai"),""));
                m.put("trangThai",    labelXuat(rs.getString("TrangThai")));
                m.put("ghiChu",       nvl(rs.getString("GhiChu"),   ""));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Map<String,String> getById(String maXK) {
        String sql = "SELECT px.*, pxuong.TenPX, tk.HoTen AS TenNguoiXuat"
                   + " FROM PhieuXuatKho px"
                   + " LEFT JOIN PhanXuong pxuong ON px.MaPX      = pxuong.MaPX"
                   + " LEFT JOIN TaiKhoan  tk     ON px.NguoiXuat = tk.MaTK"
                   + " WHERE px.MaXK = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, maXK);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maXK",         rs.getString("MaXK"));
                m.put("maKho",        nvl(rs.getString("MaKho"),         ""));
                m.put("maPX",         nvl(rs.getString("MaPX"),          ""));
                m.put("tenPX",        nvl(rs.getString("TenPX"),         rs.getString("MaPX")));
                m.put("ngayXuat",     date10(rs.getString("NgayXuat")));
                m.put("trangThaiRaw", nvl(rs.getString("TrangThai"),     ""));
                m.put("trangThai",    labelXuat(rs.getString("TrangThai")));
                m.put("nguoiXuat",    nvl(rs.getString("TenNguoiXuat"),  rs.getString("NguoiXuat")));
                m.put("ghiChu",       nvl(rs.getString("GhiChu"),        ""));
                return m;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Map<String,String>> getChiTiet(String maXK) {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT ct.MaVT, ct.SoLuong, vt.TenVT, vt.DonViTinh"
                   + " FROM ChiTietXuatKho ct"
                   + " LEFT JOIN VatTu vt ON ct.MaVT = vt.MaVT"
                   + " WHERE ct.MaXK = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, maXK);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maVT",      rs.getString("MaVT"));
                m.put("tenVT",     nvl(rs.getString("TenVT"),     rs.getString("MaVT")));
                m.put("donViTinh", nvl(rs.getString("DonViTinh"), ""));
                m.put("soLuong",   rs.getString("SoLuong"));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Tạo phiếu xuất + trừ tồn kho trong 1 transaction.
     * Kiểm tra tồn kho đủ trước khi trừ.
     */
    public void insert(String maKho, String maPX, String ghiChu, String nguoiXuat,
                       String[] maVTs, String[] soLuongs) throws SQLException {

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Sinh mã phiếu
                String maXK = nextId(c, "PhieuXuatKho", "XK");

                // 2. Insert phiếu xuất
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO PhieuXuatKho(MaXK,MaKho,MaPX,NguoiXuat,TrangThai,GhiChu)"
                        + " VALUES(?,?,?,?,'DA_XUAT',?)")) {
                    ps.setString(1, maXK);
                    ps.setString(2, maKho);
                    ps.setString(3, maPX);
                    ps.setString(4, nguoiXuat);
                    ps.setString(5, ghiChu);
                    ps.executeUpdate();
                }

                // 3. Insert từng dòng vật tư + trừ tồn kho
                if (maVTs != null) {
                    for (int i = 0; i < maVTs.length; i++) {
                        if (maVTs[i] == null || maVTs[i].trim().isEmpty()) continue;
                        double sl = parseDouble(soLuongs, i);
                        if (sl <= 0) continue;

                        String maVT = maVTs[i].trim();

                        // Kiểm tra tồn kho
                        double tonHienTai = 0;
                        try (PreparedStatement ps = c.prepareStatement(
                                "SELECT SoLuong FROM TonKho WHERE MaKho=? AND MaVT=?")) {
                            ps.setString(1, maKho);
                            ps.setString(2, maVT);
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) tonHienTai = rs.getDouble(1);
                        }
                        if (tonHienTai < sl) {
                            c.rollback();
                            throw new SQLException(
                                "Tồn kho vật tư [" + maVT + "] không đủ!"
                                + " Cần: " + sl + ", Hiện có: " + tonHienTai);
                        }

                        // Insert ChiTietXuatKho
                        try (PreparedStatement ps = c.prepareStatement(
                                "INSERT INTO ChiTietXuatKho(MaXK,MaVT,SoLuong) VALUES(?,?,?)")) {
                            ps.setString(1, maXK);
                            ps.setString(2, maVT);
                            ps.setDouble(3, sl);
                            ps.executeUpdate();
                        }

                        // Trừ TonKho
                        try (PreparedStatement ps = c.prepareStatement(
                                "UPDATE TonKho SET SoLuong = SoLuong - ?"
                                + " WHERE MaKho=? AND MaVT=?")) {
                            ps.setDouble(1, sl);
                            ps.setString(2, maKho);
                            ps.setString(3, maVT);
                            ps.executeUpdate();
                        }
                    }
                }

                c.commit();

            } catch (SQLException e) {
                c.rollback();
                throw e;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    /** Xử lý lệnh xuất — gọi insert với ghi chú kèm mã lệnh */
    public void xuLyLenh(String maLenh, String maKho, String maPX,
                         String nguoiXuat, String[] maVTs, String[] soLuongs)
            throws SQLException {
        insert(maKho, maPX, "Xử lý lệnh xuất " + maLenh, nguoiXuat, maVTs, soLuongs);
    }

    public int countHomNay() {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT COUNT(*) FROM PhieuXuatKho WHERE DATE(NgayXuat)=CURDATE()");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }

    // ── Helpers ─────────────────────────────────────────────────

    private String nextId(Connection c, String table, String prefix) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*)+1 AS n FROM " + table);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? String.format("%s%03d", prefix, rs.getInt("n")) : prefix + "001";
        }
    }

    private String labelXuat(String raw) {
        if (raw == null) return "";
        switch (raw) {
            case "DA_XUAT":  return "Đã xuất";
            case "CHO_XUAT": return "Chờ xuất";
            case "HUY":      return "Hủy";
            default:         return raw;
        }
    }

    private String nvl(String val, String def) { return (val != null && !val.isEmpty()) ? val : def; }

    private String date10(String dt) { return (dt != null && dt.length() >= 10) ? dt.substring(0,10) : ""; }

    private double parseDouble(String[] arr, int i) {
        try { return (arr != null && i < arr.length) ? Double.parseDouble(arr[i]) : 0; }
        catch (NumberFormatException e) { return 0; }
    }
}
