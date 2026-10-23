SELECT TOP (1000) [UserId]
      ,[UserName]
      ,[Password]
      ,[Email]
      ,[MobileNo]
      ,[City]
  FROM [Assignmet].[dbo].[UserDetails]

  --insert into [Assignmet].[dbo].[UserDetails] values (21,'avijit','28072003','avijit@gmail','8917485418','kolkata');
  -- get all details
CREATE PROCEDURE sp_GetAllUserDetails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId,
        UserName,
        Password,
        Email,
        MobileNo,
        City
    FROM UserDetails;
END

-- insert all values
CREATE PROCEDURE sp_InsertUserDetails
(
    @UserId INT,
    @UserName VARCHAR(50),
    @Password VARCHAR(50),
    @Email VARCHAR(100),
    @MobileNo VARCHAR(15),
    @City VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO UserDetails
    (
        UserId,
        UserName,
        Password,
        Email,
        MobileNo,
        City
    )
    VALUES
    (
        @UserId,
        @UserName,
        @Password,
        @Email,
        @MobileNo,
        @City
    );
END

-- Update
CREATE PROCEDURE sp_UpdateUserDetails
(
    @UserId INT,
    @UserName VARCHAR(50) = NULL,
    @Password VARCHAR(50) = NULL,
    @Email VARCHAR(100) = NULL,
    @MobileNo VARCHAR(15) = NULL,
    @City VARCHAR(50) = NULL
)
AS
BEGIN
    UPDATE UserDetails
    SET
        UserName = COALESCE(NULLIF(@UserName,''), UserName),
        Password = COALESCE(NULLIF(@Password,''), Password),
        Email    = COALESCE(NULLIF(@Email,''), Email),
        MobileNo = COALESCE(NULLIF(@MobileNo,''), MobileNo),
        City     = COALESCE(NULLIF(@City,''), City)
    WHERE UserId = @UserId
END

--Delete user
CREATE PROCEDURE sp_DeleteUserDetails
(
    @UserId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM UserDetails
    WHERE UserId = @UserId;
END


-- paging
Create proc spGetUsers_by_PageIndex_and_PageSize
@PageIndex int,  
@PageSize int,
@TotalRows int output
as  
Begin  
Declare @StartRowIndex int 
Declare @EndRowIndex int
Set @StartRowIndex = (@PageIndex * @PageSize) + 1;
Set @EndRowIndex = (@PageIndex + 1) * @PageSize;
Select[UserId]
      ,[UserName]
      ,[Password]
      ,[Email]
      ,[MobileNo]
      ,[City]
      from  
(Select ROW_NUMBER() over (order by [UserId]) as RowNumber,[UserId]
      ,[UserName]
      ,[Password]
      ,[Email]
      ,[MobileNo]
      ,[City]  
from [Assignmet].[dbo].[UserDetails]) Users  
Where RowNumber >= @StartRowIndex and RowNumber <= @EndRowIndex
Select @TotalRows = COUNT(*) from [Assignmet].[dbo].[UserDetails]
End
