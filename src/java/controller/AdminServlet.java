package controller;

import dao.TaiKhoanDAO;
import model.TaiKhoan;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        TaiKhoanDAO dao = new TaiKhoanDAO();

        String form = req.getParameter("form");
        if ("edit".equals(form)) {
            String maTK = req.getParameter("maTK");
            req.setAttribute("editTK", dao.getById(maTK));
        }
        req.setAttribute("accounts", dao.getAll());
        req.getRequestDispatcher("/views/admin/accounts.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        TaiKhoanDAO dao = new TaiKhoanDAO();

        if ("insert".equals(action)) {
            TaiKhoan tk = new TaiKhoan();
            tk.setHoTen(req.getParameter("hoTen"));
            tk.setTenDangNhap(req.getParameter("tenDangNhap"));
            tk.setMatKhau(req.getParameter("matKhau"));
            tk.setVaiTro(req.getParameter("vaiTro"));
            tk.setTrangThai(1);
            if (dao.insert(tk)) req.getSession().setAttribute("flashMsg", "Tạo tài khoản thành công!");
            else req.getSession().setAttribute("flashErr", "Tạo tài khoản thất bại!");
        } else if ("update".equals(action)) {
            TaiKhoan tk = dao.getById(req.getParameter("maTK"));
            if (tk != null) {
                tk.setHoTen(req.getParameter("hoTen"));
                tk.setTenDangNhap(req.getParameter("tenDangNhap"));
                String p = req.getParameter("matKhau");
                if (p != null && !p.isEmpty()) tk.setMatKhau(p);
                tk.setVaiTro(req.getParameter("vaiTro"));
                tk.setTrangThai(Integer.parseInt(req.getParameter("trangThai")));
                dao.update(tk);
            }
        } else if ("delete".equals(action)) {
            dao.delete(req.getParameter("maTK"));
        }
        resp.sendRedirect(req.getContextPath() + "/admin/accounts");
    }
}
