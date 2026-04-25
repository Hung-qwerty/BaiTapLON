package controller;

import dao.TaiKhoanDAO;
import model.TaiKhoan;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nếu đã đăng nhập thì redirect
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            redirectByRole((TaiKhoan) session.getAttribute("user"), resp);
            return;
        }
        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        TaiKhoanDAO dao = new TaiKhoanDAO();
        TaiKhoan user = dao.login(username, password);

        if (user != null) {
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 phút
            redirectByRole(user, resp);
        } else {
            req.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(TaiKhoan user, HttpServletResponse resp) throws IOException {
        switch (user.getVaiTro()) {
            case "ADMIN":      resp.sendRedirect("admin/accounts"); break;
            case "MUA_HANG":   resp.sendRedirect("muahang/dashboard"); break;
            case "QUAN_LY":    resp.sendRedirect("quanly/dashboard"); break;
            case "KHO":        resp.sendRedirect("kho/dashboard"); break;
            case "DOI_CHIEU":  resp.sendRedirect("doichieu/dashboard"); break;
            case "TAI_VU":     resp.sendRedirect("taivu/dashboard"); break;
            case "PHAN_XUONG": resp.sendRedirect("phanxuong/dashboard"); break;
            default:           resp.sendRedirect("login");
        }
    }
}
