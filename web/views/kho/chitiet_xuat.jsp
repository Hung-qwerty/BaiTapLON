<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    Map<String,String> phieu = (Map<String,String>) request.getAttribute("phieu");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> chiTiet = (List<Map<String,String>>) request.getAttribute("chiTiet");
    String ctx = request.getContextPath();
    if (phieu == null) {
        response.sendRedirect(ctx + "/kho/xuathang");
        return;
    }
%>
<%@ include file="/WEB-INF/header.jsp" %>

<div style="margin-bottom:16px">
    <a href="<%= ctx %>/kho/xuathang" class="btn btn-outline" style="font-size:13px">&#8592; Quay lại</a>
</div>

<div class="card">
    <div class="card-title" style="margin-bottom:20px">Chi tiết phiếu xuất: <strong><%= phieu.get("maXK") %></strong></div>
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:24px">
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Kho xuất</div><div><span class="badge badge-blue"><%= phieu.get("maKho") %></span></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Phân xưởng</div><div style="font-weight:600"><%= phieu.get("tenPX") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Ngày xuất</div><div style="font-weight:600"><%= phieu.get("ngayXuat") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Người xuất</div><div style="font-weight:600"><%= phieu.get("nguoiXuat") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Trạng thái</div>
            <span class="badge <%= "DA_XUAT".equals(phieu.get("trangThai")) ? "badge-green" : "badge-yellow" %>">
                <%= phieu.get("trangThai") %>
            </span>
        </div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Ghi chú</div><div><%= phieu.get("ghiChu").isEmpty() ? "—" : phieu.get("ghiChu") %></div></div>
    </div>

    <div style="font-weight:700;font-size:14px;margin-bottom:12px">Danh sách vật tư xuất</div>
    <table>
        <thead><tr><th>Mã vật tư</th><th>Tên vật tư</th><th>Đơn vị</th><th>Số lượng xuất</th></tr></thead>
        <tbody>
        <% if (chiTiet != null && !chiTiet.isEmpty()) {
               for (Map<String,String> ct : chiTiet) { %>
        <tr>
            <td><strong><%= ct.get("maVT") %></strong></td>
            <td><%= ct.get("tenVT") %></td>
            <td><%= ct.get("donViTinh") %></td>
            <td><strong><%= ct.get("soLuong") %></strong></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="4" style="text-align:center;color:#94a3b8;padding:24px">Chưa có chi tiết vật tư</td></tr>
        <% } %>
        </tbody>
    </table>
</div>

<%@ include file="/WEB-INF/footer.jsp" %>
