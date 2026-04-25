<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập – Quản lý kho hàng</title>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            min-height: 100vh;
            background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 50%, #0f172a 100%);
            display: flex; align-items: center; justify-content: center;
        }
        .login-box {
            background: rgba(255,255,255,0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.10);
            border-radius: 20px;
            padding: 48px 44px;
            width: 420px;
            animation: fadeUp .5s ease;
        }
        @keyframes fadeUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
        .logo-wrap  { text-align: center; margin-bottom: 36px; }
        .logo-icon  { width:60px;height:60px;background:#2563eb;border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:28px;margin:0 auto 14px; }
        .logo-title { color:#f1f5f9;font-size:22px;font-weight:700; }
        .logo-sub   { color:#64748b;font-size:13px;margin-top:4px; }
        .form-group { margin-bottom: 16px; }
        .form-label { color:#94a3b8;font-size:13px;font-weight:500;display:block;margin-bottom:8px; }
        .form-input {
            width:100%;padding:12px 16px;
            background:rgba(255,255,255,0.07);
            border:1px solid rgba(255,255,255,0.12);
            border-radius:10px;color:#f1f5f9;font-size:14px;outline:none;
            transition:border-color .2s,box-shadow .2s;
        }
        .form-input::placeholder { color:#475569; }
        .form-input:focus { border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.18); }
        .pass-wrap { position:relative; }
        .pass-wrap input { padding-right:44px; }
        .pass-toggle { position:absolute;right:14px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;color:#64748b;font-size:16px; }
        .error-msg  { background:rgba(239,68,68,.15);border:1px solid rgba(239,68,68,.3);border-radius:8px;padding:10px 14px;color:#fca5a5;font-size:13px;margin-bottom:16px; }
        .btn-login  { width:100%;padding:13px;background:#2563eb;color:#fff;border:none;border-radius:10px;font-weight:700;font-size:15px;cursor:pointer;transition:background .2s;margin-top:8px; }
        .btn-login:hover { background:#1d4ed8; }
        .demo-box   { margin-top:24px;padding:14px 16px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:10px; }
        .demo-title { color:#475569;font-size:11px;font-weight:600;letter-spacing:1px;text-transform:uppercase;margin-bottom:10px; }
        .demo-grid  { display:grid;grid-template-columns:1fr 1fr;gap:6px; }
        .demo-item  { padding:6px 8px;border-radius:6px;cursor:pointer;font-size:12px;color:#94a3b8;transition:background .15s; }
        .demo-item:hover { background:rgba(255,255,255,0.07); }
        .demo-item span  { color:#60a5fa; }
    </style>
</head>
<body>
<div class="login-box">
    <div class="logo-wrap">
        <div class="logo-icon">&#127981;</div>
        <div class="logo-title">Quản lý kho hàng</div>
        <div class="logo-sub">Đăng nhập để tiếp tục</div>
    </div>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
    <div class="error-msg">&#10060; <%= error %></div>
    <% } %>

    <form action="<%= request.getContextPath() %>/login" method="post">
        <div class="form-group">
            <label class="form-label">Tên đăng nhập</label>
            <input type="text" name="username" class="form-input"
                   placeholder="Nhập tên đăng nhập" required autofocus>
        </div>
        <div class="form-group">
            <label class="form-label">Mật khẩu</label>
            <div class="pass-wrap">
                <input type="password" name="password" id="passInput" class="form-input"
                       placeholder="Nhập mật khẩu" required>
                <button type="button" class="pass-toggle" onclick="togglePass()">&#128065;</button>
            </div>
        </div>
        <button type="submit" class="btn-login">Đăng nhập</button>
    </form>

    <div class="demo-box">
        <div class="demo-title">Tài khoản demo</div>
        <div class="demo-grid">
            <div class="demo-item" onclick="fill('admin','admin123')"><span>admin</span> · Quản trị</div>
            <div class="demo-item" onclick="fill('muahang.an','123456')"><span>muahang.an</span> · Mua hàng</div>
            <div class="demo-item" onclick="fill('kho.cuong','123456')"><span>kho.cuong</span> · Kho</div>
            <div class="demo-item" onclick="fill('quanly.hai','123456')"><span>quanly.hai</span> · Quản lý</div>
        </div>
    </div>
</div>
<script>
function fill(u,p){
    document.querySelector('[name=username]').value=u;
    document.querySelector('[name=password]').value=p;
}
function togglePass(){
    const i=document.getElementById('passInput');
    i.type=i.type==='password'?'text':'password';
}
</script>
</body>
</html>
