/* ====================================================================
				Name : Avijit Pakhira
				Date : 19 Nov, 2026
				Description : Assignment III
==================================================================== */

/* 1. What will be the output of the below query, given an Employee table having 10 records?        
            BEGIN TRAN 
                TRUNCATE TABLE Employees 
                ROLLBACK 
            END TRAN 
            SELECT * FROM Employees                                                                         */
   Ans: returning the original 10 records of the table Employees


/* 2. Write an SQL query to display the text CAPONE as following:          
                    C 
                    A 
                    P 
                    O 
                    N 
                    E                                                                                       */

/* 3. Let us have a table with the following data:                                                                                                
 
    CourseID    Course Name 
    1                 .Net 
    2                 SQL Server 
    3                 SSRS 
    4                 SharePoint 
    5                 WCF 
    We need to concatenate the Course Name column like the following: 
    .Net, SQL Server, SSRS, SharePoint, WCF                                                                     */


    
/* 4. Create a stored procedure to print total number of patients and their average age 
    to a specific doctor. The procedure should return total number of patients and their average age.          */
    
    USE Hospital;


/* 5. Create a stored procedure with input student ID, course ID and enrolment date  to enrol a student 
    in multiple courses simultaneously while ensuring that all enrollments are successful or rolled back in 
    case of any failure.                                                                                           */

/* 6. Create stored procedure to place an order and corresponding entry should be done in all tables like order, 
    order items, stock.                                                                                            */

/* 7. Create stored procedure to take input parameter passenger id to retrieve booking details for a specific 
    passenger and returns output parameters to provide information about the number of bookings and the total 
    amount spent by the passenger.                                                                                 */

/* 8. Suppose there is table named sales that stores information about sales transactions, including the 
    sales ID, Sales Date, Customer ID, Product ID, and the Total Amount. Create indexes on the columns frequently 
    used in the WHERE clause or JOIN conditions like sales date, customer id, product id using covering index.          */


/* 9. Insert multiple transactions for different accounts and ensures that if any transaction fails, all the 
    previous inserts are rolled back. Handle exceptions.                                                            */

/* 10. Create a clustered index on the Customer ID column and create a non-clustered index on multiple columns 
    to optimize queries that filter by more than one column.                                                        */




                                
