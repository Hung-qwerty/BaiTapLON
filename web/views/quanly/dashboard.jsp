<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "tongquan";
    String ctx = request.getContextPath();

    String tongDoanhThu = (String) request.getAttribute("tongDoanhThu");
    String tongMatHang  = (String) request.getAttribute("tongMatHang");
    Integer soBoPhan    = (Integer) request.getAttribute("soBoPhan");
    Integer tongNhanVien= (Integer) request.getAttribute("tongNhanVien");
    if (tongDoanhThu == null) tongDoanhThu = "0 đ";
    if (tongMatHang  == null) tongMatHang  = "0";
    if (soBoPhan     == null) soBoPhan     = 0;
    if (tongNhanVien == null) tongNhanVien  = 0;

    String doanhThuData = (String) request.getAttribute("doanhThuData");
    String tonKhoData   = (String) request.getAttribute("tonKhoData");
    Double maxDT        = (Double) request.getAttribute("maxDT");
    Double maxTK        = (Double) request.getAttribute("maxTK");
    if (doanhThuData == null) doanhThuData = "[0,0,0,0,0,0]";
    if (tonKhoData   == null) tonKhoData   = "[0,0,0,0,0,0]";
    if (maxDT        == null) maxDT        = 300.0;
    if (maxTK        == null) maxTK        = 600.0;

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> danhSachBoPhan  = (List<Map<String,Object>>) request.getAttribute("danhSachBoPhan");
    @SuppressWarnings("unchecked")
    List<Map<String,String>> danhSachThongBao= (List<Map<String,String>>) request.getAttribute("danhSachThongBao");

    Integer soMatHangThieu = (Integer) request.getAttribute("soMatHangThieu");
    Integer soDonChoDuyet  = (Integer) request.getAttribute("soDonChoDuyet");
    Integer soPhieuSaiLech = (Integer) request.getAttribute("soPhieuSaiLech");
    String giaTriTonKho    = (String) request.getAttribute("giaTriTonKho");
    String tongThanhToan   = (String) request.getAttribute("tongThanhToan");
    Integer soHoaDonChuaTT = (Integer) request.getAttribute("soHoaDonChuaTT");
%>
<%@ include file="/WEB-INF/header.jsp" %>

<!-- STAT CARDS -->
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-label">Tổng doanh thu <span>&#128176;</span></div>
        <div class="stat-value"><%= tongDoanhThu %></div>
        <div class="stat-sub">Tổng giá trị đơn hàng</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Mặt hàng <span>&#128230;</span></div>
        <div class="stat-value"><%= tongMatHang %></div>
        <div class="stat-sub">Đang quản lý</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Bộ phận <span>&#127981;</span></div>
        <div class="stat-value"><%= soBoPhan %></div>
        <div class="stat-sub">Trên tất cả các bộ phận</div>
    </div>
    <div class="stat-card">
        <div class="stat-label">Nhân viên <span>&#128101;</span></div>
        <div class="stat-value"><%= tongNhanVien %></div>
        <div class="stat-sub">Nhân viên hoạt động</div>
    </div>
</div>

<!-- TABS -->
<div class="tabs">
    <a href="<%= ctx %>/quanly/dashboard?tab=tongquan"  class="tab-btn <%= "tongquan".equals(tab) ?"active":"" %>">Tổng quan</a>
    <a href="<%= ctx %>/quanly/dashboard?tab=bophan"    class="tab-btn <%= "bophan".equals(tab)   ?"active":"" %>">Bộ phận</a>
    <a href="<%= ctx %>/quanly/dashboard?tab=thongbao"  class="tab-btn <%= "thongbao".equals(tab) ?"active":"" %>">Thông báo</a>
    <a href="<%= ctx %>/quanly/dashboard?tab=baocao"    class="tab-btn <%= "baocao".equals(tab)   ?"active":"" %>">Báo cáo</a>
</div>

<%-- ══ TỔNG QUAN ══ --%>
<% if ("tongquan".equals(tab)) { %>
<div class="chart-grid">
    <!-- Biểu đồ doanh thu -->
    <div class="chart-card">
        <div class="card-title" style="margin-bottom:4px">Hiệu suất kinh doanh</div>
        <div class="card-sub" style="margin-bottom:16px">Giá trị đơn hàng theo tháng (triệu đồng)</div>
        <canvas id="chartDT" width="500" height="200" style="width:100%;height:200px"></canvas>
        <div style="display:flex;justify-content:space-between;font-size:12px;color:#64748b;margin-top:8px;padding:0 4px">
            <span>T1</span><span>T2</span><span>T3</span><span>T4</span><span>T5</span><span>T6</span>
        </div>
    </div>
    <!-- Biểu đồ tồn kho -->
    <div class="chart-card">
        <div class="card-title" style="margin-bottom:4px">Xu hướng nhập kho</div>
        <div class="card-sub" style="margin-bottom:16px">Số lượng nhập theo tháng (đơn vị)</div>
        <canvas id="chartTK" width="500" height="200" style="width:100%;height:200px"></canvas>
        <div style="display:flex;justify-content:space-between;font-size:12px;color:#64748b;margin-top:8px;padding:0 4px">
            <span>T1</span><span>T2</span><span>T3</span><span>T4</span><span>T5</span><span>T6</span>
        </div>
    </div>
</div>

<script>
const dtData = <%= doanhThuData %>;
const tkData = <%= tonKhoData %>;
const maxDT  = <%= maxDT %> || 300;
const maxTK  = <%= maxTK %> || 600;

function drawBar(canvasId, data, maxVal, color) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const W = canvas.offsetWidth || 500;
    const H = 200;
    canvas.width  = W;
    canvas.height = H;
    ctx.clearRect(0, 0, W, H);

    const pad  = 20;
    const gap  = 8;
    const n    = data.length;
    const bw   = (W - pad * 2 - gap * (n - 1)) / n;

    // Grid lines
    ctx.strokeStyle = '#f1f5f9';
    ctx.lineWidth   = 1;
    for (let i = 0; i <= 4; i++) {
        const y = pad + (H - pad * 2) * i / 4;
        ctx.beginPath(); ctx.moveTo(pad, y); ctx.lineTo(W - pad, y); ctx.stroke();
    }

    // Bars
    data.forEach((v, i) => {
        const barH = maxVal > 0 ? Math.max(2, (v / maxVal) * (H - pad * 2)) : 2;
        const x    = pad + i * (bw + gap);
        const y    = H - pad - barH;

        // Gradient fill
        const grad = ctx.createLinearGradient(0, y, 0, H - pad);
        grad.addColorStop(0, color + 'CC');
        grad.addColorStop(1, color + '44');
        ctx.fillStyle = grad;
        ctx.beginPath();
        ctx.roundRect ? ctx.roundRect(x, y, bw, barH, [4,4,0,0])
                      : ctx.rect(x, y, bw, barH);
        ctx.fill();

        // Value label
        if (v > 0) {
            ctx.fillStyle = '#374151';
            ctx.font      = '11px Segoe UI';
            ctx.textAlign = 'center';
            ctx.fillText(v.toFixed(0), x + bw / 2, y - 4);
        }
    });
}

function drawLine(canvasId, data, maxVal, color) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const W = canvas.offsetWidth || 500;
    const H = 200;
    canvas.width  = W;
    canvas.height = H;
    ctx.clearRect(0, 0, W, H);

    const pad = 24;
    const n   = data.length;
    if (n < 2) return;

    const xStep = (W - pad * 2) / (n - 1);
    const pts   = data.map((v, i) => ({
        x: pad + i * xStep,
        y: pad + (maxVal > 0 ? (1 - v / maxVal) : 0) * (H - pad * 2)
    }));

    // Grid
    ctx.strokeStyle = '#f1f5f9';
    ctx.lineWidth   = 1;
    for (let i = 0; i <= 4; i++) {
        const y = pad + (H - pad * 2) * i / 4;
        ctx.beginPath(); ctx.moveTo(pad, y); ctx.lineTo(W - pad, y); ctx.stroke();
    }

    // Fill area
    ctx.beginPath();
    ctx.moveTo(pts[0].x, H - pad);
    pts.forEach(p => ctx.lineTo(p.x, p.y));
    ctx.lineTo(pts[pts.length - 1].x, H - pad);
    ctx.closePath();
    const grad = ctx.createLinearGradient(0, pad, 0, H - pad);
    grad.addColorStop(0, color + '30');
    grad.addColorStop(1, color + '05');
    ctx.fillStyle = grad;
    ctx.fill();

    // Line
    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth   = 2.5;
    ctx.lineJoin    = 'round';
    pts.forEach((p, i) => i === 0 ? ctx.moveTo(p.x, p.y) : ctx.lineTo(p.x, p.y));
    ctx.stroke();

    // Dots + labels
    pts.forEach((p, i) => {
        ctx.beginPath();
        ctx.arc(p.x, p.y, 4, 0, Math.PI * 2);
        ctx.fillStyle   = color;
        ctx.fill();
        ctx.strokeStyle = '#fff';
        ctx.lineWidth   = 2;
        ctx.stroke();

        if (data[i] > 0) {
            ctx.fillStyle = '#374151';
            ctx.font      = '10px Segoe UI';
            ctx.textAlign = 'center';
            ctx.fillText(data[i].toFixed(0), p.x, p.y - 8);
        }
    });
}

window.addEventListener('load', () => {
    drawBar('chartDT', dtData, maxDT, '#f87171');
    drawLine('chartTK', tkData, maxTK, '#3b82f6');
});
</script>
<% } %>

<%-- ══ BỘ PHẬN ══ --%>
<% if ("bophan".equals(tab)) { %>
<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Hiệu suất các bộ phận</div>
            <div class="card-sub">Dữ liệu thực từ cơ sở dữ liệu</div>
        </div>
    </div>
    <table>
        <thead>
            <tr><th>Bộ phận</th><th>Nhân sự</th><th>Công việc</th><th>Hiệu suất</th><th>Trạng thái</th></tr>
        </thead>
        <tbody>
        <% if (danhSachBoPhan != null) for (Map<String,Object> b : danhSachBoPhan) {
               int hs = (Integer) b.get("hieuSuat");
               String pc  = hs >= 90 ? "progress-green" : hs >= 70 ? "progress-yellow" : "progress-yellow";
               String bc2 = "Tốt".equals(b.get("trangThai")) ? "badge-dark"
                          : "Trung bình".equals(b.get("trangThai")) ? "badge-gray" : "badge-yellow";
        %>
        <tr>
            <td><strong><%= b.get("ten") %></strong></td>
            <td><%= b.get("nhanSu") %> người</td>
            <td><%= b.get("congViec") %></td>
            <td>
                <div class="progress-wrap">
                    <div class="progress-bar">
                        <div class="progress-fill <%= pc %>" style="width:<%= hs %>%"></div>
                    </div>
                    <strong><%= hs %>%</strong>
                </div>
            </td>
            <td><span class="badge <%= bc2 %>"><%= b.get("trangThai") %></span></td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>
<% } %>

<%-- ══ THÔNG BÁO ══ --%>
<% if ("thongbao".equals(tab)) { %>

<!-- Summary cards -->
<div class="stats-grid" style="margin-bottom:20px">
    <div class="stat-card" style="border-left:4px solid #f59e0b">
        <div class="stat-label">Tồn kho thấp <span>&#9888;</span></div>
        <div class="stat-value" style="color:#d97706"><%= soMatHangThieu != null ? soMatHangThieu : 0 %></div>
        <div class="stat-sub">Mặt hàng dưới mức tối thiểu</div>
    </div>
    <div class="stat-card" style="border-left:4px solid #3b82f6">
        <div class="stat-label">Chờ duyệt <span>&#128336;</span></div>
        <div class="stat-value" style="color:#2563eb"><%= soDonChoDuyet != null ? soDonChoDuyet : 0 %></div>
        <div class="stat-sub">Đơn hàng cần xử lý</div>
    </div>
    <div class="stat-card" style="border-left:4px solid #ef4444">
        <div class="stat-label">Sai lệch kho <span>&#10060;</span></div>
        <div class="stat-value" style="color:#dc2626"><%= soPhieuSaiLech != null ? soPhieuSaiLech : 0 %></div>
        <div class="stat-sub">Phiếu nhập sai lệch</div>
    </div>
    <div class="stat-card" style="border-left:4px solid #22c55e">
        <div class="stat-label">Hệ thống <span>&#9989;</span></div>
        <div class="stat-value" style="color:#16a34a">OK</div>
        <div class="stat-sub">Đang hoạt động bình thường</div>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <div>
            <div class="card-title">Thông báo hệ thống</div>
            <div class="card-sub">Các cảnh báo và sự kiện từ cơ sở dữ liệu</div>
        </div>
    </div>
    <div class="notif-list">
    <% if (danhSachThongBao != null && !danhSachThongBao.isEmpty()) {
           for (Map<String,String> tb2 : danhSachThongBao) {
               String loai = tb2.get("loai");
               String cls  = "warn".equals(loai) ? "notif-warn"
                           : "info".equals(loai) ? "notif-info"
                           : "err".equals(loai)  ? "notif-err"
                           : "notif-ok";
    %>
        <div class="notif-item <%= cls %>">
            <div>
                <div class="notif-msg"><%= tb2.get("icon") %> <%= tb2.get("msg") %></div>
                <div class="notif-time"><%= tb2.get("time") %></div>
            </div>
            <% if ("warn".equals(loai) || "err".equals(loai) || "info".equals(loai)) { %>
            <a href="<%= ctx %>/kho/tonkho" class="btn-link" style="white-space:nowrap">Xem</a>
            <% } %>
        </div>
    <% } } else { %>
        <div class="notif-item notif-ok">
            <div>
                <div class="notif-msg">✅ Hệ thống đang hoạt động bình thường</div>
                <div class="notif-time">Hôm nay</div>
            </div>
        </div>
    <% } %>
    </div>
</div>
<% } %>

<%-- ══ BÁO CÁO ══ --%>
<% if ("baocao".equals(tab)) { %>

<!-- Tóm tắt số liệu -->
<div class="card" style="margin-bottom:20px">
    <div class="card-title" style="margin-bottom:16px">Tóm tắt tài chính</div>
    <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:20px">
        <div style="text-align:center;padding:16px;background:#f8fafc;border-radius:10px">
            <div style="font-size:12px;color:#64748b;margin-bottom:8px">Tổng doanh thu</div>
            <div style="font-size:22px;font-weight:700;color:#0f172a"><%= tongDoanhThu %></div>
        </div>
        <div style="text-align:center;padding:16px;background:#f0fdf4;border-radius:10px">
            <div style="font-size:12px;color:#64748b;margin-bottom:8px">Đã thanh toán</div>
            <div style="font-size:22px;font-weight:700;color:#16a34a"><%= tongThanhToan != null ? tongThanhToan : "0 đ" %></div>
        </div>
        <div style="text-align:center;padding:16px;background:#<%= soHoaDonChuaTT != null && soHoaDonChuaTT > 0 ? "fff7ed" : "f8fafc" %>;border-radius:10px">
            <div style="font-size:12px;color:#64748b;margin-bottom:8px">HĐ chưa thanh toán</div>
            <div style="font-size:22px;font-weight:700;color:<%= soHoaDonChuaTT != null && soHoaDonChuaTT > 0 ? "#ea580c" : "#0f172a" %>">
                <%= soHoaDonChuaTT != null ? soHoaDonChuaTT : 0 %> hóa đơn
            </div>
        </div>
    </div>
</div>

<!-- Các loại báo cáo -->
<div class="card">
    <div class="card-title" style="margin-bottom:4px">Báo cáo tổng hợp</div>
    <div class="card-sub" style="margin-bottom:20px">Tạo và tải xuống báo cáo quản lý</div>
    <div class="report-grid">
        <div class="report-card" onclick="alert('Tính năng xuất báo cáo sẽ được phát triển thêm')">
            <div class="r-icon">&#128202;</div>
            <div class="r-title">Báo cáo hiệu suất</div>
            <div class="r-sub">Tháng này</div>
        </div>
        <div class="report-card" onclick="window.location='<%= ctx %>/kho/tonkho'">
            <div class="r-icon">&#128230;</div>
            <div class="r-title">Báo cáo tồn kho</div>
            <div class="r-sub">Xem tồn kho hiện tại</div>
        </div>
        <div class="report-card" onclick="alert('Tính năng xuất báo cáo sẽ được phát triển thêm')">
            <div class="r-icon">&#128181;</div>
            <div class="r-title">Báo cáo tài chính</div>
            <div class="r-sub">Quý này</div>
        </div>
    </div>
</div>
<% } %>

<%@ include file="/WEB-INF/footer.jsp" %>
