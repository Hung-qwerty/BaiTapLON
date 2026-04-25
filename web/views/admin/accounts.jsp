<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.TaiKhoan" %>
<%
    // KHÔNG khai báo pageTitle/activeNav - đã set trong AdminServlet
    @SuppressWarnings("unchecked")
    List<TaiKhoan> accounts = (List<TaiKhoan>) request.getAttribute("accounts");
    TaiKhoan editTK = (TaiKhoan) request.getAttribute("editTK");
    String showForm = request.getParameter("form");
    String ctx      = request.getContextPath();

    int active = 0, locked = 0;
    if (accounts != null) for (TaiKhoan a : accounts) {
        if (a.getTrangThai() == 1) active++; else locked++;
    }
%>
<%@ include file="/WEB-INF/header.jsp" %>

<!-- Stats -->
<div class="stats-grid">
    <div class="stat-card"><div class="stat-label">Tổng tài khoản <span>&#128101;</span></div><div class="stat-value"><%= accounts != null ? accounts.size() : 0 %></div><div class="stat-sub">Trong hệ thống</div></div>
    <div class="stat-card"><div class="stat-label">Đang hoạt động <span>&#9989;</span></div><div class="stat-value"><%= active %></div><div class="stat-sub">Tài khoản</div></div>
    <div class="stat-card"><div class="stat-label">Đã khóa <span>&#128274;</span></div><div class="stat-value"><%= locked %></div><div class="stat-sub">Tài khoản</div></div>
    <div class="stat-card"><div class="stat-label">Vai trò <span>&#127917;</span></div><div class="stat-value">6</div><div class="stat-sub">Loại vai trò</div></div>
</div>

<!-- Form thêm/sửa -->
<% if ("add".equals(showForm) || "edit".equals(showForm)) { %>
<div class="card">
    <div class="card-title" style="margin-bottom:16px">
        <%= "edit".equals(showForm) ? "Chỉnh sửa tài khoản" : "Tạo tài khoản mới" %>
    </div>
    <form action="<%= ctx %>/admin/accounts" method="post">
        <input type="hidden" name="action" value="<%= "edit".equals(showForm)?"update":"insert" %>">
        <% if ("edit".equals(showForm) && editTK != null) { %>
        <input type="hidden" name="maTK" value="<%= editTK.getMaTK() %>">
        <% } %>
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label">Họ và tên *</label>
                <input type="text" name="hoTen" class="form-control" required
                       value="<%= editTK!=null?editTK.getHoTen():"" %>" placeholder="Nhập họ và tên">
            </div>
            <div class="form-group">
                <label class="form-label">Tên đăng nhập *</label>
                <input type="text" name="tenDangNhap" class="form-control" required
                       value="<%= editTK!=null?editTK.getTenDangNhap():"" %>" placeholder="vd: nhanvien.abc">
            </div>
            <div class="form-group">
                <label class="form-label">Mật khẩu <% if("edit".equals(showForm)){%>(để trống nếu không đổi)<%}else{%>*<%}%></label>
                <input type="password" name="matKhau" class="form-control"
                       <%= "add".equals(showForm)?"required":"" %> placeholder="Nhập mật khẩu">
            </div>
            <div class="form-group">
                <label class="form-label">Vai trò *</label>
                <select name="vaiTro" class="form-control" required>
                    <% String[] vt = {"MUA_HANG","KHO","DOI_CHIEU","TAI_VU","QUAN_LY","PHAN_XUONG"};
                       String[] vl = {"Nhân viên mua hàng","Nhân viên kho","Nhân viên đối chiếu","Nhân viên tài vụ","Tài khoản quản lý","Nhân viên phân xưởng"};
                       for (int i=0;i<vt.length;i++) {
                           boolean sel = editTK!=null && vt[i].equals(editTK.getVaiTro());
                    %>
                    <option value="<%= vt[i] %>" <%= sel?"selected":"" %>><%= vl[i] %></option>
                    <% } %>
                </select>
            </div>
            <% if ("edit".equals(showForm)) { %>
            <div class="form-group">
                <label class="form-label">Trạng thái</label>
                <select name="trangThai" class="form-control">
                    <option value="1" <%= editTK!=null&&editTK.getTrangThai()==1?"selected":"" %>>Hoạt động</option>
                    <option value="0" <%= editTK!=null&&editTK.getTrangThai()==0?"selected":"" %>>Khóa</option>
                </select>
            </div>
            <% } %>
        </div>
        <div style="margin-top:20px;display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">
                <%= "edit".equals(showForm)?"Lưu thay đổi":"Tạo tài khoản" %>
            </button>
            <a href="<%= ctx %>/admin/accounts" class="btn btn-outline">Hủy</a>
        </div>
    </form>
</div>
<% } %>

<!-- Danh sách tài khoản -->
<div class="card">
    <div class="card-header">
        <div><div class="card-title">Danh sách tài khoản</div><div class="card-sub">Quản lý tất cả người dùng trong hệ thống</div></div>
        <div class="card-actions">
            <div class="search-wrap"><input type="text" id="searchAcc" class="search-input" placeholder="Tìm kiếm..." onkeyup="filterTable('accTable','searchAcc')"></div>
            <a href="?form=add" class="btn btn-primary">+ Thêm tài khoản</a>
        </div>
    </div>
    <table id="accTable">
        <thead><tr><th>Mã TK</th><th>Họ tên</th><th>Tên đăng nhập</th><th>Vai trò</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
        <tbody>
        <% if (accounts != null) for (TaiKhoan a : accounts) {
               boolean isAdmin = "TK000".equals(a.getMaTK());
               String stCls = a.getTrangThai()==1 ? "badge-green" : "badge-red";
               String stLbl = a.getTrangThai()==1 ? "Hoạt động"   : "Đã khóa";
        %>
        <tr>
            <td><strong><%= a.getMaTK() %></strong></td>
            <td><%= a.getHoTen() %></td>
            <td style="color:#64748b"><%= a.getTenDangNhap() %></td>
            <td><span class="badge badge-gray"><%= a.getVaiTroLabel() %></span></td>
            <td><span class="badge <%= stCls %>"><%= stLbl %></span></td>
            <td>
                <div style="display:flex;gap:10px">
                    <a href="?form=edit&maTK=<%= a.getMaTK() %>" class="btn-link">Sửa</a>
                    <% if (!isAdmin) { %>
                    <form action="<%= ctx %>/admin/accounts" method="post" style="display:inline"
                          onsubmit="return confirm('Xác nhận khóa tài khoản này?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="maTK"   value="<%= a.getMaTK() %>">
                        <button type="submit" class="btn-link" style="color:#ef4444">Khóa</button>
                    </form>
                    <% } %>
                </div>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<script>
function filterTable(tableId, inputId) {
    const q = document.getElementById(inputId).value.toLowerCase();
    document.querySelectorAll('#' + tableId + ' tbody tr').forEach(r => {
        r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
</script>

<%@ include file="/WEB-INF/footer.jsp" %>
