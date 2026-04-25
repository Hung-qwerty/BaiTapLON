package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class TonKhoDAO {

    /** Danh sách tồn kho join với VatTu */
    public List<Map<String,String>> getAll() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT tk.MaKho, tk.MaVT, tk.SoLuong,"
                   + " vt.TenVT, vt.DonViTinh"
                   + " FROM TonKho tk"
                   + " LEFT JOIN VatTu vt ON tk.MaVT = vt.MaVT"
                   + " ORDER BY tk.MaKho, tk.MaVT";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maKho",     rs.getString("MaKho"));
                m.put("maVT",      rs.getString("MaVT"));
                m.put("tenVT",     nvl(rs.getString("TenVT"),     rs.getString("MaVT")));
                m.put("donViTinh", nvl(rs.getString("DonViTinh"), ""));
                double sl = rs.getDouble("SoLuong");
                m.put("soLuong",   formatSL(sl));
                // Ngưỡng tồn kho: <= 0 = Hết, < 20 = Thấp, >= 20 = Đủ
                m.put("trangThai", sl <= 0 ? "Hết" : sl < 20 ? "Thấp" : "Đủ");
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** Đếm số mặt hàng đang có tồn kho > 0 */
    public int countMatHang() {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT COUNT(*) FROM TonKho WHERE SoLuong > 0");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }

    /** Danh sách tất cả vật tư (để chọn khi tạo phiếu) */
    public List<Map<String,String>> getAllVatTu() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT MaVT, TenVT, DonViTinh"
                   + " FROM VatTu"
                   + " WHERE TrangThai = 1"
                   + " ORDER BY TenVT";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maVT",     rs.getString("MaVT"));
                m.put("tenVT",    rs.getString("TenVT"));
                m.put("donViTinh",nvl(rs.getString("DonViTinh"), ""));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── Helpers ─────────────────────────────────────────────────

    private String nvl(String val, String def) {
        return (val != null && !val.isEmpty()) ? val : def;
    }

    private String formatSL(double sl) {
        // Hiển thị số nguyên nếu không có phần thập phân
        return (sl == Math.floor(sl)) ? String.valueOf((long) sl) : String.valueOf(sl);
    }
}
