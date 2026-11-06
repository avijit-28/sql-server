-- ====================================================================================================
--                  Author : Avijit Pakhira
--                  Date Created :- 06/11/2026
--                  Description :- Stored Procedure for CURD operation on Doctor's Table

--1. Get Doctor Details by ID
-- ====================================================================================================
create proc get_DoctorDetails(
    @id int,
    @msg varchar(200) output
)
as 
begin
    SELECT [doctor_id]
          ,[first_name]
          ,[last_name]
          ,[specialization]
          ,[department_id]
          ,[email]
          ,[phone_number]
      FROM [Hospital].[hpl].[Doctors]
      WHERE [doctor_id] = @id

    set @msg = 'Doctor details fetched successfully by ' + cast(@id as varchar(max))
end
GO

declare @m varchar(200)
exec get_DoctorDetails 1, @m out
print @m
GO

-- ====================================================================================================
-- 2. Get All Doctor Details
-- ====================================================================================================
create proc get_AllDoctorDetails(
    @msg varchar(200) output
)
as 
begin
    SELECT [doctor_id]
          ,[first_name]
          ,[last_name]
          ,[specialization]
          ,[department_id]
          ,[email]
          ,[phone_number]
      FROM [Hospital].[hpl].[Doctors]

    if(@@ROWCOUNT > 0)
        set @msg = 'Doctor details fetched successfully'
end
GO

declare @m varchar(200)
exec get_AllDoctorDetails @m out
print @m
GO

-- ====================================================================================================
-- 3. Insert Doctor Details
-- ====================================================================================================
create proc set_InsertDoctorDetails(
    @first_name varchar(100),
    @last_name varchar(100),
    @specialization varchar(100),
    @department_id int,
    @email varchar(100),
    @phone_number varchar(20),
    @msg varchar(200) output
)
as 
begin
    insert into [Hospital].[hpl].[Doctors] 
           ([first_name]
           ,[last_name]
           ,[specialization]
           ,[department_id]
           ,[email]
           ,[phone_number])
    values 
           (@first_name,
           @last_name,
           @specialization,
           @department_id,
           @email,
           @phone_number)

    set @msg = 'successfully inserted data'
end
GO

declare @m varchar(200)
exec set_InsertDoctorDetails 'John', 'Doe', 'Cardiology', 2, 'john.doe@hospital.com', '1234567890', @m out
print @m
GO

-- ====================================================================================================
-- 4. Update Doctor Details
-- ====================================================================================================
create proc UpdateDoctorDetails(
    @Id INT,
    @first_name VARCHAR(100) = NULL,
    @last_name VARCHAR(100) = NULL,
    @specialization VARCHAR(100) = NULL,
    @department_id INT = NULL,
    @email VARCHAR(100) = NULL,
    @phone_number VARCHAR(20) = NULL,
    @msg varchar(200) output
)
as
begin
    update [Hospital].[hpl].[Doctors] 
    set
        first_name = isnull(@first_name, first_name),
        last_name = isnull(@last_name, last_name),
        specialization = isnull(@specialization, specialization),
        department_id = isnull(@department_id, department_id),
        email = isnull(@email, email),
        phone_number = isnull(@phone_number, phone_number)
    where doctor_id = @Id;

    set @msg = 'successfully updated data'
end
GO

declare @m varchar(200)
exec UpdateDoctorDetails @Id = 1, @specialization = 'Neurology', @phone_number = '9876543210', @msg = @m out
print @m
GO

-- ====================================================================================================
-- 5. Delete Doctor Details
-- ====================================================================================================
create proc set_DeleteDoctorDetails( 
    @id int,
    @msg varchar(200) output
)
as
begin
    delete from [Hospital].[hpl].[Doctors]  
    where doctor_id = @id

    set @msg = 'Deleted Successfully'
end
GO

declare @m varchar(200)
exec set_DeleteDoctorDetails 1, @m out
print @m
GO