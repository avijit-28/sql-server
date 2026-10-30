/* ============================================================
   LMS - LEARNING MANAGEMENT SYSTEM
   Database: LMS
   SQL Server
   ============================================================ */

---------------------------------------------------------------
-- 1. CREATE DATABASE
---------------------------------------------------------------

IF DB_ID('LMS') IS NULL
BEGIN
    CREATE DATABASE LMS;
END
GO

USE LMS;
GO


/* ============================================================
   2. DROP TABLES IF THEY ALREADY EXIST
   ============================================================ */

IF OBJECT_ID('dbo.QuizAnswers', 'U') IS NOT NULL DROP TABLE dbo.QuizAnswers;
IF OBJECT_ID('dbo.QuizAttempts', 'U') IS NOT NULL DROP TABLE dbo.QuizAttempts;
IF OBJECT_ID('dbo.QuestionOptions', 'U') IS NOT NULL DROP TABLE dbo.QuestionOptions;
IF OBJECT_ID('dbo.Questions', 'U') IS NOT NULL DROP TABLE dbo.Questions;
IF OBJECT_ID('dbo.Quizzes', 'U') IS NOT NULL DROP TABLE dbo.Quizzes;

IF OBJECT_ID('dbo.Submissions', 'U') IS NOT NULL DROP TABLE dbo.Submissions;
IF OBJECT_ID('dbo.Assignments', 'U') IS NOT NULL DROP TABLE dbo.Assignments;

IF OBJECT_ID('dbo.LessonProgress', 'U') IS NOT NULL DROP TABLE dbo.LessonProgress;
IF OBJECT_ID('dbo.Enrollments', 'U') IS NOT NULL DROP TABLE dbo.Enrollments;

IF OBJECT_ID('dbo.Lessons', 'U') IS NOT NULL DROP TABLE dbo.Lessons;
IF OBJECT_ID('dbo.Modules', 'U') IS NOT NULL DROP TABLE dbo.Modules;

IF OBJECT_ID('dbo.CourseReviews', 'U') IS NOT NULL DROP TABLE dbo.CourseReviews;
IF OBJECT_ID('dbo.Certificates', 'U') IS NOT NULL DROP TABLE dbo.Certificates;

IF OBJECT_ID('dbo.Courses', 'U') IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;

IF OBJECT_ID('dbo.Notifications', 'U') IS NOT NULL DROP TABLE dbo.Notifications;
IF OBJECT_ID('dbo.Announcements', 'U') IS NOT NULL DROP TABLE dbo.Announcements;

IF OBJECT_ID('dbo.Payments', 'U') IS NOT NULL DROP TABLE dbo.Payments;

GO


/* ============================================================
   3. CATEGORIES
   ============================================================ */

CREATE TABLE Categories
(
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,

    CategoryName NVARCHAR(100) NOT NULL,

    Description NVARCHAR(500) NULL,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Categories_CategoryName
        UNIQUE(CategoryName)
);
GO


/* ============================================================
   4. COURSES
   ============================================================ */

CREATE TABLE Courses
(
    CourseId INT IDENTITY(1,1) PRIMARY KEY,

    CategoryId INT NOT NULL,

    InstructorId NVARCHAR(450) NOT NULL,

    Title NVARCHAR(200) NOT NULL,

    Description NVARCHAR(MAX) NULL,

    Thumbnail NVARCHAR(500) NULL,

    Price DECIMAL(18,2) NOT NULL DEFAULT 0,

    Level NVARCHAR(50) NOT NULL DEFAULT 'Beginner',

    DurationInHours DECIMAL(5,2) NOT NULL DEFAULT 0,

    Status NVARCHAR(30) NOT NULL DEFAULT 'Draft',

    Rating DECIMAL(3,2) NOT NULL DEFAULT 0,

    TotalStudents INT NOT NULL DEFAULT 0,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedDate DATETIME2 NULL,

    PublishedDate DATETIME2 NULL,

    CONSTRAINT FK_Courses_Categories
        FOREIGN KEY(CategoryId)
        REFERENCES Categories(CategoryId),

    CONSTRAINT CK_Courses_Price
        CHECK(Price >= 0),

    CONSTRAINT CK_Courses_Level
        CHECK(Level IN ('Beginner','Intermediate','Advanced')),

    CONSTRAINT CK_Courses_Status
        CHECK(Status IN ('Draft','Published','Archived'))
);
GO


/* ============================================================
   5. MODULES
   ============================================================ */

CREATE TABLE Modules
(
    ModuleId INT IDENTITY(1,1) PRIMARY KEY,

    CourseId INT NOT NULL,

    ModuleName NVARCHAR(200) NOT NULL,

    Description NVARCHAR(1000) NULL,

    ModuleOrder INT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Modules_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE
);
GO


/* ============================================================
   6. LESSONS
   ============================================================ */

CREATE TABLE Lessons
(
    LessonId INT IDENTITY(1,1) PRIMARY KEY,

    ModuleId INT NOT NULL,

    Title NVARCHAR(200) NOT NULL,

    Description NVARCHAR(MAX) NULL,

    LessonType NVARCHAR(30) NOT NULL,

    VideoUrl NVARCHAR(500) NULL,

    Content NVARCHAR(MAX) NULL,

    ResourceUrl NVARCHAR(500) NULL,

    DurationInMinutes INT NOT NULL DEFAULT 0,

    LessonOrder INT NOT NULL DEFAULT 1,

    IsPreview BIT NOT NULL DEFAULT 0,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedDate DATETIME2 NULL,

    CONSTRAINT FK_Lessons_Modules
        FOREIGN KEY(ModuleId)
        REFERENCES Modules(ModuleId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Lessons_Type
        CHECK(LessonType IN
        (
            'Video',
            'PDF',
            'Article',
            'Link',
            'Quiz',
            'Assignment'
        ))
);
GO


/* ============================================================
   7. ENROLLMENTS
   ============================================================ */

CREATE TABLE Enrollments
(
    EnrollmentId INT IDENTITY(1,1) PRIMARY KEY,

    StudentId NVARCHAR(450) NOT NULL,

    CourseId INT NOT NULL,

    EnrollmentDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    Status NVARCHAR(30) NOT NULL DEFAULT 'Active',

    CompletionPercentage DECIMAL(5,2) NOT NULL DEFAULT 0,

    CompletionDate DATETIME2 NULL,

    CONSTRAINT FK_Enrollments_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Student_Course
        UNIQUE(StudentId, CourseId),

    CONSTRAINT CK_Enrollment_Status
        CHECK(Status IN ('Active','Completed','Cancelled')),

    CONSTRAINT CK_Enrollment_Percentage
        CHECK(CompletionPercentage BETWEEN 0 AND 100)
);
GO


/* ============================================================
   8. LESSON PROGRESS
   ============================================================ */

CREATE TABLE LessonProgress
(
    ProgressId INT IDENTITY(1,1) PRIMARY KEY,

    StudentId NVARCHAR(450) NOT NULL,

    LessonId INT NOT NULL,

    IsCompleted BIT NOT NULL DEFAULT 0,

    WatchTimeInSeconds INT NOT NULL DEFAULT 0,

    CompletedDate DATETIME2 NULL,

    LastAccessedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_LessonProgress_Lessons
        FOREIGN KEY(LessonId)
        REFERENCES Lessons(LessonId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Student_Lesson
        UNIQUE(StudentId, LessonId)
);
GO


/* ============================================================
   9. QUIZZES
   ============================================================ */

CREATE TABLE Quizzes
(
    QuizId INT IDENTITY(1,1) PRIMARY KEY,

    CourseId INT NOT NULL,

    LessonId INT NULL,

    Title NVARCHAR(200) NOT NULL,

    Description NVARCHAR(MAX) NULL,

    PassingPercentage DECIMAL(5,2) NOT NULL DEFAULT 40,

    TimeLimitMinutes INT NULL,

    TotalMarks INT NOT NULL DEFAULT 0,

    IsActive BIT NOT NULL DEFAULT 1,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Quizzes_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE,

    CONSTRAINT FK_Quizzes_Lessons
        FOREIGN KEY(LessonId)
        REFERENCES Lessons(LessonId)
        ON DELETE NO ACTION,

    CONSTRAINT CK_Quiz_PassingPercentage
        CHECK(PassingPercentage BETWEEN 0 AND 100)
);
GO


/* ============================================================
   10. QUESTIONS
   ============================================================ */

CREATE TABLE Questions
(
    QuestionId INT IDENTITY(1,1) PRIMARY KEY,

    QuizId INT NOT NULL,

    QuestionText NVARCHAR(MAX) NOT NULL,

    Marks INT NOT NULL DEFAULT 1,

    QuestionOrder INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Questions_Quizzes
        FOREIGN KEY(QuizId)
        REFERENCES Quizzes(QuizId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Questions_Marks
        CHECK(Marks > 0)
);
GO


/* ============================================================
   11. QUESTION OPTIONS
   ============================================================ */

CREATE TABLE QuestionOptions
(
    OptionId INT IDENTITY(1,1) PRIMARY KEY,

    QuestionId INT NOT NULL,

    OptionText NVARCHAR(1000) NOT NULL,

    IsCorrect BIT NOT NULL DEFAULT 0,

    OptionOrder INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_QuestionOptions_Questions
        FOREIGN KEY(QuestionId)
        REFERENCES Questions(QuestionId)
        ON DELETE CASCADE
);
GO


/* ============================================================
   12. QUIZ ATTEMPTS
   ============================================================ */

CREATE TABLE QuizAttempts
(
    AttemptId INT IDENTITY(1,1) PRIMARY KEY,

    QuizId INT NOT NULL,

    StudentId NVARCHAR(450) NOT NULL,

    Score DECIMAL(5,2) NOT NULL DEFAULT 0,

    TotalMarks INT NOT NULL DEFAULT 0,

    ObtainedMarks INT NOT NULL DEFAULT 0,

    IsPassed BIT NOT NULL DEFAULT 0,

    StartedAt DATETIME2 NOT NULL DEFAULT GETDATE(),

    CompletedAt DATETIME2 NULL,

    CONSTRAINT FK_QuizAttempts_Quizzes
        FOREIGN KEY(QuizId)
        REFERENCES Quizzes(QuizId)
        ON DELETE CASCADE
);
GO


/* ============================================================
   13. QUIZ ANSWERS
   ============================================================ */

CREATE TABLE QuizAnswers
(
    AnswerId INT IDENTITY(1,1) PRIMARY KEY,

    AttemptId INT NOT NULL,

    QuestionId INT NOT NULL,

    SelectedOptionId INT NULL,

    IsCorrect BIT NOT NULL DEFAULT 0,

    MarksObtained INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_QuizAnswers_Attempts
        FOREIGN KEY(AttemptId)
        REFERENCES QuizAttempts(AttemptId)
        ON DELETE CASCADE,

    CONSTRAINT FK_QuizAnswers_Questions
        FOREIGN KEY(QuestionId)
        REFERENCES Questions(QuestionId),

    CONSTRAINT FK_QuizAnswers_Options
        FOREIGN KEY(SelectedOptionId)
        REFERENCES QuestionOptions(OptionId)
);
GO


/* ============================================================
   14. ASSIGNMENTS
   ============================================================ */

CREATE TABLE Assignments
(
    AssignmentId INT IDENTITY(1,1) PRIMARY KEY,

    CourseId INT NOT NULL,

    LessonId INT NULL,

    Title NVARCHAR(200) NOT NULL,

    Description NVARCHAR(MAX) NULL,

    DueDate DATETIME2 NULL,

    MaxMarks INT NOT NULL DEFAULT 100,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Assignments_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE,

    CONSTRAINT FK_Assignments_Lessons
        FOREIGN KEY(LessonId)
        REFERENCES Lessons(LessonId)
        ON DELETE NO ACTION
);
GO


/* ============================================================
   15. SUBMISSIONS
   ============================================================ */

CREATE TABLE Submissions
(
    SubmissionId INT IDENTITY(1,1) PRIMARY KEY,

    AssignmentId INT NOT NULL,

    StudentId NVARCHAR(450) NOT NULL,

    SubmissionText NVARCHAR(MAX) NULL,

    FileUrl NVARCHAR(500) NULL,

    SubmittedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    Marks DECIMAL(6,2) NULL,

    Feedback NVARCHAR(MAX) NULL,

    Status NVARCHAR(30) NOT NULL DEFAULT 'Submitted',

    GradedDate DATETIME2 NULL,

    CONSTRAINT FK_Submissions_Assignments
        FOREIGN KEY(AssignmentId)
        REFERENCES Assignments(AssignmentId)
        ON DELETE CASCADE,

    CONSTRAINT CK_Submissions_Status
        CHECK(Status IN ('Submitted','Graded','Late'))
);
GO


/* ============================================================
   16. CERTIFICATES
   ============================================================ */

CREATE TABLE Certificates
(
    CertificateId INT IDENTITY(1,1) PRIMARY KEY,

    CertificateNumber NVARCHAR(100) NOT NULL,

    StudentId NVARCHAR(450) NOT NULL,

    CourseId INT NOT NULL,

    IssueDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    FinalScore DECIMAL(5,2) NULL,

    CertificateUrl NVARCHAR(500) NULL,

    CONSTRAINT UQ_Certificate_Number
        UNIQUE(CertificateNumber),

    CONSTRAINT UQ_Student_Course_Certificate
        UNIQUE(StudentId, CourseId),

    CONSTRAINT FK_Certificates_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE
);
GO


/* ============================================================
   17. COURSE REVIEWS
   ============================================================ */

CREATE TABLE CourseReviews
(
    ReviewId INT IDENTITY(1,1) PRIMARY KEY,

    CourseId INT NOT NULL,

    StudentId NVARCHAR(450) NOT NULL,

    Rating INT NOT NULL,

    ReviewText NVARCHAR(2000) NULL,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    UpdatedDate DATETIME2 NULL,

    CONSTRAINT FK_CourseReviews_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE,

    CONSTRAINT UQ_Student_Course_Review
        UNIQUE(StudentId, CourseId),

    CONSTRAINT CK_CourseReviews_Rating
        CHECK(Rating BETWEEN 1 AND 5)
);
GO


/* ============================================================
   18. PAYMENTS
   ============================================================ */

CREATE TABLE Payments
(
    PaymentId INT IDENTITY(1,1) PRIMARY KEY,

    StudentId NVARCHAR(450) NOT NULL,

    CourseId INT NOT NULL,

    EnrollmentId INT NULL,

    Amount DECIMAL(18,2) NOT NULL,

    PaymentMethod NVARCHAR(50) NOT NULL,

    TransactionId NVARCHAR(200) NULL,

    PaymentStatus NVARCHAR(30) NOT NULL DEFAULT 'Pending',

    PaymentDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Payments_Courses
        FOREIGN KEY(CourseId)
        REFERENCES Courses(CourseId)
        ON DELETE CASCADE,

    CONSTRAINT FK_Payments_Enrollments
        FOREIGN KEY(EnrollmentId)
        REFERENCES Enrollments(EnrollmentId),

    CONSTRAINT CK_Payments_Status
        CHECK(PaymentStatus IN
        (
            'Pending',
            'Completed',
            'Failed',
            'Refunded'
        ))
);
GO


/* ============================================================
   19. ANNOUNCEMENTS
   ============================================================ */

CREATE TABLE Announcements
(
    AnnouncementId INT IDENTITY(1,1) PRIMARY KEY,

    Title NVARCHAR(200) NOT NULL,

    Message NVARCHAR(MAX) NOT NULL,

    CreatedBy NVARCHAR(450) NOT NULL,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),

    IsActive BIT NOT NULL DEFAULT 1
);
GO


/* ============================================================
   20. NOTIFICATIONS
   ============================================================ */

CREATE TABLE Notifications
(
    NotificationId INT IDENTITY(1,1) PRIMARY KEY,

    UserId NVARCHAR(450) NOT NULL,

    Title NVARCHAR(200) NOT NULL,

    Message NVARCHAR(1000) NOT NULL,

    NotificationType NVARCHAR(50) NULL,

    IsRead BIT NOT NULL DEFAULT 0,

    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO


/* ============================================================
   21. INDEXES
   ============================================================ */

CREATE INDEX IX_Courses_CategoryId
ON Courses(CategoryId);

CREATE INDEX IX_Courses_InstructorId
ON Courses(InstructorId);

CREATE INDEX IX_Courses_Status
ON Courses(Status);

CREATE INDEX IX_Modules_CourseId
ON Modules(CourseId);

CREATE INDEX IX_Lessons_ModuleId
ON Lessons(ModuleId);

CREATE INDEX IX_Enrollments_StudentId
ON Enrollments(StudentId);

CREATE INDEX IX_Enrollments_CourseId
ON Enrollments(CourseId);

CREATE INDEX IX_LessonProgress_StudentId
ON LessonProgress(StudentId);

CREATE INDEX IX_QuizAttempts_StudentId
ON QuizAttempts(StudentId);

CREATE INDEX IX_Submissions_StudentId
ON Submissions(StudentId);

CREATE INDEX IX_Payments_StudentId
ON Payments(StudentId);

GO


/* ============================================================
   22. INSERT CATEGORIES
   ============================================================ */

INSERT INTO Categories
(
    CategoryName,
    Description
)
VALUES
(
    'Programming',
    'Programming languages and software development'
),
(
    'Data Science',
    'Data science, analytics and statistics'
),
(
    'Machine Learning',
    'Machine learning and artificial intelligence'
),
(
    'Web Development',
    'Frontend and backend web development'
),
(
    'Database',
    'Database management and SQL'
),
(
    'Computer Science',
    'Computer science fundamentals'
);
GO


/* ============================================================
   23. INSERT SAMPLE COURSES
   ============================================================ */

INSERT INTO Courses
(
    CategoryId,
    InstructorId,
    Title,
    Description,
    Thumbnail,
    Price,
    Level,
    DurationInHours,
    Status
)
VALUES
(
    1,
    'INSTRUCTOR-001',
    'C# Programming Fundamentals',
    'Learn C# programming from beginner to intermediate level.',
    'csharp.jpg',
    999.00,
    'Beginner',
    20,
    'Published'
),
(
    3,
    'INSTRUCTOR-001',
    'Machine Learning Fundamentals',
    'Learn machine learning algorithms and practical implementation.',
    'machine-learning.jpg',
    1499.00,
    'Intermediate',
    30,
    'Published'
),
(
    5,
    'INSTRUCTOR-001',
    'SQL Server Masterclass',
    'Learn SQL Server, queries, joins, procedures and database design.',
    'sql-server.jpg',
    799.00,
    'Beginner',
    15,
    'Published'
);
GO


/* ============================================================
   24. INSERT MODULES
   ============================================================ */

INSERT INTO Modules
(
    CourseId,
    ModuleName,
    Description,
    ModuleOrder
)
VALUES
(
    1,
    'C# Basics',
    'Introduction to C# programming',
    1
),
(
    1,
    'Object Oriented Programming',
    'Classes, objects and inheritance',
    2
),
(
    2,
    'Introduction to Machine Learning',
    'ML fundamentals and workflow',
    1
),
(
    2,
    'Supervised Learning',
    'Classification and regression',
    2
),
(
    3,
    'SQL Fundamentals',
    'SQL Server basics',
    1
),
(
    3,
    'Advanced SQL',
    'Stored procedures, views and optimization',
    2
);
GO


/* ============================================================
   25. INSERT LESSONS
   ============================================================ */

INSERT INTO Lessons
(
    ModuleId,
    Title,
    Description,
    LessonType,
    VideoUrl,
    DurationInMinutes,
    LessonOrder,
    IsPreview
)
VALUES
(
    1,
    'Introduction to C#',
    'Introduction to C# and .NET',
    'Video',
    'https://example.com/csharp-intro',
    30,
    1,
    1
),
(
    1,
    'Variables and Data Types',
    'Understanding C# variables',
    'Video',
    'https://example.com/csharp-variables',
    40,
    2,
    0
),
(
    2,
    'Classes and Objects',
    'Introduction to OOP',
    'Video',
    'https://example.com/classes',
    45,
    1,
    0
),
(
    3,
    'What is Machine Learning?',
    'Introduction to ML',
    'Video',
    'https://example.com/ml-intro',
    35,
    1,
    1
),
(
    3,
    'ML Workflow',
    'Machine learning workflow',
    'Article',
    NULL,
    25,
    2,
    0
),
(
    5,
    'SQL SELECT Statement',
    'Introduction to SELECT',
    'Video',
    'https://example.com/sql-select',
    30,
    1,
    1
),
(
    5,
    'WHERE Clause',
    'Filtering SQL data',
    'Video',
    'https://example.com/sql-where',
    25,
    2,
    0
);
GO


/* ============================================================
   26. INSERT QUIZ
   ============================================================ */

INSERT INTO Quizzes
(
    CourseId,
    LessonId,
    Title,
    Description,
    PassingPercentage,
    TimeLimitMinutes,
    TotalMarks
)
VALUES
(
    2,
    NULL,
    'Machine Learning Fundamentals Quiz',
    'Basic machine learning assessment',
    40,
    30,
    10
);
GO


/* ============================================================
   27. INSERT QUESTIONS
   ============================================================ */

INSERT INTO Questions
(
    QuizId,
    QuestionText,
    Marks,
    QuestionOrder
)
VALUES
(
    1,
    'Which of the following is a supervised learning algorithm?',
    1,
    1
),
(
    1,
    'Which library is commonly used for machine learning in Python?',
    1,
    2
),
(
    1,
    'What is the purpose of a training dataset?',
    1,
    3
);
GO


/* ============================================================
   28. INSERT QUESTION OPTIONS
   ============================================================ */

INSERT INTO QuestionOptions
(
    QuestionId,
    OptionText,
    IsCorrect,
    OptionOrder
)
VALUES
(
    1,
    'Linear Regression',
    1,
    1
),
(
    1,
    'K-Means',
    0,
    2
),
(
    1,
    'Apriori',
    0,
    3
),
(
    1,
    'PCA',
    0,
    4
),

(
    2,
    'Scikit-learn',
    1,
    1
),
(
    2,
    'Photoshop',
    0,
    2
),
(
    2,
    'Bootstrap',
    0,
    3
),
(
    2,
    'IIS',
    0,
    4
),

(
    3,
    'Train the model',
    1,
    1
),
(
    3,
    'Only store images',
    0,
    2
),
(
    3,
    'Create a website',
    0,
    3
),
(
    3,
    'Send emails',
    0,
    4
);
GO


/* ============================================================
   29. STORED PROCEDURE
       GET ALL PUBLISHED COURSES
   ============================================================ */

CREATE PROCEDURE sp_GetPublishedCourses
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        c.CourseId,
        c.Title,
        c.Description,
        c.Thumbnail,
        c.Price,
        c.Level,
        c.DurationInHours,
        c.Rating,
        c.TotalStudents,
        cat.CategoryName
    FROM Courses c
    INNER JOIN Categories cat
        ON c.CategoryId = cat.CategoryId
    WHERE c.Status = 'Published'
    ORDER BY c.CreatedDate DESC;

END
GO


/* ============================================================
   30. GET COURSE BY ID
   ============================================================ */

CREATE PROCEDURE sp_GetCourseById
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        c.CourseId,
        c.Title,
        c.Description,
        c.Thumbnail,
        c.Price,
        c.Level,
        c.DurationInHours,
        c.Status,
        c.Rating,
        c.TotalStudents,
        cat.CategoryName
    FROM Courses c
    INNER JOIN Categories cat
        ON c.CategoryId = cat.CategoryId
    WHERE c.CourseId = @CourseId;

END
GO


/* ============================================================
   31. GET COURSE MODULES
   ============================================================ */

CREATE PROCEDURE sp_GetCourseModules
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        ModuleId,
        CourseId,
        ModuleName,
        Description,
        ModuleOrder
    FROM Modules
    WHERE CourseId = @CourseId
    ORDER BY ModuleOrder;

END
GO


/* ============================================================
   32. GET MODULE LESSONS
   ============================================================ */

CREATE PROCEDURE sp_GetModuleLessons
    @ModuleId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        LessonId,
        ModuleId,
        Title,
        Description,
        LessonType,
        VideoUrl,
        Content,
        ResourceUrl,
        DurationInMinutes,
        LessonOrder,
        IsPreview
    FROM Lessons
    WHERE ModuleId = @ModuleId
    ORDER BY LessonOrder;

END
GO


/* ============================================================
   33. ENROLL STUDENT
   ============================================================ */

CREATE PROCEDURE sp_EnrollStudent
    @StudentId NVARCHAR(450),
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM Enrollments
        WHERE StudentId = @StudentId
        AND CourseId = @CourseId
        AND Status <> 'Cancelled'
    )
    BEGIN

        RAISERROR('Student is already enrolled in this course.',16,1);
        RETURN;

    END

    INSERT INTO Enrollments
    (
        StudentId,
        CourseId,
        Status
    )
    VALUES
    (
        @StudentId,
        @CourseId,
        'Active'
    );

    UPDATE Courses
    SET TotalStudents = TotalStudents + 1
    WHERE CourseId = @CourseId;

END
GO


/* ============================================================
   34. GET STUDENT COURSES
   ============================================================ */

CREATE PROCEDURE sp_GetStudentCourses
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        e.EnrollmentId,
        e.StudentId,
        e.CourseId,
        e.EnrollmentDate,
        e.Status,
        e.CompletionPercentage,
        c.Title,
        c.Thumbnail,
        c.Level,
        c.DurationInHours
    FROM Enrollments e
    INNER JOIN Courses c
        ON e.CourseId = c.CourseId
    WHERE e.StudentId = @StudentId
    AND e.Status <> 'Cancelled'
    ORDER BY e.EnrollmentDate DESC;

END
GO


/* ============================================================
   35. MARK LESSON COMPLETE
   ============================================================ */

CREATE PROCEDURE sp_MarkLessonComplete
    @StudentId NVARCHAR(450),
    @LessonId INT
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM LessonProgress
        WHERE StudentId = @StudentId
        AND LessonId = @LessonId
    )
    BEGIN

        UPDATE LessonProgress
        SET
            IsCompleted = 1,
            CompletedDate = GETDATE(),
            LastAccessedDate = GETDATE()
        WHERE StudentId = @StudentId
        AND LessonId = @LessonId;

    END
    ELSE
    BEGIN

        INSERT INTO LessonProgress
        (
            StudentId,
            LessonId,
            IsCompleted,
            CompletedDate
        )
        VALUES
        (
            @StudentId,
            @LessonId,
            1,
            GETDATE()
        );

    END

END
GO


/* ============================================================
   36. GET COURSE PROGRESS
   ============================================================ */

CREATE PROCEDURE sp_GetCourseProgress
    @StudentId NVARCHAR(450),
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @TotalLessons INT;
    DECLARE @CompletedLessons INT;

    SELECT
        @TotalLessons = COUNT(l.LessonId)
    FROM Lessons l
    INNER JOIN Modules m
        ON l.ModuleId = m.ModuleId
    WHERE m.CourseId = @CourseId;

    SELECT
        @CompletedLessons = COUNT(lp.ProgressId)
    FROM LessonProgress lp
    INNER JOIN Lessons l
        ON lp.LessonId = l.LessonId
    INNER JOIN Modules m
        ON l.ModuleId = m.ModuleId
    WHERE lp.StudentId = @StudentId
    AND m.CourseId = @CourseId
    AND lp.IsCompleted = 1;

    SELECT
        @TotalLessons AS TotalLessons,
        @CompletedLessons AS CompletedLessons,
        CASE
            WHEN @TotalLessons = 0 THEN 0
            ELSE
                CAST(
                    (@CompletedLessons * 100.0)
                    / @TotalLessons
                    AS DECIMAL(5,2)
                )
        END AS CompletionPercentage;

END
GO


/* ============================================================
   37. CREATE QUIZ ATTEMPT
   ============================================================ */

CREATE PROCEDURE sp_CreateQuizAttempt
    @QuizId INT,
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @TotalMarks INT;

    SELECT
        @TotalMarks = ISNULL(SUM(Marks),0)
    FROM Questions
    WHERE QuizId = @QuizId;

    INSERT INTO QuizAttempts
    (
        QuizId,
        StudentId,
        TotalMarks
    )
    VALUES
    (
        @QuizId,
        @StudentId,
        @TotalMarks
    );

    SELECT SCOPE_IDENTITY() AS AttemptId;

END
GO


/* ============================================================
   38. GET QUIZ QUESTIONS
   ============================================================ */

CREATE PROCEDURE sp_GetQuizQuestions
    @QuizId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        q.QuestionId,
        q.QuestionText,
        q.Marks,
        q.QuestionOrder,
        o.OptionId,
        o.OptionText,
        o.OptionOrder
    FROM Questions q
    LEFT JOIN QuestionOptions o
        ON q.QuestionId = o.QuestionId
    WHERE q.QuizId = @QuizId
    ORDER BY
        q.QuestionOrder,
        o.OptionOrder;

END
GO


/* ============================================================
   39. SAVE QUIZ ANSWER
   ============================================================ */

CREATE PROCEDURE sp_SaveQuizAnswer
    @AttemptId INT,
    @QuestionId INT,
    @SelectedOptionId INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IsCorrect BIT = 0;
    DECLARE @Marks INT = 0;

    SELECT
        @IsCorrect = IsCorrect
    FROM QuestionOptions
    WHERE OptionId = @SelectedOptionId
    AND QuestionId = @QuestionId;

    IF @IsCorrect = 1
    BEGIN
        SELECT @Marks = Marks
        FROM Questions
        WHERE QuestionId = @QuestionId;
    END

    IF EXISTS
    (
        SELECT 1
        FROM QuizAnswers
        WHERE AttemptId = @AttemptId
        AND QuestionId = @QuestionId
    )
    BEGIN

        UPDATE QuizAnswers
        SET
            SelectedOptionId = @SelectedOptionId,
            IsCorrect = @IsCorrect,
            MarksObtained = @Marks
        WHERE AttemptId = @AttemptId
        AND QuestionId = @QuestionId;

    END
    ELSE
    BEGIN

        INSERT INTO QuizAnswers
        (
            AttemptId,
            QuestionId,
            SelectedOptionId,
            IsCorrect,
            MarksObtained
        )
        VALUES
        (
            @AttemptId,
            @QuestionId,
            @SelectedOptionId,
            @IsCorrect,
            @Marks
        );

    END

END
GO


/* ============================================================
   40. SUBMIT QUIZ
   ============================================================ */

CREATE PROCEDURE sp_SubmitQuiz
    @AttemptId INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE
        @TotalMarks INT,
        @ObtainedMarks INT,
        @PassingPercentage DECIMAL(5,2),
        @Score DECIMAL(5,2),
        @IsPassed BIT;

    SELECT
        @TotalMarks = qa.TotalMarks,
        @PassingPercentage = q.PassingPercentage
    FROM QuizAttempts qa
    INNER JOIN Quizzes q
        ON qa.QuizId = q.QuizId
    WHERE qa.AttemptId = @AttemptId;

    SELECT
        @ObtainedMarks = ISNULL(SUM(MarksObtained),0)
    FROM QuizAnswers
    WHERE AttemptId = @AttemptId;

    SET @Score =
        CASE
            WHEN @TotalMarks = 0 THEN 0
            ELSE
                (@ObtainedMarks * 100.0) / @TotalMarks
        END;

    SET @IsPassed =
        CASE
            WHEN @Score >= @PassingPercentage THEN 1
            ELSE 0
        END;

    UPDATE QuizAttempts
    SET
        ObtainedMarks = @ObtainedMarks,
        Score = @Score,
        IsPassed = @IsPassed,
        CompletedAt = GETDATE()
    WHERE AttemptId = @AttemptId;

    SELECT
        AttemptId,
        TotalMarks,
        ObtainedMarks,
        Score,
        IsPassed,
        CompletedAt
    FROM QuizAttempts
    WHERE AttemptId = @AttemptId;

END
GO


/* ============================================================
   41. GET STUDENT QUIZ RESULTS
   ============================================================ */

CREATE PROCEDURE sp_GetStudentQuizResults
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        qa.AttemptId,
        q.Title AS QuizTitle,
        c.Title AS CourseTitle,
        qa.Score,
        qa.TotalMarks,
        qa.ObtainedMarks,
        qa.IsPassed,
        qa.StartedAt,
        qa.CompletedAt
    FROM QuizAttempts qa
    INNER JOIN Quizzes q
        ON qa.QuizId = q.QuizId
    INNER JOIN Courses c
        ON q.CourseId = c.CourseId
    WHERE qa.StudentId = @StudentId
    ORDER BY qa.CompletedAt DESC;

END
GO


/* ============================================================
   42. GET INSTRUCTOR COURSES
   ============================================================ */

CREATE PROCEDURE sp_GetInstructorCourses
    @InstructorId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        c.CourseId,
        c.Title,
        c.Price,
        c.Level,
        c.Status,
        c.Rating,
        c.TotalStudents,
        c.CreatedDate,
        cat.CategoryName
    FROM Courses c
    INNER JOIN Categories cat
        ON c.CategoryId = cat.CategoryId
    WHERE c.InstructorId = @InstructorId
    ORDER BY c.CreatedDate DESC;

END
GO


/* ============================================================
   43. ADMIN DASHBOARD STATISTICS
   ============================================================ */

CREATE PROCEDURE sp_GetAdminDashboardStats
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*) FROM Categories) AS TotalCategories,

        (SELECT COUNT(*) FROM Courses) AS TotalCourses,

        (SELECT COUNT(*) FROM Courses
         WHERE Status = 'Published') AS PublishedCourses,

        (SELECT COUNT(*) FROM Enrollments
         WHERE Status <> 'Cancelled') AS TotalEnrollments,

        (SELECT COUNT(*) FROM Certificates) AS TotalCertificates,

        (SELECT COUNT(*) FROM Payments
         WHERE PaymentStatus = 'Completed') AS SuccessfulPayments,

        (SELECT ISNULL(SUM(Amount),0)
         FROM Payments
         WHERE PaymentStatus = 'Completed') AS TotalRevenue;

END
GO


/* ============================================================
   44. STUDENT DASHBOARD STATISTICS
   ============================================================ */

CREATE PROCEDURE sp_GetStudentDashboardStats
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        (
            SELECT COUNT(*)
            FROM Enrollments
            WHERE StudentId = @StudentId
            AND Status = 'Active'
        ) AS ActiveCourses,

        (
            SELECT COUNT(*)
            FROM Enrollments
            WHERE StudentId = @StudentId
            AND Status = 'Completed'
        ) AS CompletedCourses,

        (
            SELECT COUNT(*)
            FROM Certificates
            WHERE StudentId = @StudentId
        ) AS Certificates,

        (
            SELECT COUNT(*)
            FROM QuizAttempts
            WHERE StudentId = @StudentId
            AND CompletedAt IS NOT NULL
        ) AS CompletedQuizzes;

END
GO


/* ============================================================
   45. INSTRUCTOR DASHBOARD STATISTICS
   ============================================================ */

CREATE PROCEDURE sp_GetInstructorDashboardStats
    @InstructorId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        (
            SELECT COUNT(*)
            FROM Courses
            WHERE InstructorId = @InstructorId
        ) AS TotalCourses,

        (
            SELECT ISNULL(SUM(TotalStudents),0)
            FROM Courses
            WHERE InstructorId = @InstructorId
        ) AS TotalStudents,

        (
            SELECT ISNULL(SUM(p.Amount),0)
            FROM Payments p
            INNER JOIN Courses c
                ON p.CourseId = c.CourseId
            WHERE c.InstructorId = @InstructorId
            AND p.PaymentStatus = 'Completed'
        ) AS TotalRevenue,

        (
            SELECT
                ISNULL(AVG(c.Rating),0)
            FROM Courses c
            WHERE c.InstructorId = @InstructorId
            AND c.Rating > 0
        ) AS AverageRating;

END
GO


/* ============================================================
   46. SEARCH COURSES
   ============================================================ */

CREATE PROCEDURE sp_SearchCourses
    @Search NVARCHAR(200) = NULL,
    @CategoryId INT = NULL,
    @Level NVARCHAR(50) = NULL
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        c.CourseId,
        c.Title,
        c.Description,
        c.Thumbnail,
        c.Price,
        c.Level,
        c.DurationInHours,
        c.Rating,
        c.TotalStudents,
        cat.CategoryName
    FROM Courses c
    INNER JOIN Categories cat
        ON c.CategoryId = cat.CategoryId
    WHERE c.Status = 'Published'

    AND
    (
        @Search IS NULL
        OR c.Title LIKE '%' + @Search + '%'
        OR c.Description LIKE '%' + @Search + '%'
    )

    AND
    (
        @CategoryId IS NULL
        OR c.CategoryId = @CategoryId
    )

    AND
    (
        @Level IS NULL
        OR c.Level = @Level
    )

    ORDER BY c.CreatedDate DESC;

END
GO


/* ============================================================
   47. UPDATE COURSE RATING
   ============================================================ */

CREATE PROCEDURE sp_UpdateCourseRating
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE Courses
    SET Rating =
    (
        SELECT ISNULL(AVG(CAST(Rating AS DECIMAL(3,2))),0)
        FROM CourseReviews
        WHERE CourseId = @CourseId
    )
    WHERE CourseId = @CourseId;

END
GO


/* ============================================================
   48. GET COURSE REVIEWS
   ============================================================ */

CREATE PROCEDURE sp_GetCourseReviews
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        ReviewId,
        StudentId,
        Rating,
        ReviewText,
        CreatedDate,
        UpdatedDate
    FROM CourseReviews
    WHERE CourseId = @CourseId
    ORDER BY CreatedDate DESC;

END
GO


/* ============================================================
   49. GENERATE CERTIFICATE
   ============================================================ */

CREATE PROCEDURE sp_GenerateCertificate
    @StudentId NVARCHAR(450),
    @CourseId INT,
    @FinalScore DECIMAL(5,2)
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM Certificates
        WHERE StudentId = @StudentId
        AND CourseId = @CourseId
    )
    BEGIN

        SELECT
            CertificateId,
            CertificateNumber,
            StudentId,
            CourseId,
            IssueDate,
            FinalScore,
            CertificateUrl
        FROM Certificates
        WHERE StudentId = @StudentId
        AND CourseId = @CourseId;

        RETURN;

    END

    DECLARE @CertificateNumber NVARCHAR(100);

    SET @CertificateNumber =
        'LMS-' +
        CONVERT(NVARCHAR(20), YEAR(GETDATE())) +
        '-' +
        RIGHT(
            '000000' +
            CONVERT(NVARCHAR(20), ABS(CHECKSUM(NEWID()))),
            6
        );

    INSERT INTO Certificates
    (
        CertificateNumber,
        StudentId,
        CourseId,
        FinalScore
    )
    VALUES
    (
        @CertificateNumber,
        @StudentId,
        @CourseId,
        @FinalScore
    );

    SELECT
        CertificateId,
        CertificateNumber,
        StudentId,
        CourseId,
        IssueDate,
        FinalScore,
        CertificateUrl
    FROM Certificates
    WHERE CertificateId = SCOPE_IDENTITY();

END
GO


/* ============================================================
   50. GET STUDENT CERTIFICATES
   ============================================================ */

CREATE PROCEDURE sp_GetStudentCertificates
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        cert.CertificateId,
        cert.CertificateNumber,
        cert.IssueDate,
        cert.FinalScore,
        cert.CertificateUrl,
        c.Title AS CourseTitle
    FROM Certificates cert
    INNER JOIN Courses c
        ON cert.CourseId = c.CourseId
    WHERE cert.StudentId = @StudentId
    ORDER BY cert.IssueDate DESC;

END
GO


/* ============================================================
   51. GET ALL STUDENTS ENROLLED IN COURSE
   ============================================================ */

CREATE PROCEDURE sp_GetCourseStudents
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        e.EnrollmentId,
        e.StudentId,
        e.EnrollmentDate,
        e.Status,
        e.CompletionPercentage
    FROM Enrollments e
    WHERE e.CourseId = @CourseId
    ORDER BY e.EnrollmentDate DESC;

END
GO


/* ============================================================
   52. GET ALL ASSIGNMENTS
   ============================================================ */

CREATE PROCEDURE sp_GetCourseAssignments
    @CourseId INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        AssignmentId,
        CourseId,
        LessonId,
        Title,
        Description,
        DueDate,
        MaxMarks,
        CreatedDate
    FROM Assignments
    WHERE CourseId = @CourseId
    ORDER BY DueDate;

END
GO


/* ============================================================
   53. GET STUDENT SUBMISSIONS
   ============================================================ */

CREATE PROCEDURE sp_GetStudentSubmissions
    @StudentId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        s.SubmissionId,
        s.AssignmentId,
        a.Title AS AssignmentTitle,
        s.SubmittedDate,
        s.Marks,
        s.Feedback,
        s.Status,
        s.GradedDate
    FROM Submissions s
    INNER JOIN Assignments a
        ON s.AssignmentId = a.AssignmentId
    WHERE s.StudentId = @StudentId
    ORDER BY s.SubmittedDate DESC;

END
GO


/* ============================================================
   54. CREATE NOTIFICATION
   ============================================================ */

CREATE PROCEDURE sp_CreateNotification
    @UserId NVARCHAR(450),
    @Title NVARCHAR(200),
    @Message NVARCHAR(1000),
    @NotificationType NVARCHAR(50) = NULL
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO Notifications
    (
        UserId,
        Title,
        Message,
        NotificationType
    )
    VALUES
    (
        @UserId,
        @Title,
        @Message,
        @NotificationType
    );

END
GO


/* ============================================================
   55. GET USER NOTIFICATIONS
   ============================================================ */

CREATE PROCEDURE sp_GetUserNotifications
    @UserId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        NotificationId,
        Title,
        Message,
        NotificationType,
        IsRead,
        CreatedDate
    FROM Notifications
    WHERE UserId = @UserId
    ORDER BY CreatedDate DESC;

END
GO


/* ============================================================
   56. MARK NOTIFICATION AS READ
   ============================================================ */

CREATE PROCEDURE sp_MarkNotificationRead
    @NotificationId INT,
    @UserId NVARCHAR(450)
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE Notifications
    SET IsRead = 1
    WHERE NotificationId = @NotificationId
    AND UserId = @UserId;

END
GO


/* ============================================================
   57. DATABASE SUMMARY
   ============================================================ */

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO


/* ============================================================
   END OF LMS DATABASE SCRIPT
   ============================================================ */