<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.TaiKhoan" %>
<%
    String pageTitle = (String) request.getAttribute("pageTitle");
    String activeNav = (String) request.getAttribute("activeNav");
    if (pageTitle == null) pageTitle = "Quản lý kho hàng";
    if (activeNav  == null) activeNav  = "";

    TaiKhoan _u   = (TaiKhoan) session.getAttribute("user");
    String _hoTen = (_u != null) ? _u.getHoTen()      : "";
    String _role  = (_u != null) ? _u.getVaiTro()      : "";
    String _label = (_u != null) ? _u.getVaiTroLabel() : "";
    String _av    = (_hoTen.length() > 0) ? String.valueOf(_hoTen.charAt(0)) : "U";
    String _ctx   = request.getContextPath();

    String _flash = (String) session.getAttribute("flash");
    if (_flash != null) session.removeAttribute("flash");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <link rel="stylesheet" href="<%= _ctx %>/css/style.css">
    <style>
        .nav-item.active {
            background: #1e293b !important;
            color: #f8fafc !important;
            border-left: 3px solid #3b82f6 !important;
        }
        .flash-msg { padding:12px 18px; border-radius:8px; margin-bottom:16px; font-weight:600; font-size:14px; }
        .flash-ok  { background:#dcfce7; border:1px solid #86efac; color:#16a34a; }
        .flash-err { background:#fee2e2; border:1px solid #fca5a5; color:#dc2626; }
    </style>
</head>
<body>
<div class="wrapper">

<aside class="sidebar">
    <div class="sidebar-logo">
        <div class="icon">&#127981;</div>
        <div>
            <div class="title">Quản lý kho hàng</div>
            <div class="role"><%= _label %></div>
        </div>
    </div>

    <nav class="sidebar-nav">

        <% if ("MUA_HANG".equals(_role)) { %>
            <a href="<%= _ctx %>/muahang/dashboard" class="nav-item <%= "MUA_HANG_DASH".equals(activeNav)?"active":"" %>"><span class="ni">&#128722;</span> Đơn mua hàng</a>
            <a href="<%= _ctx %>/muahang/ncc"       class="nav-item <%= "MUA_HANG_NCC".equals(activeNav)?"active":"" %>"><span class="ni">&#127970;</span> Nhà cung cấp</a>
            <a href="<%= _ctx %>/muahang/taomoi"    class="nav-item <%= "MUA_HANG_TAO".equals(activeNav)?"active":"" %>"><span class="ni">&#10133;</span> Tạo đơn mới</a>

        <% } else if ("KHO".equals(_role)) { %>
            <a href="<%= _ctx %>/kho/dashboard"  class="nav-item <%= "KHO_DASH".equals(activeNav)?"active":"" %>"><span class="ni">&#128202;</span> Tổng quan kho</a>
            <a href="<%= _ctx %>/kho/nhaphang"   class="nav-item <%= "KHO_NHAP".equals(activeNav)?"active":"" %>"><span class="ni">&#128229;</span> Nhập hàng</a>
            <a href="<%= _ctx %>/kho/xuathang"   class="nav-item <%= "KHO_XUAT".equals(activeNav)?"active":"" %>"><span class="ni">&#128228;</span> Xuất hàng</a>
            <a href="<%= _ctx %>/kho/tonkho"     class="nav-item <%= "KHO_TON".equals(activeNav)?"active":"" %>"><span class="ni">&#128230;</span> Tồn kho</a>
            <a href="<%= _ctx %>/kho/lenhxuat"   class="nav-item <%= "KHO_LENH".equals(activeNav)?"active":"" %>"><span class="ni">&#128196;</span> Lệnh xuất</a>

        <% } else if ("QUAN_LY".equals(_role)) { %>
            <a href="<%= _ctx %>/quanly/dashboard"               class="nav-item <%= "QL_DASH".equals(activeNav)?"active":"" %>"><span class="ni">&#128202;</span> Tổng quan</a>
            <a href="<%= _ctx %>/quanly/dashboard?tab=bophan"    class="nav-item <%= "QL_BP".equals(activeNav)?"active":"" %>"><span class="ni">&#127981;</span> Bộ phận</a>
            <a href="<%= _ctx %>/quanly/dashboard?tab=thongbao"  class="nav-item <%= "QL_TB".equals(activeNav)?"active":"" %>"><span class="ni">&#128276;</span> Thông báo</a>
            <a href="<%= _ctx %>/quanly/dashboard?tab=baocao"    class="nav-item <%= "QL_BC".equals(activeNav)?"active":"" %>"><span class="ni">&#128203;</span> Báo cáo</a>

        <% } else if ("ADMIN".equals(_role)) { %>
            <a href="<%= _ctx %>/admin/accounts" class="nav-item <%= "ADMIN_ACC".equals(activeNav)?"active":"" %>"><span class="ni">&#128101;</span> Quản lý tài khoản</a>

        <% } else if ("DOI_CHIEU".equals(_role)) { %>
            <a href="<%= _ctx %>/doichieu/dashboard" class="nav-item active"><span class="ni">&#128269;</span> Đối chiếu hàng</a>

        <% } else if ("TAI_VU".equals(_role)) { %>
            <a href="<%= _ctx %>/taivu/dashboard" class="nav-item active"><span class="ni">&#128179;</span> Quản lý tài vụ</a>

        <% } else if ("PHAN_XUONG".equals(_role)) { %>
            <a href="<%= _ctx %>/phanxuong/dashboard" class="nav-item active"><span class="ni">&#128295;</span> Phân xưởng</a>
        <% } %>

    </nav>

    <div class="sidebar-footer">
        <div class="user-info">
            <div class="avatar"><%= _av %></div>
            <div>
                <div class="user-name"><%= _hoTen %></div>
                <div class="user-role"><%= _label %></div>
            </div>
        </div>
        <form action="<%= _ctx %>/logout" method="get">
            <button type="submit" class="btn-logout">&#8617; Đăng xuất</button>
        </form>
    </div>
</aside>

<div class="main-area">
    <header class="topbar">
        <div class="topbar-title"><%= pageTitle %></div>
        <div class="topbar-right">
            <div class="topbar-user">
                <div class="avatar" style="width:30px;height:30px;font-size:13px"><%= _av %></div>
                <span><%= _hoTen %></span>
            </div>
        </div>
    </header>
    <div class="content">
        <% if (_flash != null) { %>
        <div class="flash-msg flash-ok">&#10003; <%= _flash %></div>
        <% } %>
