import java.sql.*;  

class TestConMssql{  
   public static void main(String args[]){  
      try {  
         Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");  

         Connection con=DriverManager.getConnection(  
            "jdbc:sqlserver://my_mssql:1433;databaseName=test_db;user=sa;password=Test_Passwd123");  

         Statement stmt=con.createStatement();  
         ResultSet rs=stmt.executeQuery("select top 3 * from test_table;");  
         while(rs.next())  
            System.out.println(rs.getInt(1));  
         con.close();  
       } catch(Exception e){ System.out.println(e);}  
   }  
}  
