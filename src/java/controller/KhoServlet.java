package controller;

import dao.PhieuNhapDAO;
import dao.PhieuXuatDAO;
import dao.TonKhoDAO;
import model.TaiKhoan;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/kho/*")
public class KhoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();

        PhieuNhapDAO nhapDAO = new PhieuNhapDAO();
        PhieuXuatDAO xuatDAO = new PhieuXuatDAO();
        TonKhoDAO    tonDAO  = new TonKhoDAO();

        // Stat cards — luôn load
        req.setAttribute("slTon",  tonDAO.countMatHang());
        req.setAttribute("slNhap", nhapDAO.countHomNay());
        req.setAttribute("slXuat", xuatDAO.countHomNay());
        req.setAttribute("slLech", nhapDAO.countSaiLech());
        req.setAttribute("pageTitle", "Quản lý kho hàng");

        // Danh sách vật tư — luôn load (dùng cho mọi form)
        req.setAttribute("danhSachVatTu", tonDAO.getAllVatTu());

        // Chi tiết phiếu nhập
        if ("/chitietnhap".equals(path)) {
            String maNK = req.getParameter("id");
            req.setAttribute("phieu",    nhapDAO.getById(maNK));
            req.setAttribute("chiTiet",  nhapDAO.getChiTiet(maNK));
            req.setAttribute("activeNav","KHO_NHAP");
            req.getRequestDispatcher("/views/kho/chitiet_nhap.jsp").forward(req, resp);
            return;
        }

        // Chi tiết phiếu xuất
        if ("/chitietxuat".equals(path)) {
            String maXK = req.getParameter("id");
            req.setAttribute("phieu",   xuatDAO.getById(maXK));
            req.setAttribute("chiTiet", xuatDAO.getChiTiet(maXK));
            req.setAttribute("activeNav","KHO_XUAT");
            req.getRequestDispatcher("/views/kho/chitiet_xuat.jsp").forward(req, resp);
            return;
        }

        // Các tab chính
        String tab, activeNav;

        if ("/nhaphang".equals(path)) {
            tab       = "nhaphang";
            activeNav = "KHO_NHAP";
            req.setAttribute("danhSachNhap",   nhapDAO.getAll());
            // Load danh sách đơn hàng để chọn trong dropdown
            req.setAttribute("danhSachDonHang", nhapDAO.getDanhSachDonHang());

        } else if ("/xuathang".equals(path)) {
            tab       = "xuathang";
            activeNav = "KHO_XUAT";
            req.setAttribute("danhSachXuat", xuatDAO.getAll());

        } else if ("/tonkho".equals(path)) {
            tab       = "tonkho";
            activeNav = "KHO_TON";
            req.setAttribute("danhSachTon", tonDAO.getAll());

        } else if ("/lenhxuat".equals(path)) {
            tab       = "lenhxuat";
            activeNav = "KHO_LENH";

        } else {
            tab       = "tonkho";
            activeNav = "KHO_DASH";
            req.setAttribute("danhSachTon", tonDAO.getAll());
        }

        req.setAttribute("tab",       tab);
        req.setAttribute("activeNav", activeNav);
        req.getRequestDispatcher("/views/kho/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String   action = req.getParameter("action");
        String   ctx    = req.getContextPath();
        TaiKhoan user   = (TaiKhoan) req.getSession().getAttribute("user");
        String   maTK   = (user != null) ? user.getMaTK() : "SYS";

        if ("taoPhieuNhap".equals(action)) {
            String   maDH      = req.getParameter("maDH");
            String   maKho     = req.getParameter("maKho");
            String   trangThai = req.getParameter("trangThai");
            String   ghiChu    = req.getParameter("ghiChu");
            String[] maVTs     = req.getParameterValues("maVT[]");
            String[] slDat     = req.getParameterValues("soLuongDat[]");
            String[] slNhan    = req.getParameterValues("soLuongNhan[]");

            if (!coVatTuHopLe(maVTs)) {
                req.getSession().setAttribute("flashErr",
                    "Vui lòng thêm ít nhất 1 vật tư!");
                resp.sendRedirect(ctx + "/kho/nhaphang");
                return;
            }
            try {
                new PhieuNhapDAO().insert(maDH, maKho, trangThai, ghiChu, maTK, maVTs, slDat, slNhan);
                req.getSession().setAttribute("flash",
                    "Tạo phiếu nhập thành công! Tồn kho đã được cập nhật.");
            } catch (SQLException e) {
                req.getSession().setAttribute("flashErr",
                    "Lỗi tạo phiếu nhập: " + e.getMessage());
            }
            resp.sendRedirect(ctx + "/kho/nhaphang");

        } else if ("taoPhieuXuat".equals(action)) {
            String   maKho  = req.getParameter("maKho");
            String   maPX   = req.getParameter("maPX");
            String   ghiChu = req.getParameter("ghiChu");
            String[] maVTs  = req.getParameterValues("maVT[]");
            String[] slXuat = req.getParameterValues("soLuong[]");

            if (!coVatTuHopLe(maVTs)) {
                req.getSession().setAttribute("flashErr",
                    "Vui lòng thêm ít nhất 1 vật tư!");
                resp.sendRedirect(ctx + "/kho/xuathang");
                return;
            }
            try {
                new PhieuXuatDAO().insert(maKho, maPX, ghiChu, maTK, maVTs, slXuat);
                req.getSession().setAttribute("flash",
                    "Tạo phiếu xuất thành công! Tồn kho đã được trừ.");
            } catch (SQLException e) {
                req.getSession().setAttribute("flashErr", "Lỗi: " + e.getMessage());
            }
            resp.sendRedirect(ctx + "/kho/xuathang");

        } else if ("xuLyXuat".equals(action)) {
            String   maLenh = req.getParameter("maLenh");
            String   maKho  = req.getParameter("maKho");
            String   maPX   = req.getParameter("maPX");
            String[] maVTs  = req.getParameterValues("maVT[]");
            String[] slXuat = req.getParameterValues("soLuong[]");

            if (!coVatTuHopLe(maVTs)) {
                req.getSession().setAttribute("flashErr",
                    "Vui lòng chọn ít nhất 1 vật tư!");
                resp.sendRedirect(ctx + "/kho/lenhxuat");
                return;
            }
            try {
                new PhieuXuatDAO().xuLyLenh(maLenh, maKho, maPX, maTK, maVTs, slXuat);
                req.getSession().setAttribute("flash",
                    "Đã xử lý lệnh xuất " + maLenh + "! Tồn kho đã được trừ.");
            } catch (SQLException e) {
                req.getSession().setAttribute("flashErr", "Lỗi xử lý: " + e.getMessage());
            }
            resp.sendRedirect(ctx + "/kho/lenhxuat");

        } else {
            resp.sendRedirect(req.getContextPath() + "/kho/dashboard");
        }
    }

    private boolean coVatTuHopLe(String[] maVTs) {
        if (maVTs == null) return false;
        for (String m : maVTs) {
            if (m != null && !m.trim().isEmpty()) return true;
        }
        return false;
    }
}
