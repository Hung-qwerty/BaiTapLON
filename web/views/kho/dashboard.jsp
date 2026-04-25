<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "tonkho";
    String ctx = request.getContextPath();

    Integer slTon  = (Integer) request.getAttribute("slTon");
    Integer slNhap = (Integer) request.getAttribute("slNhap");
    Integer slXuat = (Integer) request.getAttribute("slXuat");
    Integer slLech = (Integer) request.getAttribute("slLech");
    if (slTon  == null) slTon  = 0;
    if (slNhap == null) slNhap = 0;
    if (slXuat == null) slXuat = 0;
    if (slLech == null) slLech = 0;

    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachTon     = (List<Map<String,String>>) request.getAttribute("danhSachTon");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachNhap    = (List<Map<String,String>>) request.getAttribute("danhSachNhap");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachXuat    = (List<Map<String,String>>) request.getAttribute("danhSachXuat");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachVatTu   = (List<Map<String,String>>) request.getAttribute("danhSachVatTu");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachDonHang = (List<Map<String,String>>) request.getAttribute("danhSachDonHang");

    String flashErr = (String) session.getAttribute("flashErr");
    if (flashErr != null) session.removeAttribute("flashErr");
%>
<%@ include file="/WEB-INF/header.jsp" %>

<% if (flashErr != null) { %>
<div class="flash-msg flash-err">&#10060; <%= flashErr %></div>
<% } %>

<!-- STAT CARDS -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Tổng tồn kho <span>&#128230;</span></div>
        <div class="stat-value"><%= slTon %></div>
        <div class="stat-sub">Mặt hàng có tồn</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Nhập hôm nay <span>&#128229;</span></div>
        <div class="stat-value"><%= slNhap %></div>
        <div class="stat-sub">Phiếu nhập</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Xuất hôm nay <span>&#128228;</span></div>
        <div class="stat-value"><%= slXuat %></div>
        <div class="stat-sub">Phiếu xuất</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Lệch kho <span>&#9888;</span></div>
        <div class="stat-value"><%= slLech %></div>
        <div class="stat-sub">Phiếu sai lệch</div>
    </div>
</div>

<!-- TABS -->
<div class="tabs">
    <a href="<%= ctx %>/kho/tonkho"   class="tab-btn <%= "tonkho".equals(tab)   ? "active":"" %>">Tồn kho</a>
    <a href="<%= ctx %>/kho/nhaphang" class="tab-btn <%= "nhaphang".equals(tab) ? "active":"" %>">Nhập hàng</a>
    <a href="<%= ctx %>/kho/xuathang" class="tab-btn <%= "xuathang".equals(tab) ? "active":"" %>">Xuất hàng</a>
    <a href="<%= ctx %>/kho/lenhxuat" class="tab-btn <%= "lenhxuat".equals(tab) ? "active":"" %>">Lệnh xuất</a>
</div>

<%-- ══ TỒN KHO ══ --%>
<% if ("tonkho".equals(tab)) { %>
<div class="card">
    <div class="card-header">
        <div><div class="card-title">Danh sách tồn kho</div><div class="card-sub">Số lượng thực tế từ cơ sở dữ liệu</div></div>
        <div class="search-wrap"><input type="text" id="sTon" class="search-input" placeholder="Tìm vật tư..." onkeyup="ft('tTon','sTon')"></div>
    </div>
    <table id="tTon">
        <thead><tr><th>Mã vật tư</th><th>Tên vật tư</th><th>Kho</th><th>Số lượng</th><th>Đơn vị</th><th>Trạng thái</th></tr></thead>
        <tbody>
        <% if (danhSachTon != null && !danhSachTon.isEmpty()) {
               for (Map<String,String> t : danhSachTon) {
                   String tt = t.get("trangThai");
                   String tc = "Đủ".equals(tt) ? "badge-green" : "Thấp".equals(tt) ? "badge-yellow" : "badge-red";
        %>
        <tr>
            <td><strong><%= t.get("maVT") %></strong></td>
            <td><%= t.get("tenVT") %></td>
            <td><span class="badge badge-blue"><%= t.get("maKho") %></span></td>
            <td><strong><%= t.get("soLuong") %></strong></td>
            <td><%= t.get("donViTinh") %></td>
            <td><span class="badge <%= tc %>"><%= tt %></span></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:32px">Chưa có dữ liệu tồn kho</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%-- ══ NHẬP HÀNG ══ --%>
<% if ("nhaphang".equals(tab)) { %>
<div class="card" style="border:2px solid #3b82f6;margin-bottom:20px">
    <div class="card-title" style="margin-bottom:4px;color:#1d4ed8">&#128229; Tạo phiếu nhập kho</div>
    <div class="card-sub" style="margin-bottom:20px">Điền thông tin và chọn vật tư cần nhập</div>

    <form action="<%= ctx %>/kho/nhaphang" method="post" onsubmit="return validateNhap()">
        <input type="hidden" name="action" value="taoPhieuNhap">
        <div class="form-grid" style="margin-bottom:20px">

            <!-- Dropdown đơn hàng từ DB thay vì ô text tự do -->
            <div class="form-group">
                <label class="form-label">Đơn hàng liên quan</label>
                <select name="maDH" class="form-control">
                    <option value="">-- Không liên kết đơn hàng --</option>
                    <% if (danhSachDonHang != null) for (Map<String,String> dh : danhSachDonHang) { %>
                    <option value="<%= dh.get("maDH") %>">
                        <%= dh.get("maDH") %> – <%= dh.get("tenNCC") %>
                    </option>
                    <% } %>
                </select>
                <div style="font-size:11px;color:#94a3b8;margin-top:4px">
                    Chọn đơn hàng nếu phiếu nhập này thuộc 1 đơn đặt hàng cụ thể
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">Kho nhập <span style="color:red">*</span></label>
                <select name="maKho" class="form-control" required>
                    <option value="KHO01">KHO01 – Kho chính số 1</option>
                    <option value="KHO02">KHO02 – Kho số 2</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Trạng thái <span style="color:red">*</span></label>
                <select name="trangThai" class="form-control" required>
                    <option value="NHAP_DU">Nhập đủ</option>
                    <option value="NHAP_MOT_PHAN">Nhập một phần</option>
                    <option value="SAI_LECH">Sai lệch</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Ghi chú</label>
                <input type="text" name="ghiChu" class="form-control" placeholder="Ghi chú thêm...">
            </div>
        </div>

        <!-- Bảng vật tư nhập -->
        <div style="margin-bottom:12px">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                <strong style="font-size:14px">&#128230; Danh sách vật tư nhập <span style="color:red">*</span></strong>
                <button type="button" class="btn btn-outline" style="padding:5px 14px;font-size:13px"
                        onclick="themDong('tbodyNhap','nhap')">+ Thêm dòng</button>
            </div>
            <div style="overflow-x:auto">
                <table style="width:100%;border-collapse:collapse">
                    <thead>
                        <tr style="background:#f1f5f9">
                            <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #e2e8f0">VẬT TƯ <span style="color:red">*</span></th>
                            <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #e2e8f0;width:150px">SL ĐẶT</th>
                            <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #e2e8f0;width:150px">SL NHẬN <span style="color:red">*</span></th>
                            <th style="padding:10px;width:44px;border-bottom:1px solid #e2e8f0"></th>
                        </tr>
                    </thead>
                    <tbody id="tbodyNhap">
                    <tr>
                        <td style="padding:8px 6px">
                            <select name="maVT[]" class="form-control" required>
                                <option value="">-- Chọn vật tư --</option>
                                <% if (danhSachVatTu != null) for (Map<String,String> v : danhSachVatTu) { %>
                                <option value="<%= v.get("maVT") %>">[<%= v.get("maVT") %>] <%= v.get("tenVT") %><% if (!v.get("donViTinh").isEmpty()) { %> (<%= v.get("donViTinh") %>)<% } %></option>
                                <% } %>
                            </select>
                        </td>
                        <td style="padding:8px 6px">
                            <input type="number" name="soLuongDat[]" class="form-control" min="0" step="0.01" value="0">
                        </td>
                        <td style="padding:8px 6px">
                            <input type="number" name="soLuongNhan[]" class="form-control" min="0.01" step="0.01" placeholder="0" required>
                        </td>
                        <td style="padding:8px 6px;text-align:center">
                            <button type="button" onclick="xoaDong(this)" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:18px">&#10005;</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div id="errNhap" style="color:#ef4444;font-size:13px;margin-bottom:10px;display:none"></div>
        <div style="display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">&#10003; Lưu phiếu nhập</button>
            <a href="<%= ctx %>/kho/nhaphang" class="btn btn-outline">Làm lại</a>
        </div>
    </form>
</div>

<!-- Danh sách phiếu nhập -->
<div class="card">
    <div class="card-header">
        <div><div class="card-title">Phiếu nhập kho</div><div class="card-sub">Lịch sử nhập hàng</div></div>
        <div class="search-wrap"><input type="text" id="sNhap" class="search-input" placeholder="Tìm phiếu..." onkeyup="ft('tNhap','sNhap')"></div>
    </div>
    <table id="tNhap">
        <thead><tr><th>Mã phiếu</th><th>Đơn hàng</th><th>Kho nhập</th><th>Nhà CC</th><th>Ngày nhập</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
        <tbody>
        <% if (danhSachNhap != null && !danhSachNhap.isEmpty()) {
               for (Map<String,String> n : danhSachNhap) {
                   String raw = n.get("trangThaiRaw");
                   String bc  = "NHAP_DU".equals(raw) ? "badge-green" : "SAI_LECH".equals(raw) ? "badge-red" : "badge-yellow";
        %>
        <tr>
            <td><strong><%= n.get("maNK") %></strong></td>
            <td><%= n.get("maDH") %></td>
            <td><span class="badge badge-blue"><%= n.get("maKho") %></span></td>
            <td><%= n.get("tenNCC") %></td>
            <td><%= n.get("ngayNhap") %></td>
            <td><span class="badge <%= bc %>"><%= n.get("trangThai") %></span></td>
            <td><a href="<%= ctx %>/kho/chitietnhap?id=<%= n.get("maNK") %>" class="btn-link">Chi tiết</a></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="7" style="text-align:center;color:#94a3b8;padding:32px">Chưa có phiếu nhập nào</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%-- ══ XUẤT HÀNG ══ --%>
<% if ("xuathang".equals(tab)) { %>
<div class="card" style="border:2px solid #10b981;margin-bottom:20px">
    <div class="card-title" style="margin-bottom:4px;color:#065f46">&#128228; Tạo phiếu xuất kho</div>
    <div class="card-sub" style="margin-bottom:20px">Chọn vật tư cần xuất — hệ thống tự trừ tồn kho</div>

    <form action="<%= ctx %>/kho/xuathang" method="post" onsubmit="return validateXuat()">
        <input type="hidden" name="action" value="taoPhieuXuat">
        <div class="form-grid" style="margin-bottom:20px">
            <div class="form-group">
                <label class="form-label">Kho xuất <span style="color:red">*</span></label>
                <select name="maKho" class="form-control" required>
                    <option value="KHO01">KHO01 – Kho chính số 1</option>
                    <option value="KHO02">KHO02 – Kho số 2</option>
                </select>
            </div>
            <div class="form-group">
                <label class="form-label">Phân xưởng nhận <span style="color:red">*</span></label>
                <select name="maPX" class="form-control" required>
                    <option value="PX01">PX01 – Phân xưởng 1</option>
                    <option value="PX02">PX02 – Phân xưởng 2</option>
                </select>
            </div>
            <div class="form-group" style="grid-column:1/-1">
                <label class="form-label">Ghi chú</label>
                <input type="text" name="ghiChu" class="form-control" placeholder="Ghi chú thêm...">
            </div>
        </div>

        <div style="margin-bottom:12px">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
                <strong style="font-size:14px">&#128230; Danh sách vật tư xuất <span style="color:red">*</span></strong>
                <button type="button" class="btn btn-outline" style="padding:5px 14px;font-size:13px"
                        onclick="themDong('tbodyXuat','xuat')">+ Thêm dòng</button>
            </div>
            <div style="overflow-x:auto">
                <table style="width:100%;border-collapse:collapse">
                    <thead>
                        <tr style="background:#f1f5f9">
                            <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #e2e8f0">VẬT TƯ <span style="color:red">*</span></th>
                            <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #e2e8f0;width:200px">SỐ LƯỢNG XUẤT <span style="color:red">*</span></th>
                            <th style="padding:10px;width:44px;border-bottom:1px solid #e2e8f0"></th>
                        </tr>
                    </thead>
                    <tbody id="tbodyXuat">
                    <tr>
                        <td style="padding:8px 6px">
                            <select name="maVT[]" class="form-control" required>
                                <option value="">-- Chọn vật tư --</option>
                                <% if (danhSachVatTu != null) for (Map<String,String> v : danhSachVatTu) { %>
                                <option value="<%= v.get("maVT") %>">[<%= v.get("maVT") %>] <%= v.get("tenVT") %><% if (!v.get("donViTinh").isEmpty()) { %> (<%= v.get("donViTinh") %>)<% } %></option>
                                <% } %>
                            </select>
                        </td>
                        <td style="padding:8px 6px">
                            <input type="number" name="soLuong[]" class="form-control" min="0.01" step="0.01" placeholder="Nhập số lượng" required>
                        </td>
                        <td style="padding:8px 6px;text-align:center">
                            <button type="button" onclick="xoaDong(this)" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:18px">&#10005;</button>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <div id="errXuat" style="color:#ef4444;font-size:13px;margin-bottom:10px;display:none"></div>
        <div style="display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">&#10003; Lưu phiếu xuất</button>
            <a href="<%= ctx %>/kho/xuathang" class="btn btn-outline">Làm lại</a>
        </div>
    </form>
</div>

<div class="card">
    <div class="card-header">
        <div><div class="card-title">Phiếu xuất kho</div><div class="card-sub">Lịch sử xuất hàng</div></div>
        <div class="search-wrap"><input type="text" id="sXuat" class="search-input" placeholder="Tìm phiếu..." onkeyup="ft('tXuat','sXuat')"></div>
    </div>
    <table id="tXuat">
        <thead><tr><th>Mã phiếu</th><th>Kho</th><th>Phân xưởng</th><th>Ngày xuất</th><th>Trạng thái</th><th>Thao tác</th></tr></thead>
        <tbody>
        <% if (danhSachXuat != null && !danhSachXuat.isEmpty()) {
               for (Map<String,String> x : danhSachXuat) {
                   String raw = x.get("trangThaiRaw");
                   String xc  = "DA_XUAT".equals(raw) ? "badge-green" : "CHO_XUAT".equals(raw) ? "badge-yellow" : "badge-red";
        %>
        <tr>
            <td><strong><%= x.get("maXK") %></strong></td>
            <td><span class="badge badge-blue"><%= x.get("maKho") %></span></td>
            <td><%= x.get("tenPX") %></td>
            <td><%= x.get("ngayXuat") %></td>
            <td><span class="badge <%= xc %>"><%= x.get("trangThai") %></span></td>
            <td><a href="<%= ctx %>/kho/chitietxuat?id=<%= x.get("maXK") %>" class="btn-link">Chi tiết</a></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:32px">Chưa có phiếu xuất nào</td></tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%-- ══ LỆNH XUẤT ══ --%>
<% if ("lenhxuat".equals(tab)) { %>
<div class="card" id="formLenh" style="display:none;border:2px solid #f59e0b;margin-bottom:20px">
    <div class="card-title" style="margin-bottom:4px;color:#92400e">&#9889; Xử lý lệnh: <span id="lblLenh"></span></div>
    <div class="card-sub" style="margin-bottom:16px">Chọn vật tư và số lượng thực tế xuất — tồn kho sẽ bị trừ ngay</div>
    <form action="<%= ctx %>/kho/lenhxuat" method="post" onsubmit="return validateLenh()">
        <input type="hidden" name="action"  value="xuLyXuat">
        <input type="hidden" name="maLenh"  id="inpLenh">
        <input type="hidden" name="maKho"   id="inpKho">
        <input type="hidden" name="maPX"    id="inpPX">
        <div style="overflow-x:auto;margin-bottom:12px">
            <table style="width:100%;border-collapse:collapse">
                <thead>
                    <tr style="background:#fef9c3">
                        <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #fcd34d">VẬT TƯ <span style="color:red">*</span></th>
                        <th style="padding:10px;text-align:left;font-size:12px;color:#64748b;border-bottom:1px solid #fcd34d;width:200px">SỐ LƯỢNG XUẤT <span style="color:red">*</span></th>
                        <th style="padding:10px;width:44px;border-bottom:1px solid #fcd34d"></th>
                    </tr>
                </thead>
                <tbody id="tbodyLenh">
                <tr>
                    <td style="padding:8px 6px">
                        <select name="maVT[]" class="form-control" required>
                            <option value="">-- Chọn vật tư --</option>
                            <% if (danhSachVatTu != null) for (Map<String,String> v : danhSachVatTu) { %>
                            <option value="<%= v.get("maVT") %>">[<%= v.get("maVT") %>] <%= v.get("tenVT") %><% if (!v.get("donViTinh").isEmpty()) { %> (<%= v.get("donViTinh") %>)<% } %></option>
                            <% } %>
                        </select>
                    </td>
                    <td style="padding:8px 6px">
                        <input type="number" name="soLuong[]" class="form-control" min="0.01" step="0.01" placeholder="Nhập số lượng" required>
                    </td>
                    <td style="padding:8px 6px;text-align:center">
                        <button type="button" onclick="xoaDong(this)" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:18px">&#10005;</button>
                    </td>
                </tr>
                </tbody>
            </table>
        </div>
        <button type="button" class="btn btn-outline" style="margin-bottom:12px;font-size:13px"
                onclick="themDong('tbodyLenh','lenh')">+ Thêm vật tư</button>
        <div id="errLenh" style="color:#ef4444;font-size:13px;margin-bottom:10px;display:none"></div>
        <div style="display:flex;gap:10px">
            <button type="submit" class="btn btn-primary">&#10003; Xác nhận xuất kho</button>
            <button type="button" class="btn btn-outline" onclick="document.getElementById('formLenh').style.display='none'">Hủy</button>
        </div>
    </form>
</div>

<div class="card">
    <div class="card-header">
        <div><div class="card-title">Lệnh xuất chờ xử lý</div><div class="card-sub">Yêu cầu từ phân xưởng</div></div>
    </div>
    <table>
        <thead><tr><th>Mã lệnh</th><th>Phân xưởng</th><th>Vật tư yêu cầu</th><th>Ngày yêu cầu</th><th>Ưu tiên</th><th>Thao tác</th></tr></thead>
        <tbody>
            <tr>
                <td><strong>LX-001</strong></td><td>PX01 – Phân xưởng 1</td>
                <td>Xi măng, Sắt phi 16</td><td>2026-03-10</td>
                <td><span class="badge badge-red">Cao</span></td>
                <td><button class="btn btn-primary" style="padding:6px 14px;font-size:13px" onclick="moLenh('LX-001','KHO01','PX01')">Xử lý xuất</button></td>
            </tr>
            <tr>
                <td><strong>LX-002</strong></td><td>PX02 – Phân xưởng 2</td>
                <td>Cát vàng</td><td>2026-03-10</td>
                <td><span class="badge badge-yellow">Trung bình</span></td>
                <td><button class="btn btn-primary" style="padding:6px 14px;font-size:13px" onclick="moLenh('LX-002','KHO02','PX02')">Xử lý xuất</button></td>
            </tr>
        </tbody>
    </table>
</div>
<% } %>

<script>
function ft(tid,sid){
    const q=document.getElementById(sid).value.toLowerCase();
    document.querySelectorAll('#'+tid+' tbody tr').forEach(r=>r.style.display=r.textContent.toLowerCase().includes(q)?'':'none');
}
function xoaDong(btn){
    const tb=btn.closest('tr').parentElement;
    if(tb.children.length>1) btn.closest('tr').remove();
    else alert('Phải có ít nhất 1 dòng vật tư!');
}
function getOpts(tbodyId){
    const s=document.querySelector('#'+tbodyId+' select[name="maVT[]"]');
    return s?s.innerHTML:'';
}
function themDong(tbodyId,loai){
    const opts=getOpts(tbodyId);
    const tbody=document.getElementById(tbodyId);
    const tr=document.createElement('tr');
    let cols='';
    if(loai==='nhap'){
        cols=`<td style="padding:8px 6px"><input type="number" name="soLuongDat[]" class="form-control" min="0" step="0.01" value="0"></td>
              <td style="padding:8px 6px"><input type="number" name="soLuongNhan[]" class="form-control" min="0.01" step="0.01" placeholder="0" required></td>`;
    } else {
        cols=`<td style="padding:8px 6px"><input type="number" name="soLuong[]" class="form-control" min="0.01" step="0.01" placeholder="Nhập số lượng" required></td>`;
    }
    tr.innerHTML=`<td style="padding:8px 6px"><select name="maVT[]" class="form-control" required>${opts}</select></td>${cols}
        <td style="padding:8px 6px;text-align:center"><button type="button" onclick="xoaDong(this)" style="background:none;border:none;color:#ef4444;cursor:pointer;font-size:18px">&#10005;</button></td>`;
    tbody.appendChild(tr);
}
function validateForm(tbodyId,errId,slName){
    const rows=document.querySelectorAll('#'+tbodyId+' tr');
    const el=document.getElementById(errId);
    let ok=true;
    rows.forEach(r=>{
        const sel=r.querySelector('select[name="maVT[]"]');
        const sl=r.querySelector('input[name="'+slName+'"]');
        if(sel&&!sel.value) ok=false;
        if(sl&&(!sl.value||parseFloat(sl.value)<=0)) ok=false;
    });
    el.style.display=ok?'none':'block';
    if(!ok) el.textContent='Vui lòng chọn vật tư và nhập số lượng hợp lệ (> 0) cho tất cả các dòng!';
    return ok;
}
function validateNhap(){ return validateForm('tbodyNhap','errNhap','soLuongNhan[]'); }
function validateXuat(){ return validateForm('tbodyXuat','errXuat','soLuong[]'); }
function validateLenh(){ return validateForm('tbodyLenh','errLenh','soLuong[]'); }
function moLenh(maLenh,maKho,maPX){
    document.getElementById('inpLenh').value=maLenh;
    document.getElementById('inpKho').value=maKho;
    document.getElementById('inpPX').value=maPX;
    document.getElementById('lblLenh').textContent=maLenh+' → '+maKho+' → '+maPX;
    const f=document.getElementById('formLenh');
    f.style.display='block';
    f.scrollIntoView({behavior:'smooth',block:'start'});
}
</script>

<%@ include file="/WEB-INF/footer.jsp" %>
