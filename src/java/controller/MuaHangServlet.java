package controller;

import dao.DonHangDAO;
import dao.NhaCungCapDAO;
import model.TaiKhoan;
import model.DonHang;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/muahang/*")
public class MuaHangServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        String   path = req.getPathInfo(); // /dashboard, /ncc, /taomoi

        DonHangDAO    dhDAO  = new DonHangDAO();
        NhaCungCapDAO nccDAO = new NhaCungCapDAO();

        // Dữ liệu chung cho stat cards
        req.setAttribute("soLuongDonThang", dhDAO.countThang());
        req.setAttribute("tongGiaTri",      dhDAO.tongGiaTriThang());
        req.setAttribute("soCho",           dhDAO.countByTrangThai("MOI"));
        req.setAttribute("soNCC",           nccDAO.countActive());
        req.setAttribute("danhSachNCC",     nccDAO.getAll());
        req.setAttribute("pageTitle",       "Quản lý mua hàng");

        // Phân nhánh theo path → đặt activeNav và activeTab đúng
        if ("/ncc".equals(path)) {
            req.setAttribute("activeNav", "MUA_HANG_NCC");
            req.setAttribute("activeTab", "ncc");
        } else if ("/taomoi".equals(path)) {
            req.setAttribute("activeNav", "MUA_HANG_TAO");
            req.setAttribute("activeTab", "tao");
        } else {
            // /dashboard hoặc mặc định
            req.setAttribute("activeNav",   "MUA_HANG_DASH");
            req.setAttribute("activeTab",   "don");
            req.setAttribute("danhSachDon", dhDAO.getByNguoiTao(user.getMaTK()));
        }

        req.getRequestDispatcher("/views/muahang/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoan user   = (TaiKhoan) req.getSession().getAttribute("user");
        String   action = req.getParameter("action");
        String   ctx    = req.getContextPath();

        if ("taoDon".equals(action)) {
            DonHang dh = new DonHang();
            dh.setMaNCC(req.getParameter("maNCC"));
            dh.setGhiChu(req.getParameter("ghiChu"));
            dh.setNguoiTao(user.getMaTK());
            boolean ok = new DonHangDAO().insert(dh);
            req.getSession().setAttribute("flash", ok ? "Tạo đơn hàng thành công!" : "Tạo đơn hàng thất bại!");
            resp.sendRedirect(ctx + "/muahang/dashboard");

        } else if ("themNCC".equals(action)) {
            String tenNCC  = req.getParameter("tenNCC");
            String phone   = req.getParameter("phone");
            String email   = req.getParameter("email");
            String diaChi  = req.getParameter("diaChi");
            boolean ok = new NhaCungCapDAO().insert(tenNCC, phone, email, diaChi);
            req.getSession().setAttribute("flash", ok ? "Thêm nhà cung cấp thành công!" : "Thêm nhà cung cấp thất bại!");
            resp.sendRedirect(ctx + "/muahang/ncc");

        } else if ("xoaNCC".equals(action)) {
            new NhaCungCapDAO().delete(req.getParameter("maNCC"));
            resp.sendRedirect(ctx + "/muahang/ncc");

        } else {
            resp.sendRedirect(ctx + "/muahang/dashboard");
        }
    }
}
