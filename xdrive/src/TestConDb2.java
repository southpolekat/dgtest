import java.sql.*;  
class TestConDb2{  
   public static void main(String args[]){  
      try {  
         Class.forName("com.ibm.db2.jcc.DB2Driver");  

         Connection con=DriverManager.getConnection(  
            //"jdbc:db2://my_db2:50000/test_db","db2inst1","test_passwd"
            "jdbc:db2://my_db2:50000/test_db:user=db2inst1;password=test_passwd;"
            );  

         Statement stmt=con.createStatement();  
         ResultSet rs=stmt.executeQuery("select * from test_table");  
         while(rs.next())  
            System.out.println(rs.getInt(1));  
         con.close();  
       } catch(Exception e){ System.out.println(e);}  
   }  
}  
