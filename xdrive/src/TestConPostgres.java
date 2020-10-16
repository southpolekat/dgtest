import java.sql.*;  
class TestConPostgres{  
   public static void main(String args[]){  
      try {  
         Class.forName("org.postgresql.Driver");  

         Connection con=DriverManager.getConnection(  
            "jdbc:postgresql://my_pg9:5432/test_db?user=test_user&password=test_passwd"
            //"jdbc:postgresql://my_pg9:5432/test_db", "test_user", "test_passwd"
            );  

         Statement stmt=con.createStatement();  
         ResultSet rs=stmt.executeQuery("select * from test_table");  
         while(rs.next())  
            System.out.println(rs.getInt(1));  
         con.close();  
       } catch(Exception e){ System.out.println(e);}  
   }  
}  
