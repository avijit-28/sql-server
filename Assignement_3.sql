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
 DECLARE @str VARCHAR(20) = 'CAPONE'
 DECLARE @i INT = 1;
 while @i <= LEN(@str)
 BEGIN
    PRINT SUBSTRING(@str,@i,1)
    set @i = @i +1;
END;


/* 3. Let us have a table with the following data:                                                                                                
 
    CourseID    Course Name 
    1                 .Net 
    2                 SQL Server 
    3                 SSRS 
    4                 SharePoint 
    5                 WCF 
    We need to concatenate the Course Name column like the following: 
    .Net, SQL Server, SSRS, SharePoint, WCF                                                                     */
    use BikeStores
    Declare @CourseList Varchar(Max) = '';
    select @CourseList = @CourseList + [CourseName] + ', '
    from Courses
    print @CourseList
    
    
/* 4. Create a stored procedure to print total number of patients and their average age 
    to a specific doctor. The procedure should return total number of patients and their average age.          */
    
    USE Hospital;
    go
    ALTER PROCEDURE sp_GetTotalPatientAndAge 
        @doctor_id INT,
        @total_patient INT = NULL OUTPUT,
        @average_age DECIMAL(5, 2) = NULL OUTPUT
    AS 
    BEGIN
    DECLARE @doctor_name varchar(50)
    
    SELECT 
        @doctor_name = CONCAT('Dr. ', first_name, ' ', last_name)
        FROM [hpl].[Doctors]
        where @doctor_id = doctor_id

        IF @doctor_name IS NULL
            BEGIN
            PRINT 'Doctor ID ' + CAST(@doctor_id AS VARCHAR(10)) + ' does not exist.';
            RETURN
        END
        ELSE
            BEGIN
            PRINT ' Doctor: ' + @doctor_name + ' (ID: ' + CAST(@doctor_id AS VARCHAR(10)) + ')';
            END
    SELECT 
        @total_patient = COUNT(DISTINCT p.patient_id),
        @average_age = ISNULL(
                       AVG(
                       CAST(
                       DATEDIFF(MONTH,p.date_of_birth,GETDATE())/12 as DECIMAL(5, 2)))
                       ,00.0)
    FROM [hpl].[Patients] AS p
    INNER JOIN [hpl].[Appointments] AS a
    on a.patient_id = p.patient_id
    WHERE @doctor_id = a.doctor_id
    END;

    DECLARE @DoctorID INT = 55;
    DECLARE @PatientCount  INT;
    DECLARE @AvgAge DECIMAL(5, 2) ;

    EXEC sp_GetTotalPatientAndAge @DoctorID, @PatientCount OUTPUT, @AvgAge OUTPUT;

    
    PRINT ' Total Patients: ' + CAST(@PatientCount AS VARCHAR(10));
    PRINT ' Average Age:    ' + CAST(@AVGAge AS VARCHAR(10)) + ' years';

/* 5. Create a stored procedure with input student ID, course ID and enrolment date  to enrol a student 
    in multiple courses simultaneously while ensuring that all enrollments are successful or rolled back in 
    case of any failure.      
    */

    USE BikeStores;
    GO
    CREATE PROCEDURE sp_EnrollStudentMultipleCourses
        @StudentID INT,
        @CourseIDs VARCHAR(MAX),
        @EnrollmentDate DATE = NULL
    AS 
    BEGIN
        IF @EnrollmentDate IS NULL 
            SET @EnrollmentDate = CAST(GETDATE() AS DATE);

        BEGIN TRY
            BEGIN TRANSACTION;
            IF NOT EXISTS (SELECT 1 FROM [dbo].[Students] WHERE @StudentID = @StudentID)
            BEGIN
                RAISERROR('Validation Failed: Stuedent ID %d does not exist.',16,1,@StudentID);
            END;    

            DECLARE @SelectedCourses TABLE (CourseID INT);

            INSERT INTO @SelectedCourses (CourseID)
            SELECT CAST(TRIM(VALUE) AS INT)
            FROM string_split(@CourseIDs,',')
            WHERE TRIM(VALUE) <> '';

            DECLARE @InvalidCourseCount INT;
            SELECT @InvalidCourseCount = COUNT(*)
            FROM @SelectedCourses sc
            LEFT JOIN [dbo].[Courses] c ON sc.CourseID = c.CourseID
            WHERE c.CourseID IS NULL;
            IF @InvalidCourseCount > 0
            BEGIN
                RAISERROR('Validation Failed: One or more Course IDs are invalid.', 16, 1);
            END;
            INSERT INTO dbo.Enrollments (StudentID, CourseID, EnrollmentDate)
            SELECT @StudentID, sc.CourseID, @EnrollmentDate
            FROM @SelectedCourses sc;
        
            COMMIT TRANSACTION;
            PRINT 'SUCCESS: Student ID ' + CAST(@StudentID AS VARCHAR(10)) + 
              ' successfully enrolled in courses (' + @CourseIDs + ').';
        END TRY
        BEGIN CATCH
            IF (XACT_STATE() <> 0)
            BEGIN
                ROLLBACK TRANSACTION;
            END;
            PRINT 'FAILURE: Transaction rolled back! No enrollments were saved.';
            PRINT 'Error: ' + ERROR_MESSAGE();
        
            THROW;
        END CATCH
    END;

    --TEST 
    EXEC sp_EnrollStudentMultipleCourses 
        @StudentID = 1, 
        @CourseIDs = '4,1', 
        @EnrollmentDate = '2026-11-19';

    SELECT * FROM dbo.Enrollments WHERE StudentID = 1;
        

/* 6. Create stored procedure to place an order and corresponding entry should be done in all tables like order, 
    order items, stock.                                                                                            */

    --USE Assignment2;
    --GO
    ALTER PROCEDURE sp_PlaceOrder
        @CustomerID INT,
        @ProductID INT,
        @Quantity INT,
        @NewOrderID INT = NULL OUTPUT
    AS 
    BEGIN
        DECLARE @CurrentStock INT;
        DECLARE @UnitPrice DECIMAL(10,2);
        Declare @TotalAmount DECIMAL(10,2);

        BEGIN TRY
            BEGIN TRANSACTION;

            IF NOT EXISTS (SELECT 1 FROM dbo.Customers WHERE CustomerID = @CustomerID)
            BEGIN
                RAISERROR('Invalid Customer ID %d.', 16, 1, @CustomerID);
            END;

            Select @UnitPrice = UnitPrice
            from dbo.Products 
            where ProductID = @ProductID;

            IF @UnitPrice is NULL
            Begin
                RAISERROR('Invalid Product ID %d.', 16, 1, @ProductID);
            END;

            Select @CurrentStock = QuantityAvailable 
            from dbo.stock with (UPDLOCK)
            where ProductID = @ProductID;

            SET @CurrentStock = ISNULL(@CurrentStock, 0);

            if @CurrentStock < @Quantity
            BEGIN
            RAISERROR('Insufficient stock for Product ID %d. Requested: %d, Available: %d.', 
                      16, 1, @ProductID, @Quantity, @CurrentStock);
        END;

            set @TotalAmount = @UnitPrice * @Quantity;

            INSERT INTO dbo.Orders (CustomerID, OrderDate, TotalAmount)
            VALUES (@CustomerID, GETDATE(), @TotalAmount);

            Set @NewOrderID = SCOPE_IDENTITY();

            Insert into dbo.OrderItems (OrderID, ProductID, Quantity, UnitPrice)
            VALUES (@NewOrderID, @ProductID, @Quantity, @UnitPrice);

            UPDATE dbo.Stock
            SET QuantityAvailable = QuantityAvailable - @Quantity, LastUpdated = GETDATE()
            WHERE ProductID = @ProductID;

            COMMIT TRANSACTION;
            PRINT 'SUCCESS: Order #' + CAST(@NewOrderID AS VARCHAR(10)) + 
              ' placed successfully. Total: Rs. ' + CAST(@TotalAmount AS VARCHAR(20));
        END TRY
        BEGIN CATCH
            IF (XACT_STATE() <> 0)
                BEGIN
                ROLLBACK TRANSACTION;
                END;
            PRINT 'ORDER FAILED: Transaction rolled back.';
            PRINT 'Error: ' + ERROR_MESSAGE();

            THROW;
        END CATCH
    END;
    GO
           
    --Test
    DECLARE @GeneratedOrderID INT;

    EXEC sp_PlaceOrder 
        @CustomerID = 3,
        @ProductID  = 2,
        @Quantity   = 3,
        @NewOrderID = @GeneratedOrderID OUTPUT;
     
-- Verify results:
SELECT * FROM dbo.Orders WHERE OrderID = @GeneratedOrderID;
SELECT * FROM dbo.OrderItems WHERE OrderID = @GeneratedOrderID;
-- Stock for Product 1 should now be 8 (10 - 2):
SELECT * FROM dbo.Stock WHERE ProductID = 1;

        
    

/* 7. Create stored procedure to take input parameter passenger id to retrieve booking details for a specific 
    passenger and returns output parameters to provide information about the number of bookings and the total 
    amount spent by the passenger.                                                                                 */



/* 8. Suppose there is table named sales that stores information about sales transactions, including the 
    sales ID, Sales Date, Customer ID, Product ID, and the Total Amount. Create indexes on the columns frequently 
    used in the WHERE clause or JOIN conditions like sales date, customer id, product id using covering index.          */
    use Assignment2;
    create nonclustered index ix_Sales_Cust_Prod_Date 
    on dbo.Sales (CustomerID, ProductID, SalesDate)
    INCLUDE (TotalAmount);

    create nonclustered index ix_sales_cust_date
    on dbo.sales (CustomerID,SalesDate)
    include (productID, TotalAmount)

    create nonclustered index ix_sales_prod_date
    on dbo.sales (productID, SalesDate)
    include (CustomerID, TotalAmount)

    create nonclustered index ix_sales_date
    on dbo.sales (SalesDate)
    include (CustomerID, ProductID, TotalAmount)

    SELECT CustomerID, ProductID, SalesDate, TotalAmount
    FROM dbo.Sales
    WHERE CustomerID = 101 and productID = 501 and SalesDate >= '2026-11-01';

/* 9. Insert multiple transactions for different accounts and ensures that if any transaction fails, all the 
    previous inserts are rolled back. Handle exceptions. 
    */



/* 10. Create a clustered index on the Customer ID column and create a non-clustered index on multiple columns 
    to optimize queries that filter by more than one column.   
    */
    use Assignment2;
    create clustered index ix_Sales_Trans_Cust
    on [dbo].[SalesTransactions] (CustomerID);

    CREATE NONCLUSTERED INDEX ix_Sales_Trans_Prod_Date
    ON [dbo].[SalesTransactions] (ProductID, SalesDate);
    
    SELECT * 
    FROM [dbo].[SalesTransactions]
    WHERE CustomerID = 101;

    
    SELECT ProductID, SalesDate 
    FROM [dbo].[SalesTransactions]
    WHERE ProductID = 501 AND SalesDate >= '2026-11-02';
