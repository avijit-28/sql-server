USE [Hospital];
GO

-- ====================================================================================================
-- 1. Get Patient Details by ID
-- ====================================================================================================
IF OBJECT_ID('get_PatientDetails', 'P') IS NOT NULL
    DROP PROCEDURE get_PatientDetails;
GO

CREATE PROCEDURE get_PatientDetails
(
    @id INT,
    @msg VARCHAR(200) OUTPUT
)
AS 
BEGIN
    SELECT [patient_id]
          ,[first_name]
          ,[last_name]
          ,[date_of_birth]
          ,[gender]
          ,[phone_number]
          ,[blood_group]
      FROM [Hospital].[hpl].[Patients]
      WHERE [patient_id] = @id;

    SET @msg = 'Patient details fetched successfully by ' + CAST(@id AS VARCHAR(MAX));
END;
GO

-- Test Execution
DECLARE @m VARCHAR(200);
EXEC get_PatientDetails 1, @m OUT;
PRINT @m;
GO

-- ====================================================================================================
-- 2. Get All Patient Details
-- ====================================================================================================
IF OBJECT_ID('get_AllPatientDetails', 'P') IS NOT NULL
    DROP PROCEDURE get_AllPatientDetails;
GO

CREATE PROCEDURE get_AllPatientDetails
(
    @msg VARCHAR(200) OUTPUT
)
AS 
BEGIN
    SELECT [patient_id]
          ,[first_name]
          ,[last_name]
          ,[date_of_birth]
          ,[gender]
          ,[phone_number]
          ,[blood_group]
      FROM [Hospital].[hpl].[Patients];

    IF (@@ROWCOUNT > 0)
        SET @msg = 'Patient details fetched successfully';
END;
GO

-- Test Execution
DECLARE @m VARCHAR(200);
EXEC get_AllPatientDetails @m OUT;
PRINT @m;
GO

-- ====================================================================================================
-- 3. Insert Patient Details
-- ====================================================================================================
IF OBJECT_ID('set_InsertPatientDetails', 'P') IS NOT NULL
    DROP PROCEDURE set_InsertPatientDetails;
GO

CREATE PROCEDURE set_InsertPatientDetails
(
    @first_name   VARCHAR(50),
    @last_name    VARCHAR(50),
    @date_of_birth DATE,
    @gender       CHAR(6),
    @phone_number VARCHAR(20) = NULL,
    @blood_group  VARCHAR(5) = NULL,
    @msg          VARCHAR(200) OUTPUT
)
AS 
BEGIN
    INSERT INTO [Hospital].[hpl].[Patients] 
           ([first_name]
           ,[last_name]
           ,[date_of_birth]
           ,[gender]
           ,[phone_number]
           ,[blood_group])
    VALUES 
           (@first_name,
           @last_name,
           @date_of_birth,
           @gender,
           @phone_number,
           @blood_group);

    SET @msg = 'successfully inserted data';
END;
GO

-- Test Execution
DECLARE @m VARCHAR(200);
EXEC set_InsertPatientDetails 'Rahul', 'Sharma', '1995-05-15', 'Male', '9876543210', 'O+', @m OUT;
PRINT @m;
GO

-- ====================================================================================================
-- 4. Update Patient Details
-- ====================================================================================================
IF OBJECT_ID('UpdatePatientDetails', 'P') IS NOT NULL
    DROP PROCEDURE UpdatePatientDetails;
GO

CREATE PROCEDURE UpdatePatientDetails
(
    @Id           INT,
    @first_name   VARCHAR(50) = NULL,
    @last_name    VARCHAR(50) = NULL,
    @date_of_birth DATE = NULL,
    @gender       CHAR(6) = NULL,
    @phone_number VARCHAR(20) = NULL,
    @blood_group  VARCHAR(5) = NULL,
    @msg          VARCHAR(200) OUTPUT
)
AS
BEGIN
    UPDATE [Hospital].[hpl].[Patients] 
    SET
        first_name    = ISNULL(@first_name, first_name),
        last_name     = ISNULL(@last_name, last_name),
        date_of_birth = ISNULL(@date_of_birth, date_of_birth),
        gender        = ISNULL(@gender, gender),
        phone_number  = ISNULL(@phone_number, phone_number),
        blood_group   = ISNULL(@blood_group, blood_group)
    WHERE patient_id = @Id;

    SET @msg = 'successfully updated data';
END;
GO

-- Test Execution
DECLARE @m VARCHAR(200);
EXEC UpdatePatientDetails @Id = 1, @phone_number = '9123456780', @blood_group = 'A+', @msg = @m OUT;
PRINT @m;
GO

-- ====================================================================================================
-- 5. Delete Patient Details
-- ====================================================================================================
IF OBJECT_ID('set_DeletePatientDetails', 'P') IS NOT NULL
    DROP PROCEDURE set_DeletePatientDetails;
GO

CREATE PROCEDURE set_DeletePatientDetails
( 
    @id  INT,
    @msg VARCHAR(200) OUTPUT
)
AS
BEGIN
    DELETE FROM [Hospital].[hpl].[Patients]  
    WHERE patient_id = @id;

    SET @msg = 'Deleted Successfully';
END;
GO

-- Test Execution
DECLARE @m VARCHAR(200);
EXEC set_DeletePatientDetails 1, @m OUT;
PRINT @m;
GO
