package controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

@WebServlet("/quanly/*")
public class QuanLyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();

        if ("/bophan".equals(path))   req.setAttribute("tab", "bophan");
        else if ("/thongbao".equals(path)) req.setAttribute("tab", "thongbao");
        else if ("/baocao".equals(path))   req.setAttribute("tab", "baocao");
        else req.setAttribute("tab", "tongquan");

        req.getRequestDispatcher("/views/quanly/dashboard.jsp").forward(req, resp);
    }
}
