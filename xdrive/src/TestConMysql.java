import java.sql.*;  
class TestConMysql{  
   public static void main(String args[]){  
      try {  
         Class.forName("com.mysql.jdbc.Driver");  

         Connection con=DriverManager.getConnection(  
            "jdbc:mysql://mysql1:3306/test_db?useSSL=false","test_user","test_passwd");  

         Statement stmt=con.createStatement();  
         ResultSet rs=stmt.executeQuery("select * from test_table limit 3;");  
         while(rs.next())  
            System.out.println(rs.getInt(1));  
         con.close();  
       } catch(Exception e){ System.out.println(e);}  
   }  
}  
