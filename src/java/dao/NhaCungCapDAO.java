package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class NhaCungCapDAO {

    public int countActive() {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(
                 "SELECT COUNT(*) FROM NhaCungCap WHERE TrangThai=1");
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
                m.put("email",  rs.getString("Email")     != null ? rs.getString("Email")     : "");
                m.put("diaChi", rs.getString("DiaChi")    != null ? rs.getString("DiaChi")    : "");
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(String tenNCC, String phone, String email, String diaChi) {
        String sql = "INSERT INTO NhaCungCap(MaNCC,TenNCC,DienThoai,Email,DiaChi,TrangThai) VALUES(?,?,?,?,?,1)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, nextId());
            ps.setString(2, tenNCC);
            ps.setString(3, phone);
            ps.setString(4, email);
            ps.setString(5, diaChi);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean delete(String maNCC) {
        // Soft delete
        String sql = "UPDATE NhaCungCap SET TrangThai=0 WHERE MaNCC=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, maNCC);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private String nextId() {
        String sql = "SELECT COUNT(*)+1 AS n FROM NhaCungCap";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return String.format("NCC%03d", rs.getInt("n"));
        } catch (SQLException e) { e.printStackTrace(); }
        return "NCC001";
    }
}
