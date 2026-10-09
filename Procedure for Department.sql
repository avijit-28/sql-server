create proc get_DepartmentDetails(
@id int,
@msg varchar(200) output
)
as 
begin

SELECT [department_id]
      ,[department_name]
      ,[head_of_department]
      ,[phone_extension]
  FROM [Hospital].[hpl].[Departments]
  where [department_id] = @id
set @msg = 'Department details fetched successfull by '+cast(@id as varchar(max))
end

declare @m varchar(200)
exec get_DepartmentDetails 2, @m out
print @m
----------------------------------------------------------------------------------------------------

alter proc get_AllDepartmentDetails(
    @msg varchar(200) output
)
as 
begin
SELECT [department_id]
      ,[department_name]
      ,[head_of_department]
      ,[phone_extension]
  FROM [Hospital].[hpl].[Departments]
  if(@@ROWCOUNT>0)
    set @msg = 'Department details fetched successfully'
end

declare @m varchar(200)
exec get_AllDepartmentDetails @m out
print @m
----------------------------------------------------------------------------------------------------------

create proc set_InsertDepartmentDetails(
@department_name varchar(100),
@hod varchar(100),
@phone_ext varchar(10),
@msg varchar(200) output
)
as 
begin
insert into [Hospital].[hpl].[Departments] 
       ([department_name]
      ,[head_of_department]
      ,[phone_extension])
values 
      (@department_name,
      @hod,
      @phone_ext)
set @msg = 'successfully inserted data'
end
---------------------------------------------------------------------------------------------------------
alter PROCEDURE UpdateDepartmentDetails(
    @Id INT,
    @department_name VARCHAR(100) = NULL,
    @hod VARCHAR(100) = NULL,
    @Phone_ext VARCHAR(20) = NULL,
    @msg varchar(200) output
    )
AS
BEGIN
    UPDATE [Hospital].[hpl].[Departments] 
    SET
        department_name = ISNULL(@department_name, department_name),
        head_of_department = ISNULL(@hod, head_of_department),
        phone_extension = ISNULL(@Phone_ext, phone_extension)
    WHERE department_id = @Id;

set @msg = 'successfully updated data'
END



--------------------------------------------------------------------------------------------------------
create proc set_DeleteDepartmentDetails( 
@id int,
@msg varchar(200) output
)
as
begin
delete from [Hospital].[hpl].[Departments]  
where @id = department_id
set @msg = 'Deleted Successfully'

end