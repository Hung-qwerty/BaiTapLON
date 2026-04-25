<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    Map<String,String> phieu = (Map<String,String>) request.getAttribute("phieu");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> chiTiet = (List<Map<String,String>>) request.getAttribute("chiTiet");
    String ctx = request.getContextPath();
    if (phieu == null) {
        response.sendRedirect(ctx + "/kho/nhaphang");
        return;
    }
%>
<%@ include file="/WEB-INF/header.jsp" %>

<div style="margin-bottom:16px">
    <a href="<%= ctx %>/kho/nhaphang" class="btn btn-outline" style="font-size:13px">&#8592; Quay lại</a>
</div>

<div class="card">
    <div class="card-title" style="margin-bottom:20px">Chi tiết phiếu nhập: <strong><%= phieu.get("maNK") %></strong></div>
    <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;margin-bottom:24px">
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Đơn hàng</div><div style="font-weight:600"><%= phieu.get("maDH") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Nhà cung cấp</div><div style="font-weight:600"><%= phieu.get("tenNCC") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Kho nhập</div><div><span class="badge badge-blue"><%= phieu.get("maKho") %></span></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Ngày nhập</div><div style="font-weight:600"><%= phieu.get("ngayNhap") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Người nhập</div><div style="font-weight:600"><%= phieu.get("nguoiNhap") %></div></div>
        <div><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Trạng thái</div>
            <span class="badge <%= "NHAP_DU".equals(phieu.get("trangThaiRaw")) ? "badge-green" : "SAI_LECH".equals(phieu.get("trangThaiRaw")) ? "badge-red" : "badge-yellow" %>">
                <%= phieu.get("trangThai") %>
            </span>
        </div>
        <div style="grid-column:1/-1"><div style="font-size:12px;color:#94a3b8;margin-bottom:4px">Ghi chú</div><div><%= phieu.get("ghiChu").isEmpty() ? "—" : phieu.get("ghiChu") %></div></div>
    </div>

    <div style="font-weight:700;font-size:14px;margin-bottom:12px">Danh sách vật tư nhập</div>
    <table>
        <thead><tr><th>Mã vật tư</th><th>Tên vật tư</th><th>Đơn vị</th><th>SL đặt</th><th>SL nhận</th><th>Chênh lệch</th></tr></thead>
        <tbody>
        <% if (chiTiet != null && !chiTiet.isEmpty()) {
               for (Map<String,String> ct : chiTiet) {
                   double cl = 0;
                   try { cl = Double.parseDouble(ct.get("chenhLech")); } catch(Exception e) {}
                   String clStyle = cl < 0 ? "color:#ef4444;font-weight:600" : cl > 0 ? "color:#22c55e;font-weight:600" : "";
        %>
        <tr>
            <td><strong><%= ct.get("maVT") %></strong></td>
            <td><%= ct.get("tenVT") %></td>
            <td><%= ct.get("donViTinh") %></td>
            <td><%= ct.get("soLuongDat") %></td>
            <td><%= ct.get("soLuongNhan") %></td>
            <td style="<%= clStyle %>"><%= ct.get("chenhLech") %></td>
        </tr>
        <% } } else { %>
        <tr><td colspan="6" style="text-align:center;color:#94a3b8;padding:24px">Chưa có chi tiết vật tư</td></tr>
        <% } %>
        </tbody>
    </table>
</div>

<%@ include file="/WEB-INF/footer.jsp" %>
