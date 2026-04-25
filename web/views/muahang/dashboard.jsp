<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, model.DonHang" %>
<%
    // KHÔNG khai báo pageTitle/activeNav ở đây - đã set trong Servlet
    // Chỉ lấy các biến nghiệp vụ cần dùng trong trang này
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "don";

    @SuppressWarnings("unchecked")
    List<DonHang> danhSachDon = (List<DonHang>) request.getAttribute("danhSachDon");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachNCC = (List<Map<String,String>>) request.getAttribute("danhSachNCC");

    Integer soLuongDon = (Integer) request.getAttribute("soLuongDonThang");
    Double  tongGiaTri = (Double)  request.getAttribute("tongGiaTri");
    Integer soCho      = (Integer) request.getAttribute("soCho");
    Integer soNCC      = (Integer) request.getAttribute("soNCC");
    String  ctx        = request.getContextPath();

    if (soLuongDon == null) soLuongDon = 0;
    if (tongGiaTri == null) tongGiaTri = 0.0;
    if (soCho      == null) soCho      = 0;
    if (soNCC      == null) soNCC      = 0;

    String tvStr  = tongGiaTri >= 1_000_000
        ? String.format("%.0fM đ", tongGiaTri / 1_000_000)
        : String.format("%,.0fđ", tongGiaTri);
    double avg    = soLuongDon > 0 ? tongGiaTri / soLuongDon : 0;
    String avgStr = avg >= 1_000_000
        ? String.format("%.1fM đ", avg / 1_000_000)
        : String.format("%,.0fđ", avg);
%>
<%@ include file="/WEB-INF/header.jsp" %>

<!-- Stat Cards -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Đơn hàng tháng này <span>&#128722;</span></div>
        <div class="stat-value"><%= soLuongDon %></div>
        <div class="stat-sub">Tháng hiện tại</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Tổng giá trị <span>&#128200;</span></div>
        <div class="stat-value"><%= tvStr %></div>
        <div class="stat-sub">Tháng này</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Chờ duyệt <span>&#128336;</span></div>
        <div class="stat-value"><%= soCho %></div>
        <div class="stat-sub">Cần xử lý</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Nhà cung cấp <span>&#128230;</span></div>
        <div class="stat-value"><%= soNCC %></div>
        <div class="stat-sub">Đang hoạt động</div>
    </div>
</div>

<!-- Tabs -->
<div class="tabs">
    <a href="<%= ctx %>/muahang/dashboard"
       class="tab-btn <%= "don".equals(activeTab)?"active":"" %>">Đơn mua hàng</a>
    <a href="<%= ctx %>/muahang/ncc"
       class="tab-btn <%= "ncc".equals(activeTab)?"active":"" %>">Nhà cung cấp</a>
    <a href="<%= ctx %>/muahang/taomoi"
       class="tab-btn <%= "tao".equals(activeTab)?"active":"" %>">Tạo đơn mới</a>
</div>

<!-- ══ TAB: ĐƠN MUA HÀNG ══ -->
<% if ("don".equals(activeTab)) { %>
<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Đơn mua hàng</div>
            <div class="card-sub">Quản lý các đơn mua hàng</div>
        </div>
        <div class="card-actions">
            <div class="search-wrap">
                <input type="text" id="searchDon" class="search-input" placeholder="Tìm kiếm..."
                       onkeyup="filterTable('donTable','searchDon')">
            </div>
            <a href="<%= ctx %>/muahang/taomoi" class="btn btn-primary">+ Tạo đơn mới</a>
        </div>
    </div>
    <table id="donTable">
        <thead>
            <tr>
                <th>Mã đơn</th><th>Nhà cung cấp</th><th>Ngày tạo</th>
                <th>Số mặt hàng</th><th>Tổng tiền</th><th>Trạng thái</th><th>Thao tác</th>
            </tr>
        </thead>
        <tbody>
        <% if (danhSachDon != null && !danhSachDon.isEmpty()) {
               for (DonHang d : danhSachDon) {
                   String tt = d.getTrangThai();
                   String bc = "DA_DUYET".equals(tt)||"DA_NHAN".equals(tt) ? "badge-green"
                             : "MOI".equals(tt)||"CHO_DUYET".equals(tt)    ? "badge-yellow"
                             : "HUY".equals(tt)                            ? "badge-red"
                             : "badge-blue";
                   String tl = "MOI".equals(tt)       ? "Mới"
                             : "DA_GUI".equals(tt)    ? "Đã gửi"
                             : "DA_DUYET".equals(tt)  ? "Đã duyệt"
                             : "CHO_DUYET".equals(tt) ? "Chờ duyệt"
                             : "DA_NHAN".equals(tt)   ? "Đã nhận"
                             : "HUY".equals(tt)       ? "Hủy" : tt;
        %>
            <tr>
                <td><strong><%= d.getMaDH() %></strong></td>
                <td><%= d.getTenNCC() != null ? d.getTenNCC() : d.getMaNCC() %></td>
                <td><%= d.getNgayTao() %></td>
                <td><%= d.getSoMatHang() %></td>
                <td><%= d.getTongTienFormatted() %></td>
                <td><span class="badge <%= bc %>"><%= tl %></span></td>
                <td><a href="#" class="btn-link">Chi tiết</a></td>
            </tr>
        <% } } else { %>
            <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:32px">
                Chưa có đơn hàng nào</td></tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- Info cards -->
<div class="info-grid">
    <div class="info-card">
        <h4>Dashboard thực tế của người mua hàng</h4>
        <div class="info-row">
            <span class="lbl">Đơn hàng đang xử lý</span>
            <span class="val badge badge-dark"><%= soCho %></span>
        </div>
        <div class="info-row">
            <span class="lbl">Đơn hàng hoàn thành</span>
            <span class="val badge badge-gray"><%= Math.max(0, soLuongDon - soCho) %></span>
        </div>
    </div>
    <div class="info-card">
        <h4>Báo cáo tài chính mua hàng</h4>
        <div class="info-row"><span class="lbl">Tổng giá trị đơn hàng</span><span class="val"><%= tvStr %></span></div>
        <div class="info-row"><span class="lbl">Chi phí trung bình</span><span class="val"><%= avgStr %></span></div>
    </div>
    <div class="info-card">
        <h4>Cấp quyền truy cập vào hệ thống</h4>
        <div class="info-row"><span class="lbl">Quyền tạo đơn</span><span class="val badge badge-dark">Có</span></div>
        <div class="info-row"><span class="lbl">Quyền duyệt đơn</span><span class="val badge badge-gray">Không</span></div>
    </div>
</div>
<% } %>

<!-- ══ TAB: NHÀ CUNG CẤP ══ -->
<% if ("ncc".equals(activeTab)) { %>
<div class="card" id="formNCC" style="display:none">
    <div class="card-title" style="margin-bottom:16px">Thêm nhà cung cấp mới</div>
    <form action="<%= ctx %>/muahang/ncc" method="post">
        <input type="hidden" name="action" value="themNCC">
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label">Tên nhà cung cấp *</label>
                <input type="text" name="tenNCC" class="form-control" required placeholder="Nhập tên NCC">
            </div>
            <div class="form-group">
                <label class="form-label">Điện thoại</label>
                <input type="text" name="phone" class="form-control" placeholder="0901234567">
            </div>
            <div class="form-group">
                <label class="form-label">Email</label>
                <input type="email" name="email" class="form-control" placeholder="ncc@email.com">
            </div>
            <div class="form-group">
                <label class="form-label">Địa chỉ</label>
                <input type="text" name="diaChi" class="form-control" placeholder="Địa chỉ NCC">
            </div>
        </div>
        <div style="margin-top:16px;display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">Lưu nhà cung cấp</button>
            <button type="button" class="btn btn-outline" onclick="toggleForm()">Hủy</button>
        </div>
    </form>
</div>

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Danh sách Nhà cung cấp</div>
            <div class="card-sub">Quản lý các nhà cung cấp đang hoạt động</div>
        </div>
        <div class="card-actions">
            <div class="search-wrap">
                <input type="text" id="searchNCC" class="search-input" placeholder="Tìm NCC..."
                       onkeyup="filterTable('nccTable','searchNCC')">
            </div>
            <button class="btn btn-primary" onclick="toggleForm()">+ Thêm NCC</button>
        </div>
    </div>
    <table id="nccTable">
        <thead>
            <tr><th>Mã NCC</th><th>Tên nhà cung cấp</th><th>Điện thoại</th>
                <th>Email</th><th>Địa chỉ</th><th>Thao tác</th></tr>
        </thead>
        <tbody>
        <% if (danhSachNCC != null && !danhSachNCC.isEmpty()) {
               for (Map<String,String> n : danhSachNCC) { %>
            <tr>
                <td><strong><%= n.get("maNCC") %></strong></td>
                <td><%= n.get("tenNCC") %></td>
                <td><%= n.get("phone")  %></td>
                <td><%= n.get("email")  %></td>
                <td><%= n.get("diaChi") %></td>
                <td>
                    <div style="display:flex;gap:10px">
                        <a href="#" class="btn-link">Sửa</a>
                        <form action="<%= ctx %>/muahang/ncc" method="post" style="display:inline"
                              onsubmit="return confirm('Xác nhận xóa nhà cung cấp này?')">
                            <input type="hidden" name="action" value="xoaNCC">
                            <input type="hidden" name="maNCC" value="<%= n.get("maNCC") %>">
                            <button type="submit" class="btn-link" style="color:#ef4444">Xóa</button>
                        </form>
                    </div>
                </td>
            </tr>
        <% } } else { %>
            <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:32px">
                Chưa có nhà cung cấp nào</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<!-- ══ TAB: TẠO ĐƠN MỚI ══ -->
<% if ("tao".equals(activeTab)) { %>
<div class="card">
    <div class="card-title" style="margin-bottom:20px">Tạo đơn mua hàng mới</div>
    <form action="<%= ctx %>/muahang/dashboard" method="post">
        <input type="hidden" name="action" value="taoDon">
        <div class="form-grid">
            <div class="form-group">
                <label class="form-label">Nhà cung cấp *</label>
                <select name="maNCC" class="form-control" required>
                    <option value="">-- Chọn nhà cung cấp --</option>
                    <% if (danhSachNCC != null) for (Map<String,String> n : danhSachNCC) { %>
                    <option value="<%= n.get("maNCC") %>"><%= n.get("tenNCC") %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Ngày giao hàng dự kiến</label>
                <input type="date" name="ngayGiao" class="form-control">
            </div>
            <div class="form-group" style="grid-column:1/-1">
                <label class="form-label">Ghi chú</label>
                <textarea name="ghiChu" class="form-control" rows="3"
                          placeholder="Nhập ghi chú..."></textarea>
            </div>
        </div>
        <div style="margin-top:20px;display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">Tạo đơn hàng</button>
            <a href="<%= ctx %>/muahang/dashboard" class="btn btn-outline">Hủy</a>
        </div>
    </form>
</div>
<% } %>

<script>
function filterTable(tableId, inputId) {
    const q = document.getElementById(inputId).value.toLowerCase();
    document.querySelectorAll('#' + tableId + ' tbody tr').forEach(r => {
        r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function toggleForm() {
    const f = document.getElementById('formNCC');
    if (f) {
        f.style.display = f.style.display === 'none' ? 'block' : 'none';
        if (f.style.display === 'block') f.scrollIntoView({behavior:'smooth'});
    }
}
</script>

<%@ include file="/WEB-INF/footer.jsp" %>
