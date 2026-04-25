package dao;

import model.DonHang;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DonHangDAO {

    public List<DonHang> getAll() {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT dh.*, ncc.TenNCC, " +
                     "(SELECT COUNT(*) FROM ChiTietDonHang ct WHERE ct.MaDH=dh.MaDH) AS SoMatHang, " +
                     "(SELECT IFNULL(SUM(ct.SoLuong*ct.DonGia),0) FROM ChiTietDonHang ct WHERE ct.MaDH=dh.MaDH) AS TongTien " +
                     "FROM DonHang dh " +
                     "LEFT JOIN NhaCungCap ncc ON dh.MaNCC=ncc.MaNCC " +
                     "ORDER BY dh.NgayTao DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<DonHang> getByNguoiTao(String maTK) {
        List<DonHang> list = new ArrayList<>();
        String sql = "SELECT dh.*, ncc.TenNCC, " +
                     "(SELECT COUNT(*) FROM ChiTietDonHang ct WHERE ct.MaDH=dh.MaDH) AS SoMatHang, " +
                     "(SELECT IFNULL(SUM(ct.SoLuong*ct.DonGia),0) FROM ChiTietDonHang ct WHERE ct.MaDH=dh.MaDH) AS TongTien " +
                     "FROM DonHang dh " +
                     "LEFT JOIN NhaCungCap ncc ON dh.MaNCC=ncc.MaNCC " +
                     "WHERE dh.NguoiTao=? ORDER BY dh.NgayTao DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maTK);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public int countThang() {
        String sql = "SELECT COUNT(*) FROM DonHang WHERE MONTH(NgayTao)=MONTH(NOW()) AND YEAR(NgayTao)=YEAR(NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countByTrangThai(String trangThai) {
        String sql = "SELECT COUNT(*) FROM DonHang WHERE TrangThai=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public double tongGiaTriThang() {
        String sql = "SELECT IFNULL(SUM(ct.SoLuong*ct.DonGia),0) " +
                     "FROM ChiTietDonHang ct JOIN DonHang dh ON ct.MaDH=dh.MaDH " +
                     "WHERE MONTH(dh.NgayTao)=MONTH(NOW()) AND YEAR(dh.NgayTao)=YEAR(NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public boolean insert(DonHang dh) {
        String sql = "INSERT INTO DonHang(MaDH,MaNCC,NguoiTao,TrangThai,GhiChu) VALUES(?,?,?,'MOI',?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, generateId());
            ps.setString(2, dh.getMaNCC());
            ps.setString(3, dh.getNguoiTao());
            ps.setString(4, dh.getGhiChu());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    private String generateId() {
        String sql = "SELECT COUNT(*)+1 AS next FROM DonHang";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return String.format("PO-%03d", rs.getInt("next"));
        } catch (SQLException e) { e.printStackTrace(); }
        return "PO-001";
    }

    private DonHang mapRow(ResultSet rs) throws SQLException {
        DonHang dh = new DonHang();
        dh.setMaDH(rs.getString("MaDH"));
        dh.setMaNCC(rs.getString("MaNCC"));
        dh.setTenNCC(rs.getString("TenNCC"));
        dh.setNgayTao(rs.getString("NgayTao") != null ? rs.getString("NgayTao").substring(0,10) : "");
        dh.setSoMatHang(rs.getInt("SoMatHang"));
        dh.setTongTien(rs.getDouble("TongTien"));
        dh.setTrangThai(rs.getString("TrangThai"));
        return dh;
    }
}
