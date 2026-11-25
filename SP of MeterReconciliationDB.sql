USE MeterReconciliationDB;
GO


-- CREATE STORE PROCEDURE usp_UpsertMeterReading
CREATE OR ALTER PROCEDURE dbo.usp_UpsertMeterReading
(
    @RunId UNIQUEIDENTIFIER,
    @MeterSerialNumber VARCHAR(50),
    @ExternalReadingId VARCHAR(100),
    @BatchId VARCHAR(100),
    @ReadingDate DATETIME2,
    @CumulativeKWh DECIMAL(18,3),

    @Status VARCHAR(20) OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @MeterId INT;

    SET @Status = 'Failed';
    SET @Message = 'Reading was not processed.';

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Validate negative reading
        IF @CumulativeKWh < 0
        BEGIN
            INSERT INTO dbo.ReconciliationAuditLog
            (
                RunId,
                BatchId,
                MeterSerialNumber,
                AuditType,
                Message,
                IsSuccess
            )
            VALUES
            (
                @RunId,
                @BatchId,
                @MeterSerialNumber,
                'Rejected',
                'Negative cumulative meter reading.',
                0
            );

            SET @Status = 'Rejected';
            SET @Message = 'Negative cumulative reading.';

            COMMIT TRANSACTION;
            RETURN -1;
        END;

        -- Find meter
        SELECT @MeterId = MeterId
        FROM dbo.Meters
        WHERE MeterSerialNumber = @MeterSerialNumber
          AND IsActive = 1;

        -- Validate meter existence
        IF @MeterId IS NULL
        BEGIN
            INSERT INTO dbo.ReconciliationAuditLog
            (
                RunId,
                BatchId,
                MeterSerialNumber,
                AuditType,
                Message,
                IsSuccess
            )
            VALUES
            (
                @RunId,
                @BatchId,
                @MeterSerialNumber,
                'Rejected',
                'Unknown or inactive meter.',
                0
            );

            SET @Status = 'Rejected';
            SET @Message = 'Unknown or inactive meter.';

            COMMIT TRANSACTION;
            RETURN -2;
        END;

        -- Check duplicate by external ID or meter/date
        IF EXISTS
        (
            SELECT 1
            FROM dbo.MeterReadings
            WHERE
                (
                    @ExternalReadingId IS NOT NULL
                    AND ExternalReadingId = @ExternalReadingId
                )
                OR
                (
                    MeterId = @MeterId
                    AND ReadingDate = @ReadingDate
                )
        )
        BEGIN
            SET @Status = 'Duplicate';
            SET @Message = 'Reading already exists.';

            COMMIT TRANSACTION;
            RETURN 2;
        END;

        -- Insert valid reading
        INSERT INTO dbo.MeterReadings
        (
            MeterId,
            ExternalReadingId,
            BatchId,
            ReadingDate,
            CumulativeKWh,
            ReadingStatus
        )
        VALUES
        (
            @MeterId,
            @ExternalReadingId,
            @BatchId,
            @ReadingDate,
            @CumulativeKWh,
            'Accepted'
        );

        SET @Status = 'Inserted';
        SET @Message = 'Meter reading inserted successfully.';

        COMMIT TRANSACTION;
        RETURN 1;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 'Failed';
        SET @Message = ERROR_MESSAGE();

        RETURN -99;

    END CATCH;
END;
GO



-- CREATE STORE PROCEDURE usp_CalculateConsumptionDelta


CREATE OR ALTER PROCEDURE dbo.usp_CalculateConsumptionDelta
(
    @RunId UNIQUEIDENTIFIER,
    @ReadingId BIGINT,
    @Status VARCHAR(20) OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @MeterId INT;
    DECLARE @CurrentReading DECIMAL(18,3);
    DECLARE @CurrentDate DATETIME2;

    DECLARE @PreviousReading DECIMAL(18,3);
    DECLARE @PreviousDate DATETIME2;

    DECLARE @Consumption DECIMAL(18,3);

    SET @Status = 'Failed';
    SET @Message = 'Consumption calculation failed.';

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Get current reading
        SELECT
            @MeterId = MeterId,
            @CurrentReading = CumulativeKWh,
            @CurrentDate = ReadingDate
        FROM dbo.MeterReadings
        WHERE ReadingId = @ReadingId;

        -- Validate reading
        IF @MeterId IS NULL
        BEGIN
            SET @Status = 'NotFound';
            SET @Message = 'Reading ID does not exist.';

            ROLLBACK TRANSACTION;
            RETURN -1;
        END;

        -- Find previous reading for the same meter
        SELECT TOP 1
            @PreviousReading = CumulativeKWh,
            @PreviousDate = ReadingDate
        FROM dbo.MeterReadings
        WHERE MeterId = @MeterId
          AND ReadingDate < @CurrentDate
        ORDER BY ReadingDate DESC;

        -- First reading: baseline
        IF @PreviousReading IS NULL
        BEGIN
            UPDATE dbo.MeterReadings
            SET
                PreviousCumulativeKWh = NULL,
                ConsumptionKWh = NULL,
                ReadingStatus = 'Baseline'
            WHERE ReadingId = @ReadingId;

            SET @Status = 'Baseline';
            SET @Message = 'First reading stored as baseline.';

            COMMIT TRANSACTION;
            RETURN 0;
        END;

        -- Calculate consumption
        SET @Consumption =
            @CurrentReading - @PreviousReading;

        -- Negative consumption is anomalous
        IF @Consumption < 0
        BEGIN
            UPDATE dbo.MeterReadings
            SET
                PreviousCumulativeKWh = @PreviousReading,
                ConsumptionKWh = NULL,
                ReadingStatus = 'Anomaly'
            WHERE ReadingId = @ReadingId;

            INSERT INTO dbo.ReconciliationAuditLog
            (
                RunId,
                BatchId,
                MeterSerialNumber,
                AuditType,
                Message,
                IsSuccess
            )
            SELECT
                @RunId,
                BatchId,
                NULL,
                'Anomaly',
                'Negative consumption detected. Possible meter reset.',
                0
            FROM dbo.MeterReadings
            WHERE ReadingId = @ReadingId;

            SET @Status = 'Anomaly';
            SET @Message = 'Negative consumption detected.';

            COMMIT TRANSACTION;
            RETURN -2;
        END;

        -- Save calculated consumption
        UPDATE dbo.MeterReadings
        SET
            PreviousCumulativeKWh = @PreviousReading,
            ConsumptionKWh = @Consumption,
            ReadingStatus = 'Processed'
        WHERE ReadingId = @ReadingId;

        SET @Status = 'Calculated';
        SET @Message = 'Consumption calculated successfully.';

        COMMIT TRANSACTION;
        RETURN 1;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 'Failed';
        SET @Message = ERROR_MESSAGE();

        RETURN -99;

    END CATCH;
END;
GO

-- CREATE STORE PROCEDURE usp_LogReconciliationRun

CREATE OR ALTER PROCEDURE dbo.usp_LogReconciliationRun
(
    @RunId UNIQUEIDENTIFIER,
    @BatchId VARCHAR(100),

    @TotalReceived INT,
    @InsertedCount INT,
    @DuplicateCount INT,
    @RejectedCount INT,
    @AnomalyCount INT,
    @FailedCount INT,

    @Status VARCHAR(20) OUTPUT,
    @Message NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Status = 'Failed';
    SET @Message = 'Reconciliation summary was not saved.';

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Validate counts
        IF
        (
            @TotalReceived < 0
            OR @InsertedCount < 0
            OR @DuplicateCount < 0
            OR @RejectedCount < 0
            OR @AnomalyCount < 0
            OR @FailedCount < 0
        )
        BEGIN
            SET @Status = 'Rejected';
            SET @Message = 'Reconciliation counts cannot be negative.';

            ROLLBACK TRANSACTION;
            RETURN -1;
        END;

        -- Save reconciliation summary
        INSERT INTO dbo.ReconciliationAuditLog
        (
            RunId,
            BatchId,
            MeterSerialNumber,
            AuditType,
            Message,
            IsSuccess
        )
        VALUES
        (
            @RunId,
            @BatchId,
            NULL,
            'RunSummary',
            CONCAT(
                'Total Received: ', @TotalReceived,
                '; Inserted: ', @InsertedCount,
                '; Duplicates: ', @DuplicateCount,
                '; Rejected: ', @RejectedCount,
                '; Anomalies: ', @AnomalyCount,
                '; Failed: ', @FailedCount
            ),
            CASE
                WHEN @FailedCount = 0
                 AND @RejectedCount = 0
                 AND @AnomalyCount = 0
                THEN 1
                ELSE 0
            END
        );

        SET @Status = 'Logged';
        SET @Message = 'Reconciliation summary saved successfully.';

        COMMIT TRANSACTION;
        RETURN 1;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 'Failed';
        SET @Message = ERROR_MESSAGE();

        RETURN -99;

    END CATCH;
END;
GO

-- CREATE STORE PROCEDURE usp_GetAnomalousReadings
CREATE OR ALTER PROCEDURE dbo.usp_GetAnomalousReadings
(
    @FeederId VARCHAR(30) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MR.ReadingId,
        M.MeterSerialNumber,
        M.FeederId,
        MR.BatchId,
        MR.ReadingDate,
        MR.PreviousCumulativeKWh,
        MR.CumulativeKWh,
        MR.ConsumptionKWh,
        MR.ReadingStatus
    FROM dbo.MeterReadings AS MR
    INNER JOIN dbo.Meters AS M
        ON MR.MeterId = M.MeterId
    WHERE
        MR.ReadingStatus = 'Anomaly'

        AND
        (
            @FeederId IS NULL
            OR M.FeederId = @FeederId
        )

        AND
        (
            @StartDate IS NULL
            OR MR.ReadingDate >= @StartDate
        )

        AND
        (
            @EndDate IS NULL
            OR MR.ReadingDate < DATEADD(DAY, 1, @EndDate)
        )

    ORDER BY MR.ReadingDate DESC;
END;
GO


-- CREATE STORE PROCEDURE usp_GetReconciliationSummary

CREATE OR ALTER PROCEDURE dbo.usp_GetReconciliationSummary
(
    @RunId UNIQUEIDENTIFIER = NULL,
    @BatchId VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        AuditId,
        RunId,
        BatchId,
        Message AS Summary,
        IsSuccess,
        CreatedAt
    FROM dbo.ReconciliationAuditLog
    WHERE AuditType = 'RunSummary'
      AND (@RunId IS NULL OR RunId = @RunId)
      AND (@BatchId IS NULL OR BatchId = @BatchId)
    ORDER BY CreatedAt DESC;
END;
GO
