package dao;

import model.TaiKhoan;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaiKhoanDAO {

    public TaiKhoan login(String tenDangNhap, String matKhau) {
        String sql = "SELECT * FROM TaiKhoan WHERE TenDangNhap=? AND MatKhau=? AND TrangThai=1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tenDangNhap);
            ps.setString(2, matKhau);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<TaiKhoan> getAll() {
        List<TaiKhoan> list = new ArrayList<>();
        String sql = "SELECT * FROM TaiKhoan ORDER BY MaTK";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(TaiKhoan tk) {
        String sql = "INSERT INTO TaiKhoan(MaTK,TenDangNhap,MatKhau,HoTen,VaiTro,MaKho,MaPhanXuong) VALUES(?,?,?,?,?,?,?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateId());
            ps.setString(2, tk.getTenDangNhap());
            ps.setString(3, tk.getMatKhau());
            ps.setString(4, tk.getHoTen());
            ps.setString(5, tk.getVaiTro());
            ps.setString(6, tk.getMaKho());
            ps.setString(7, tk.getMaPhanXuong());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean update(TaiKhoan tk) {
        String sql = "UPDATE TaiKhoan SET TenDangNhap=?,MatKhau=?,HoTen=?,VaiTro=?,TrangThai=? WHERE MaTK=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tk.getTenDangNhap());
            ps.setString(2, tk.getMatKhau());
            ps.setString(3, tk.getHoTen());
            ps.setString(4, tk.getVaiTro());
            ps.setInt(5, tk.getTrangThai());
            ps.setString(6, tk.getMaTK());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean delete(String maTK) {
        String sql = "UPDATE TaiKhoan SET TrangThai=0 WHERE MaTK=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maTK);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public TaiKhoan getById(String maTK) {
        String sql = "SELECT * FROM TaiKhoan WHERE MaTK=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maTK);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    private String generateId() {
        String sql = "SELECT MAX(CAST(SUBSTRING(MaTK,3) AS UNSIGNED)) AS maxNum FROM TaiKhoan";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int next = rs.getInt("maxNum") + 1;
                return String.format("TK%03d", next);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return "TK001";
    }

    private TaiKhoan mapRow(ResultSet rs) throws SQLException {
        TaiKhoan tk = new TaiKhoan();
        tk.setMaTK(rs.getString("MaTK"));
        tk.setTenDangNhap(rs.getString("TenDangNhap"));
        tk.setMatKhau(rs.getString("MatKhau"));
        tk.setHoTen(rs.getString("HoTen"));
        tk.setVaiTro(rs.getString("VaiTro"));
        tk.setMaKho(rs.getString("MaKho"));
        tk.setMaPhanXuong(rs.getString("MaPhanXuong"));
        tk.setTrangThai(rs.getInt("TrangThai"));
        return tk;
    }
}
