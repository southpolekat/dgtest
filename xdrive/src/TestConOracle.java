import java.sql.*;  
class TestConOracle{  
   public static void main(String args[]){  
      try {  
         Class.forName("oracle.jdbc.OracleDriver");  

         Connection con=DriverManager.getConnection(  
            "jdbc:oracle:thin:@//oracle1:1521/ORCLCDB.localdomain","test_user","test_passwd");  

         Statement stmt=con.createStatement();  
         ResultSet rs=stmt.executeQuery("select * from test_table");  
         while(rs.next())  
            System.out.println(rs.getInt(1));  
         con.close();  
       } catch(Exception e){ System.out.println(e);}  
   }  
}  
