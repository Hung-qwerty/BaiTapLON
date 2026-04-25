# HƯỚNG DẪN CÀI ĐẶT DỰ ÁN QuanLyKho
## NetBeans + Apache Tomcat + MariaDB (WampServer)

---

## CẤU TRÚC THƯ MỤC DỰ ÁN

```
QuanLyKho/
├── src/main/java/
│   ├── controller/
│   │   ├── AuthFilter.java        ← Kiểm tra session mọi request
│   │   ├── EncodingFilter.java    ← UTF-8 encoding
│   │   ├── LoginServlet.java      ← /login
│   │   ├── LogoutServlet.java     ← /logout
│   │   ├── MuaHangServlet.java    ← /muahang/*
│   │   ├── KhoServlet.java        ← /kho/*
│   │   ├── QuanLyServlet.java     ← /quanly/*
│   │   └── AdminServlet.java      ← /admin/*
│   ├── dao/
│   │   ├── TaiKhoanDAO.java
│   │   ├── DonHangDAO.java
│   │   └── NhaCungCapDAO.java
│   ├── model/
│   │   ├── TaiKhoan.java
│   │   └── DonHang.java
│   └── util/
│       └── DBConnection.java
│
└── web/
    ├── WEB-INF/
    │   ├── web.xml
    │   ├── header.jsp             ← Include vào đầu mỗi trang
    │   └── footer.jsp             ← Include vào cuối mỗi trang
    ├── css/
    │   └── style.css
    ├── js/
    │   └── main.js
    └── views/
        ├── login.jsp
        ├── muahang/
        │   └── dashboard.jsp
        ├── quanly/
        │   └── dashboard.jsp
        ├── kho/
        │   └── dashboard.jsp
        └── admin/
            └── accounts.jsp
```

---

## BƯỚC 1: TẠO DỰ ÁN TRONG NETBEANS

1. File → New Project → **Java Web → Web Application** → Next
2. Đặt tên: `QuanLyKho` → Next
3. Server: **Apache Tomcat** → Finish
4. Sao chép toàn bộ file theo cấu trúc trên vào dự án

---

## BƯỚC 2: THÊM MARIADB JDBC DRIVER

1. Tải: https://mariadb.com/downloads/connectors/
   → File: `mariadb-java-client-x.x.x.jar`

2. Trong NetBeans:
   - Chuột phải **Libraries** → **Add JAR/Folder**
   - Chọn file `.jar` vừa tải
   
3. Hoặc dùng MySQL Connector:
   https://dev.mysql.com/downloads/connector/j/
   → Đổi URL trong `DBConnection.java`:
   `jdbc:mysql://localhost:3306/QuanLyKho?...`
   và driver: `com.mysql.cj.jdbc.Driver`

---

## BƯỚC 3: IMPORT CƠ SỞ DỮ LIỆU

1. Bật WampServer → bật Apache + MySQL
2. Mở phpMyAdmin: http://localhost/phpmyadmin
3. Import file `quan_ly_kho.sql`

---

## BƯỚC 4: CẤU HÌNH KẾT NỐI

Mở `src/util/DBConnection.java`, chỉnh:
```java
private static final String URL  = "jdbc:mariadb://localhost:3306/QuanLyKho?...";
private static final String USER = "root";
private static final String PASSWORD = "";  // mặc định WampServer trống
```

---

## BƯỚC 5: CHẠY DỰ ÁN

1. Chuột phải project → **Clean and Build**
2. Chuột phải project → **Run**
3. Trình duyệt tự mở: `http://localhost:8080/QuanLyKho/login`

---

## URL CÁC TRANG

| URL | Mô tả |
|-----|-------|
| `/login` | Trang đăng nhập |
| `/logout` | Đăng xuất |
| `/muahang/dashboard` | Dashboard mua hàng |
| `/muahang/ncc` | Nhà cung cấp |
| `/muahang/taomoi` | Tạo đơn mới |
| `/kho/dashboard` | Dashboard kho |
| `/quanly/dashboard` | Dashboard quản lý |
| `/quanly/dashboard?tab=bophan` | Tab bộ phận |
| `/quanly/dashboard?tab=thongbao` | Tab thông báo |
| `/admin/accounts` | Quản lý tài khoản |

---

## TÀI KHOẢN MẶC ĐỊNH

| Username | Mật khẩu | Vai trò |
|----------|----------|---------|
| admin | admin123 | Quản trị |
| muahang.an | 123456 | Mua hàng |
| kho.cuong | 123456 | Kho |
| quanly.hai | 123456 | Quản lý |
| doichieu.em | 123456 | Đối chiếu |
| taivu.phuong | 123456 | Tài vụ |
| pxa.anh | 123456 | Phân xưởng |

---

## LỖI THƯỜNG GẶP

| Lỗi | Giải pháp |
|-----|-----------|
| `ClassNotFoundException: org.mariadb.jdbc.Driver` | Chưa thêm JAR vào Libraries |
| `Access denied for user 'root'` | Kiểm tra mật khẩu DB trong DBConnection.java |
| `404 /login` | Kiểm tra web.xml và Servlet annotation |
| Tiếng Việt bị lỗi | Đảm bảo file JSP có `<%@ page contentType="text/html;charset=UTF-8" %>` |
| Trang trắng sau login | Kiểm tra views JSP có đúng đường dẫn include header/footer |
