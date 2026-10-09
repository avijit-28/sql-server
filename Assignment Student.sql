--use Assignmet

CREATE TABLE Students (
    StudentId INT IDENTITY(1,1) PRIMARY KEY,
    Name      NVARCHAR(100),
    Course    NVARCHAR(50),
    Marks     INT
);

INSERT INTO Students (Name, Course, Marks) VALUES
('Amit',  'BCA', 78),
('Riya',  'BCA', 91),
('Sourav','MCA', 85),
('Neha',  'MCA', 66);

-----------------------------------------------------------------------------------------

CREATE PROCEDURE usp_GetStudents
    @Course   NVARCHAR(50) = NULL,
    @MinMarks INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Result set 1: student list
    SELECT StudentId, Name, Course, Marks
    FROM Students
    WHERE (@Course IS NULL OR Course = @Course)
      AND Marks >= @MinMarks;

    -- Result set 2: summary
    SELECT COUNT(*) AS TotalStudents, AVG(Marks) AS AverageMarks
    FROM Students
    WHERE (@Course IS NULL OR Course = @Course)
      AND Marks >= @MinMarks;
END