package controller;

import model.TaiKhoan;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Cho phép truy cập không cần đăng nhập
        boolean isPublic = uri.equals(ctx + "/login")
                || uri.equals(ctx + "/")
                || uri.startsWith(ctx + "/css/")
                || uri.startsWith(ctx + "/js/")
                || uri.startsWith(ctx + "/images/");

        if (isPublic) { chain.doFilter(request, response); return; }

        HttpSession session = req.getSession(false);
        TaiKhoan user = (session != null) ? (TaiKhoan) session.getAttribute("user") : null;

        if (user == null) { res.sendRedirect(ctx + "/login"); return; }

        // Kiểm tra quyền truy cập theo vai trò
        String path = uri.substring(ctx.length());
        if (path.startsWith("/admin/") && !"ADMIN".equals(user.getVaiTro())) {
            res.sendRedirect(ctx + "/login"); return;
        }
        if (path.startsWith("/muahang/") && !"MUA_HANG".equals(user.getVaiTro()) && !"ADMIN".equals(user.getVaiTro())) {
            res.sendRedirect(ctx + "/login"); return;
        }
        if (path.startsWith("/quanly/") && !"QUAN_LY".equals(user.getVaiTro()) && !"ADMIN".equals(user.getVaiTro())) {
            res.sendRedirect(ctx + "/login"); return;
        }
        if (path.startsWith("/kho/") && !"KHO".equals(user.getVaiTro()) && !"ADMIN".equals(user.getVaiTro())) {
            res.sendRedirect(ctx + "/login"); return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}
