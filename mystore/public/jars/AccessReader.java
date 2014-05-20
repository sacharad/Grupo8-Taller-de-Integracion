/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package accessreader;
import com.healthmarketscience.jackcess.*;
import org.apache.commons.logging.*;
import org.apache.commons.lang.*;
import au.com.bytecode.opencsv.*;
import java.io.*;
import java.util.*; 
import java.sql.*; 
import java.nio.*;


/**
 *
 * @author Nicolás Escobar T
 */
public class AccessReader {

    /**
     * @param args the command line arguments
     * 
     */
    
    
    public static void main(String[] args) throws IOException {
       
        // TODO code application logic here
        System.out.println("Esto funciona");
        Database db = DatabaseBuilder.open(new File("DBPrecios.accdb")); // this is line nr 10 
        Table table = db.getTable("Pricing"); 
        String csv = "Data.csv";
        CSVWriter writer = new CSVWriter(new FileWriter(csv));
        List<String[]> data = new ArrayList<String[]>();
          
        for(Row row : table) {
            
              Object[] values = row.values().toArray();
              String [] datos= new String[values.length]; 
              for (int i=0; i<values.length; i++){
                  datos[i]= values[i].toString();
                          
              }
              data.add(datos); 
              System.out.println("Column 'a' has value: " + datos[0].toString());
              
             }
        
            writer.writeAll(data);
            writer.close();
             
        System.out.println("TERMINE");
        

    }
}
