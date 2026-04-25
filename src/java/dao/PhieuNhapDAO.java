package dao;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class PhieuNhapDAO {

    public List<Map<String,String>> getAll() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT pn.MaNK, pn.MaDH, pn.MaKho, pn.NgayNhap, pn.TrangThai, pn.GhiChu,"
                   + " ncc.TenNCC"
                   + " FROM PhieuNhapKho pn"
                   + " LEFT JOIN DonHang dh     ON pn.MaDH  = dh.MaDH"
                   + " LEFT JOIN NhaCungCap ncc  ON dh.MaNCC = ncc.MaNCC"
                   + " ORDER BY pn.NgayNhap DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maNK",         rs.getString("MaNK"));
                m.put("maDH",         nvl(rs.getString("MaDH"),     "—"));
                m.put("maKho",        nvl(rs.getString("MaKho"),    ""));
                m.put("ngayNhap",     date10(rs.getString("NgayNhap")));
                m.put("trangThaiRaw", nvl(rs.getString("TrangThai"), ""));
                m.put("trangThai",    labelNhap(rs.getString("TrangThai")));
                m.put("tenNCC",       nvl(rs.getString("TenNCC"),   "—"));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Map<String,String> getById(String maNK) {
        String sql = "SELECT pn.*, ncc.TenNCC, tk.HoTen AS TenNguoiNhap"
                   + " FROM PhieuNhapKho pn"
                   + " LEFT JOIN DonHang dh     ON pn.MaDH      = dh.MaDH"
                   + " LEFT JOIN NhaCungCap ncc  ON dh.MaNCC     = ncc.MaNCC"
                   + " LEFT JOIN TaiKhoan tk     ON pn.NguoiNhap = tk.MaTK"
                   + " WHERE pn.MaNK = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, maNK);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maNK",         rs.getString("MaNK"));
                m.put("maDH",         nvl(rs.getString("MaDH"),         "—"));
                m.put("maKho",        nvl(rs.getString("MaKho"),        ""));
                m.put("ngayNhap",     date10(rs.getString("NgayNhap")));
                m.put("trangThaiRaw", nvl(rs.getString("TrangThai"),    ""));
                m.put("trangThai",    labelNhap(rs.getString("TrangThai")));
                m.put("tenNCC",       nvl(rs.getString("TenNCC"),       "—"));
                m.put("nguoiNhap",    nvl(rs.getString("TenNguoiNhap"), rs.getString("NguoiNhap")));
                m.put("ghiChu",       nvl(rs.getString("GhiChu"),       ""));
                return m;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Map<String,String>> getChiTiet(String maNK) {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT ct.MaVT, ct.SoLuongDat, ct.SoLuongNhan, ct.ChenhLech,"
                   + " vt.TenVT, vt.DonViTinh"
                   + " FROM ChiTietNhapKho ct"
                   + " LEFT JOIN VatTu vt ON ct.MaVT = vt.MaVT"
                   + " WHERE ct.MaNK = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, maNK);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maVT",        rs.getString("MaVT"));
                m.put("tenVT",       nvl(rs.getString("TenVT"),     rs.getString("MaVT")));
                m.put("donViTinh",   nvl(rs.getString("DonViTinh"), ""));
                m.put("soLuongDat",  rs.getString("SoLuongDat"));
                m.put("soLuongNhan", rs.getString("SoLuongNhan"));
                m.put("chenhLech",   rs.getString("ChenhLech"));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Lấy danh sách đơn hàng để hiển thị dropdown trong form tạo phiếu nhập.
     */
    public List<Map<String,String>> getDanhSachDonHang() {
        List<Map<String,String>> list = new ArrayList<>();
        String sql = "SELECT dh.MaDH, ncc.TenNCC, dh.TrangThai"
                   + " FROM DonHang dh"
                   + " LEFT JOIN NhaCungCap ncc ON dh.MaNCC = ncc.MaNCC"
                   + " ORDER BY dh.NgayTao DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("maDH",   rs.getString("MaDH"));
                m.put("tenNCC", nvl(rs.getString("TenNCC"), "—"));
                m.put("tt",     nvl(rs.getString("TrangThai"), ""));
                list.add(m);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /**
     * Kiểm tra MaDH có tồn tại trong bảng DonHang không.
     * Trả về maDH nếu tồn tại, NULL nếu không.
     */
    private String validateMaDH(Connection c, String maDH) throws SQLException {
        if (maDH == null || maDH.trim().isEmpty()) return null;
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*) FROM DonHang WHERE MaDH = ?")) {
            ps.setString(1, maDH.trim());
            ResultSet rs = ps.executeQuery();
            return (rs.next() && rs.getInt(1) > 0) ? maDH.trim() : null;
        }
    }

    /**
     * Tạo phiếu nhập + cập nhật tồn kho trong 1 transaction.
     *
     * FIX 1: Kiểm tra MaDH tồn tại trong DB trước khi dùng → tránh FK error
     * FIX 2: ChenhLech là GENERATED ALWAYS → không INSERT
     */
    public void insert(String maDH, String maKho, String trangThai,
                       String ghiChu, String nguoiNhap,
                       String[] maVTs, String[] soLuongDats, String[] soLuongNhans)
            throws SQLException {

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Kiểm tra MaDH có tồn tại không — nếu không thì dùng NULL
                String maDHFinal = validateMaDH(c, maDH);

                // Sinh mã phiếu
                String maNK = nextId(c);

                // Insert PhieuNhapKho
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO PhieuNhapKho(MaNK, MaDH, MaKho, NguoiNhap, TrangThai, GhiChu)"
                      + " VALUES (?, ?, ?, ?, ?, ?)")) {
                    ps.setString(1, maNK);
                    if (maDHFinal != null) {
                        ps.setString(2, maDHFinal);
                    } else {
                        ps.setNull(2, Types.VARCHAR);
                    }
                    ps.setString(3, maKho);
                    ps.setString(4, nguoiNhap);
                    ps.setString(5, trangThai);
                    ps.setString(6, ghiChu != null ? ghiChu.trim() : "");
                    ps.executeUpdate();
                }

                // Insert từng dòng vật tư + cập nhật TonKho
                if (maVTs != null) {
                    for (int i = 0; i < maVTs.length; i++) {
                        if (maVTs[i] == null || maVTs[i].trim().isEmpty()) continue;
                        String maVT = maVTs[i].trim();
                        double dat  = parseDouble(soLuongDats,  i);
                        double nhan = parseDouble(soLuongNhans, i);

                        // Insert ChiTietNhapKho — KHÔNG insert ChenhLech (GENERATED)
                        try (PreparedStatement ps = c.prepareStatement(
                                "INSERT INTO ChiTietNhapKho(MaNK, MaVT, SoLuongDat, SoLuongNhan)"
                              + " VALUES (?, ?, ?, ?)")) {
                            ps.setString(1, maNK);
                            ps.setString(2, maVT);
                            ps.setDouble(3, dat);
                            ps.setDouble(4, nhan);
                            ps.executeUpdate();
                        }

                        // Cập nhật TonKho (UPSERT)
                        try (PreparedStatement ps = c.prepareStatement(
                                "INSERT INTO TonKho(MaKho, MaVT, SoLuong) VALUES (?, ?, ?)"
                              + " ON DUPLICATE KEY UPDATE SoLuong = SoLuong + VALUES(SoLuong)")) {
                            ps.setString(1, maKho);
                            ps.setString(2, maVT);
                            ps.setDouble(3, nhan);
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

    public int countHomNay() {
        return queryInt("SELECT COUNT(*) FROM PhieuNhapKho WHERE DATE(NgayNhap)=CURDATE()");
    }

    public int countSaiLech() {
        return queryInt("SELECT COUNT(*) FROM PhieuNhapKho WHERE TrangThai='SAI_LECH'");
    }

    // ── Helpers ──────────────────────────────────────────────────

    private int queryInt(String sql) {
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) { e.printStackTrace(); return 0; }
    }

    private String nextId(Connection c) throws SQLException {
        try (PreparedStatement ps = c.prepareStatement(
                "SELECT COUNT(*)+1 AS n FROM PhieuNhapKho");
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? String.format("NK%03d", rs.getInt("n")) : "NK001";
        }
    }

    private String labelNhap(String raw) {
        if (raw == null) return "";
        switch (raw) {
            case "NHAP_DU":       return "Nhập đủ";
            case "NHAP_MOT_PHAN": return "Nhập một phần";
            case "SAI_LECH":      return "Sai lệch";
            default:              return raw;
        }
    }

    private String nvl(String v, String d) { return (v != null && !v.isEmpty()) ? v : d; }
    private String date10(String d)        { return (d != null && d.length()>=10) ? d.substring(0,10) : ""; }
    private double parseDouble(String[] a, int i) {
        try { return (a!=null&&i<a.length&&a[i]!=null) ? Double.parseDouble(a[i]) : 0; }
        catch (NumberFormatException e) { return 0; }
    }
}
