package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        "jdbc:mariadb://localhost:3307/quanlykho"
        + "?useUnicode=true&characterEncoding=UTF-8"
        + "&connectTimeout=3000";

    private static final String USER     = "root";
    private static final String PASSWORD = "";   // WampServer mặc định trống

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy mariadb-java-client.jar! "
                    + "Chuột phải Libraries → Add JAR → chọn file jar.", e);
        }
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    // Chuột phải file → Run File để test kết nối
    public static void main(String[] args) {
        System.out.println("Đang kết nối: localhost:3307/quanlykho ...");
        try (Connection conn = getConnection()) {
            System.out.println("✅ Kết nối THÀNH CÔNG!");
            System.out.println("   Driver : " + conn.getMetaData().getDriverName());
            System.out.println("   DB     : " + conn.getCatalog());
            System.out.println("   Version: " + conn.getMetaData().getDatabaseProductVersion());
        } catch (SQLException e) {
            System.err.println("❌ Kết nối THẤT BẠI: " + e.getMessage());
        }
    }
}
