package model;

public class TaiKhoan {
    private String maTK;
    private String tenDangNhap;
    private String matKhau;
    private String hoTen;
    private String vaiTro;
    private String maKho;
    private String maPhanXuong;
    private int trangThai;

    public TaiKhoan() {}

    public TaiKhoan(String maTK, String tenDangNhap, String matKhau,
                    String hoTen, String vaiTro, String maKho, String maPhanXuong, int trangThai) {
        this.maTK = maTK;
        this.tenDangNhap = tenDangNhap;
        this.matKhau = matKhau;
        this.hoTen = hoTen;
        this.vaiTro = vaiTro;
        this.maKho = maKho;
        this.maPhanXuong = maPhanXuong;
        this.trangThai = trangThai;
    }

    public String getMaTK()          { return maTK; }
    public void setMaTK(String v)    { this.maTK = v; }
    public String getTenDangNhap()   { return tenDangNhap; }
    public void setTenDangNhap(String v) { this.tenDangNhap = v; }
    public String getMatKhau()       { return matKhau; }
    public void setMatKhau(String v) { this.matKhau = v; }
    public String getHoTen()         { return hoTen; }
    public void setHoTen(String v)   { this.hoTen = v; }
    public String getVaiTro()        { return vaiTro; }
    public void setVaiTro(String v)  { this.vaiTro = v; }
    public String getMaKho()         { return maKho; }
    public void setMaKho(String v)   { this.maKho = v; }
    public String getMaPhanXuong()   { return maPhanXuong; }
    public void setMaPhanXuong(String v) { this.maPhanXuong = v; }
    public int getTrangThai()        { return trangThai; }
    public void setTrangThai(int v)  { this.trangThai = v; }

    public String getVaiTroLabel() {
        switch (vaiTro) {
            case "ADMIN":      return "Quản trị hệ thống";
            case "MUA_HANG":   return "Nhân viên mua hàng";
            case "KHO":        return "Nhân viên kho";
            case "DOI_CHIEU":  return "Nhân viên đối chiếu";
            case "TAI_VU":     return "Nhân viên tài vụ";
            case "QUAN_LY":    return "Tài khoản quản lý";
            case "PHAN_XUONG": return "Nhân viên phân xưởng";
            default:           return vaiTro;
        }
    }
}
