USE MeterReconciliationDB;
GO

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




