package controller;

import dao.QuanLyDAO;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;
import java.util.Map;

@WebServlet("/quanly/*")
public class QuanLyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String path = req.getPathInfo();
        String tab  = req.getParameter("tab");

        // Xác định tab từ path hoặc query param
        if (tab == null) {
            if      ("/bophan".equals(path))   tab = "bophan";
            else if ("/thongbao".equals(path)) tab = "thongbao";
            else if ("/baocao".equals(path))   tab = "baocao";
            else                               tab = "tongquan";
        }

        QuanLyDAO dao = new QuanLyDAO();
        req.setAttribute("pageTitle", "Dashboard Quản lý");
        req.setAttribute("tab", tab);

        // ── Stat cards (luôn load) ──────────────────────────────
        double dt = dao.tongDoanhThu();
        req.setAttribute("tongDoanhThu",    formatTien(dt));
        req.setAttribute("tongMatHang",     String.format("%,d", dao.tongMatHang()));
        req.setAttribute("soBoPhan",        dao.soBoPhan());
        req.setAttribute("tongNhanVien",    dao.tongNhanVien());

        // ── Load data theo tab ───────────────────────────────────
        switch (tab) {
            case "tongquan":
                req.setAttribute("activeNav", "QL_DASH");
                // Dữ liệu biểu đồ: chuyển map → JSON array cho JS
                Map<Integer,Double> dtMap  = dao.doanhThuTheoThang();
                Map<Integer,Double> tkMap  = dao.tonKhoTheoThang();
                req.setAttribute("doanhThuData", toJsonArray(dtMap));
                req.setAttribute("tonKhoData",   toJsonArray(tkMap));
                req.setAttribute("maxDT",        maxVal(dtMap));
                req.setAttribute("maxTK",        maxVal(tkMap));
                break;

            case "bophan":
                req.setAttribute("activeNav", "QL_BP");
                req.setAttribute("danhSachBoPhan", dao.hieuSuatBoPhan());
                break;

            case "thongbao":
                req.setAttribute("activeNav", "QL_TB");
                req.setAttribute("danhSachThongBao", dao.danhSachThongBao());
                req.setAttribute("soMatHangThieu",   dao.soMatHangThieu());
                req.setAttribute("soDonChoDuyet",    dao.soDonChoDuyet());
                req.setAttribute("soPhieuSaiLech",   dao.soPhieuSaiLech());
                break;

            case "baocao":
                req.setAttribute("activeNav", "QL_BC");
                req.setAttribute("giaTriTonKho",    formatTien(dao.giaTriTonKho()));
                req.setAttribute("tongThanhToan",   formatTien(dao.tongThanhToan()));
                req.setAttribute("soHoaDonChuaTT",  dao.soHoaDonChuaTT());
                req.setAttribute("tongDoanhThuRaw",  formatTien(dt));
                break;

            default:
                req.setAttribute("activeNav", "QL_DASH");
        }

        req.getRequestDispatcher("/views/quanly/dashboard.jsp").forward(req, resp);
    }

    // ── Helpers ──────────────────────────────────────────────────

    /** Format tiền: >= 1 tỷ → "X.X tỷ đ", >= 1 triệu → "XM đ" */
    private String formatTien(double v) {
        if (v >= 1_000_000_000) return String.format("%.1f tỷ đ", v / 1_000_000_000);
        if (v >= 1_000_000)     return String.format("%.0fM đ",   v / 1_000_000);
        return String.format("%,.0f đ", v);
    }

    /** Chuyển map tháng→giá trị thành JSON array [v1, v2, ...] */
    private String toJsonArray(Map<Integer,Double> map) {
        StringBuilder sb = new StringBuilder("[");
        for (Double v : map.values()) {
            if (sb.length() > 1) sb.append(",");
            // Đổi sang triệu đồng cho biểu đồ
            sb.append(String.format("%.1f", v / 1_000_000));
        }
        sb.append("]");
        return sb.toString();
    }

    /** Giá trị lớn nhất trong map, tối thiểu 100 để tránh chia 0 */
    private double maxVal(Map<Integer,Double> map) {
        double max = 100_000_000; // 100M mặc định
        for (Double v : map.values()) if (v > max) max = v;
        return max / 1_000_000; // đổi sang triệu
    }
}
