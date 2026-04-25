package controller;

import dao.DonHangDAO;
import dao.NhaCungCapDAO;
import model.TaiKhoan;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/muahang/*")
public class MuaHangServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");
        String path = req.getPathInfo(); // /dashboard, /donhang, /ncc, v.v.

        DonHangDAO donHangDAO = new DonHangDAO();
        NhaCungCapDAO nccDAO  = new NhaCungCapDAO();

        // Thống kê
        req.setAttribute("soLuongDonThang",  donHangDAO.countThang());
        req.setAttribute("tongGiaTri",        donHangDAO.tongGiaTriThang());
        req.setAttribute("soCho",             donHangDAO.countByTrangThai("MOI"));
        req.setAttribute("soNCC",             nccDAO.countActive());
        req.setAttribute("danhSachDon",       donHangDAO.getByNguoiTao(user.getMaTK()));
        req.setAttribute("danhSachNCC",       nccDAO.getAll());

        if ("/donhang".equals(path)) {
            req.setAttribute("activeTab", "don");
        } else if ("/ncc".equals(path)) {
            req.setAttribute("activeTab", "ncc");
        } else if ("/taomoi".equals(path)) {
            req.setAttribute("activeTab", "tao");
        } else {
            req.setAttribute("activeTab", "don");
        }

        req.getRequestDispatcher("/views/muahang/dashboard.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        TaiKhoan user = (TaiKhoan) req.getSession().getAttribute("user");

        if ("taoDon".equals(action)) {
            model.DonHang dh = new model.DonHang();
            dh.setMaNCC(req.getParameter("maNCC"));
            dh.setGhiChu(req.getParameter("ghiChu"));
            dh.setNguoiTao(user.getMaTK());
            new DonHangDAO().insert(dh);
        }
        resp.sendRedirect(req.getContextPath() + "/muahang/dashboard");
    }
}
