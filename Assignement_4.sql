/* ====================================================================
				Name : Avijit Pakhira
				Date : 20 Nov, 2026
				Description : Assignment IV
==================================================================== */

-- 1
CREATE TABLE #Students (
    StudentName VARCHAR(50),
    FatherName  VARCHAR(50)
);
INSERT INTO #Students (StudentName, FatherName)
VALUES
    ('Rajiv Kumar',  'Arvind Kumar'),
    ('Asish Roy',    'Ashim Roy'),
    ('Bipin Gupta',  'Rajiv Gupta'),
    ('Rajiv Kumar',  'Arvind Kumar'),  
    ('Sourav Patra', 'Asish Patra'),
    ('Asish Roy',    'Ashim Roy'); 

SELECT 
    StudentName, 
    FatherName, 
    COUNT(*) AS DuplicateCount
FROM #Students
GROUP BY StudentName, FatherName
HAVING COUNT(*) > 1;


-- 2
SELECT FORMAT(GETDATE(), 'MMM dd yyyy HH:mm tt')

-- 3
use Assignment2
go
create procedure sp_UpdateTrainSeat
as 
begin
    declare @ReservationID int;
    declare @TrainID int;
    declare @SeatsBooked int;
    declare @status varchar(20);

    declare res_cursor cursor for 
    select
        reservation_id,
        train_id,
        seats_booked,
        status
    from dbo.reservations
    where is_processed = 0;

    open res_cursor

    fetch next from res_cursor 
    into  @ReservationID, @TrainID, @SeatsBooked, @Status;


    while @@FETCH_STATUS = 0
    begin
        if @status = 'Confirmed'
        begin
            update dbo.trains
            set available_seats = available_seats - @SeatsBooked
            where train_id = @TrainID
            PRINT 'Reservation #' + CAST(@ReservationID AS VARCHAR(10)) + 
                  ': CANCELED  -> Restored ' + CAST(@SeatsBooked AS VARCHAR(10)) + 
                  ' seats on Train #' + CAST(@TrainID AS VARCHAR(10));
        END;

        update dbo.reservations
        set is_processed = 1
        where reservation_id = @ReservationID;

        fetch next from res_cursor
        into @ReservationID, @TrainID, @SeatsBooked, @Status;
    END;

    CLOSE res_cursor;
    DEALLOCATE res_cursor;
    PRINT 'All reservations successfully processed ';
END;
            
EXEC sp_UpdateTrainSeat;
SELECT train_id, train_name, available_seats FROM dbo.trains;
select * from dbo.reservations

-- 4

WITH MobileBOM_CTE AS (
   
    SELECT 
        p.part_id,
        p.part_name,
        p.part_type,
        CAST(1.00 AS DECIMAL(10, 2)) AS TotalQuantity,
        0 AS [Level],
        CAST(p.part_name AS VARCHAR(MAX)) AS [HierarchyPath]
    FROM dbo.parts p
    WHERE p.part_id = 1000

    UNION ALL

   select
        child.part_id,
        child.part_name,
        child.part_type,
        CAST(bom.quantity * parent.TotalQuantity AS DECIMAL(10, 2)) AS TotalQuantity,
        parent.[Level] + 1 AS [Level],
        CAST(parent.[HierarchyPath] + ' -> ' + child.part_name AS VARCHAR(MAX))
    FROM dbo.bill_of_materials bom
    INNER JOIN MobileBOM_CTE parent ON bom.parent_part_id = parent.part_id
    INNER JOIN dbo.parts child      ON bom.child_part_id  = child.part_id
)
SELECT 
    part_id AS PartID,
    
    REPLICATE('    ', [Level]) + part_name AS IndentedPartName,
    part_type AS PartType,
    TotalQuantity,
    [Level],
    [HierarchyPath]
FROM MobileBOM_CTE
ORDER BY [HierarchyPath];


-- 5
create procedure sp_UpdateProductStockFromTransactions
as
begin
    DECLARE @TransID   INT;
    DECLARE @ProdID    INT;
    DECLARE @TransType VARCHAR(20);
    DECLARE @Qty       INT;

    DECLARE cur_trans CURSOR LOCAL FAST_FORWARD FOR
        SELECT TransactionID, ProductID, UPPER(LTRIM(RTRIM(TransactionType))), Quantity
        FROM dbo.Transactions
        WHERE IsProcessed = 0
        ORDER BY TransactionID ASC;

    begin try
        begin transaction
        open cur_trans;

        FETCH NEXT FROM cur_trans INTO @TransID, @ProdID, @TransType, @Qty;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Add stock if IN / PURCHASE
            IF @TransType IN ('IN', 'PURCHASE', 'RESTOCK')
            BEGIN
                UPDATE dbo.Products
                SET StockQuantity = StockQuantity + @Qty
                WHERE ProductID = @ProdID;
            END
            -- Subtract stock if OUT / SALE
            ELSE IF @TransType IN ('OUT', 'SALE', 'DISPATCH')
            BEGIN
                UPDATE dbo.Products
                SET StockQuantity = StockQuantity - @Qty
                WHERE ProductID = @ProdID;
            END
            -- Mark transaction as processed
            UPDATE dbo.Transactions
            SET IsProcessed = 1
            WHERE TransactionID = @TransID;
            -- Fetch next row
            FETCH NEXT FROM cur_trans INTO @TransID, @ProdID, @TransType, @Qty;
        END

        close cur_trans;
        deallocate cur_trans;
        PRINT 'Product stock updated successfully from transactions.';
    end try
    begin catch
        if cursor_status('local','cur_trans') >= 0
            close cur_trans;
        if cursor_status('local','cur_trans') >= -1
            deallocate cur_trans;

        if @@TRANCOUNT > 0
            rollback transaction;

        declare @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO


-- Check stock before running
SELECT ProductID, ProductName, StockQuantity FROM dbo.Products;

-- Execute Stored Procedure
EXEC sp_UpdateProductStockFromTransactions;

-- Check stock after running
SELECT ProductID, ProductName, StockQuantity FROM dbo.Products;

-- Check transactions status
SELECT TransactionID, ProductID, TransactionType, Quantity, IsProcessed 
FROM dbo.Transactions;

-- 5
CREATE TYPE TicketBookingType AS TABLE (
    PassengerID   INT NOT NULL,
    FlightNumber  VARCHAR(20) NOT NULL,
    Destination   VARCHAR(50) NOT NULL,
    BookingDate   DATE NOT NULL,
    TicketAmount  DECIMAL(10,2) NOT NULL,
    BookingStatus VARCHAR(20) DEFAULT 'Confirmed'
);
alter procedure sp_insertticketBookings
    @bookingList TicketBookingType READONLY
as 
begin
    begin try
        begin transaction

        if exists(
            select 1 from @bookingList b
            left join dbo.Passengers p on b.PassengerID = p.PassengerID
            where p.PassengerID is null
        )
        begin
            RAISERROR('Validation Error: One or more PassengerIDs do not exist in dbo.Passengers.', 16, 1);
        END

        INSERT INTO dbo.Bookings (
            PassengerID, 
            FlightNumber, 
            Destination, 
            BookingDate, 
            TicketAmount, 
            BookingStatus
        )

        SELECT 
            PassengerID, 
            FlightNumber, 
            Destination, 
            BookingDate, 
            TicketAmount, 
            ISNULL(BookingStatus, 'Confirmed')
        FROM @BookingList;

        commit transaction; 
        print 'ticket booking successfully '
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction;
            declare @errorMessage nvarchar(4000) = Error_Message()
            Raiserror(@errorMessage, 16,1);
    end catch
end

DECLARE @MyBookingBatch TicketBookingType;
INSERT INTO @MyBookingBatch (PassengerID, FlightNumber, Destination, BookingDate, TicketAmount, BookingStatus)
VALUES
    (1, 'AI-101', 'Mumbai',    '2026-11-21', 5200.00, 'Confirmed'),
    (2, '6E-205', 'Chennai',   '2026-11-22', 4300.00, 'Confirmed'),
    (1, 'SG-404', 'Hyderabad', '2026-11-23', 3800.00, 'Confirmed');

EXEC sp_insertticketBookings @BookingList = @MyBookingBatch;
GO

SELECT 
    b.BookingID,
    p.PassengerName,
    b.FlightNumber,
    b.Destination,
    b.BookingDate,
    b.TicketAmount,
    b.BookingStatus
FROM dbo.Bookings b
INNER JOIN dbo.Passengers p ON b.PassengerID = p.PassengerID
ORDER BY b.BookingID DESC;
GO

DECLARE @InvalidBatch TicketBookingType;
INSERT INTO @InvalidBatch (PassengerID, FlightNumber, Destination, BookingDate, TicketAmount, BookingStatus)
VALUES
    (1,   'AI-999', 'Delhi',  '2026-11-25', 4000.00, 'Confirmed'),
    (999, 'AI-888', 'Jaipur', '2026-11-26', 3500.00, 'Confirmed'); -- 999 does not exist!
-- This will throw an error and rollback completely
EXEC sp_insertticketBookings @BookingList = @InvalidBatch;

-- 6
CREATE TABLE #edges (
    source_node      VARCHAR(10) NOT NULL,
    destination_node VARCHAR(10) NOT NULL
);
INSERT INTO #edges (source_node, destination_node)
VALUES 
    ('A', 'B'),
    ('A', 'C'),
    ('A', 'E'),
    ('B', 'C'),
    ('B', 'D'),
    ('C', 'D'),
    ('E', 'D'),
    ('C', 'B');



DECLARE @start_node  VARCHAR(10) = 'A';
DECLARE @target_node VARCHAR(10) = 'D';

WITH GraphPaths AS (
    SELECT 
        source_node,
        destination_node,
        CAST(source_node + ' -> ' + destination_node AS VARCHAR(MAX)) AS full_path,
        CAST(',' + source_node + ',' + destination_node + ',' AS VARCHAR(MAX)) AS visited_nodes,
        1 AS step_count
    FROM #edges
    WHERE source_node = @start_node

    UNION ALL

    SELECT 
        e.source_node,
        e.destination_node,
        CAST(gp.full_path + ' -> ' + e.destination_node AS VARCHAR(MAX)) AS full_path,
        CAST(gp.visited_nodes + e.destination_node + ',' AS VARCHAR(MAX)) AS visited_nodes,
        gp.step_count + 1 AS step_count
    FROM GraphPaths gp
    INNER JOIN #edges e 
        ON gp.destination_node = e.source_node
    WHERE 
        gp.destination_node <> @target_node
        AND CHARINDEX(',' + e.destination_node + ',', gp.visited_nodes) = 0
)
SELECT 
    full_path, 
    step_count AS number_of_edges
FROM GraphPaths
WHERE destination_node = @target_node
ORDER BY step_count ASC, full_path ASC

--8
create type productTableType as Table (
    productName varchar(100) not null,
    unitPrice Decimal(10,2) not null,
    stockQuantity INT not null Default 0);

create procedure BulkInsertProducts
    @NewProducts productTableType Readonly
as 
begin
    begin try
        begin transaction

        INSERT INTO dbo.Products (ProductName, UnitPrice, StockQuantity)
        SELECT 
            ProductName, 
            UnitPrice, 
            StockQuantity
        FROM @NewProducts;

        DECLARE @InsertedCount INT = @@ROWCOUNT;

        COMMIT TRANSACTION;
        PRINT 'product added successfully';

        select top(@InsertedCount)
            ProductID,
            ProductName,
            UnitPrice,
            StockQuantity
        from Products
        order by ProductID Desc
    end try
    begin catch
        if @@TRANCOUNT > 0
            rollback transaction;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;
GO

DECLARE @ProductBatch ProductTableType;
INSERT INTO @ProductBatch (ProductName, UnitPrice, StockQuantity)
VALUES
    ('Mechanical Keyboard RGB', 3499.00, 25),
    ('Ultra-Wide Gaming Monitor', 28500.00, 10),
    ('Wireless Noise-Canceling Headset', 6999.00, 40);
-- Pass the table variable into the stored procedure
EXEC BulkInsertProducts @NewProducts = @ProductBatch;
GO

-- 9 
use PaintDB;
go
alter procedure sp_EscalateOverdueComplaints
as 
begin
    begin try
        begin transaction
            
        update complaints
        set 
            status = 'Escalated',
            EscalationDate = getdate() 
            
        
        where status = 'open'
            and datediff(Day,complaintDate, GetDate()) > 7;

        declare @updatedCount int = @@rowcount;
        commit transaction

        PRINT CAST(@UpdatedCount AS VARCHAR(10)) + ' complaints open for > 7 days have been Escalated.';
        
        SELECT 
            ComplaintID,          
            DealerID,
            IssueDescription,
            ComplaintDate,
            DATEDIFF(DAY, ComplaintDate, EscalationDate) AS DaysOpen,
            Status,
            EscalationDate
        FROM dbo.Complaints
        where Status = 'Escalated'

    end try
    begin catch
        if @@TRANCOUNT > 0 
        BEGIN
            ROLLBACK TRANSACTION;
            PRINT 'Transaction rolled back due to an error.';
        END

         DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
    END CATCH
END;

 EXEC dbo.sp_EscalateOverdueComplaints; 

select * from Complaints

SELECT 
    ComplaintID, 
    LEFT(IssueDescription, 30) AS Issue,
    ComplaintDate, 
    DATEDIFF(DAY, ComplaintDate, GETDATE()) AS DaysOpen,
    Status, 
    EscalationDate
FROM dbo.Complaints
WHERE ComplaintID >= IDENT_CURRENT('dbo.Complaints') - 10;
GO

select * from ComplaintEscalationLog

SELECT 
    ComplaintID,
    DealerID,
    LEFT(IssueDescription, 30) AS Issue,
    DATEDIFF(DAY, ComplaintDate, GETDATE()) AS DaysOpen
    ,status
    ,EscalationDate
FROM dbo.Complaints

ORDER BY ComplaintID DESC;

