package model;

public class DonHang {
    private String maDH;
    private String maNCC;
    private String tenNCC;
    private String ngayTao;
    private int soMatHang;
    private double tongTien;
    private String trangThai;
    private String nguoiTao;
    private String ghiChu;

    public DonHang() {}

    public String getMaDH()           { return maDH; }
    public void setMaDH(String v)     { this.maDH = v; }
    public String getMaNCC()          { return maNCC; }
    public void setMaNCC(String v)    { this.maNCC = v; }
    public String getTenNCC()         { return tenNCC; }
    public void setTenNCC(String v)   { this.tenNCC = v; }
    public String getNgayTao()        { return ngayTao; }
    public void setNgayTao(String v)  { this.ngayTao = v; }
    public int getSoMatHang()         { return soMatHang; }
    public void setSoMatHang(int v)   { this.soMatHang = v; }
    public double getTongTien()       { return tongTien; }
    public void setTongTien(double v) { this.tongTien = v; }
    public String getTrangThai()      { return trangThai; }
    public void setTrangThai(String v){ this.trangThai = v; }
    public String getNguoiTao()       { return nguoiTao; }
    public void setNguoiTao(String v) { this.nguoiTao = v; }
    public String getGhiChu()         { return ghiChu; }
    public void setGhiChu(String v)   { this.ghiChu = v; }

    public String getTongTienFormatted() {
        return String.format("%,.0fđ", tongTien);
    }
}
