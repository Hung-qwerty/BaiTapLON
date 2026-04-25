package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class NhaCungCapDAO {
    public int countActive() {
        String sql = "SELECT COUNT(*) FROM NhaCungCap WHERE TrangThai=1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public List<Map<String,String>> getAll() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT * FROM NhaCungCap WHERE TrangThai=1 ORDER BY TenNCC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maNCC",  rs.getString("MaNCC"));
                m.put("tenNCC", rs.getString("TenNCC"));
                m.put("phone",  rs.getString("DienThoai") != null ? rs.getString("DienThoai") : "");
                m.put("email",  rs.getString("Email") != null ? rs.getString("Email") : "");
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}
