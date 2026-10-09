CREATE DATABASE ProjectManagementDB;
GO

USE ProjectManagementDB;
GO

CREATE TABLE Projects
(
    ProjectId INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) NOT NULL
        DEFAULT 'Planned',

    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);
GO

CREATE TABLE Tasks
(
    TaskId INT PRIMARY KEY,
    ProjectId INT NOT NULL,
    TaskName VARCHAR(150) NOT NULL,

    ParentTaskId INT NULL,
    DependsOnTaskId INT NULL,

    AssignedTo VARCHAR(100) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) NOT NULL
        DEFAULT 'Pending',

    FOREIGN KEY (ProjectId)
        REFERENCES Projects(ProjectId),

    FOREIGN KEY (ParentTaskId)
        REFERENCES Tasks(TaskId),

    FOREIGN KEY (DependsOnTaskId)
        REFERENCES Tasks(TaskId),

    CHECK (ParentTaskId IS NULL
           OR ParentTaskId <> TaskId),

    CHECK (DependsOnTaskId IS NULL
           OR DependsOnTaskId <> TaskId),

    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

INSERT INTO Projects
    (ProjectId, ProjectName, StartDate, EndDate, Status)
VALUES
    (1, 'E-Commerce Application',
        '2026-10-01', '2026-12-31', 'In Progress'),

    (2, 'Employee Management System',
        '2026-10-05', '2027-01-31', 'Planned');

        INSERT INTO Tasks
    (TaskId, ProjectId, TaskName, ParentTaskId,
     DependsOnTaskId, AssignedTo, StartDate, EndDate, Status)
VALUES
-- Project 1: top-level tasks
(101, 1, 'Requirement Analysis', NULL, NULL,
 'Rahul', '2026-10-01', '2026-10-05', 'Completed'),

(102, 1, 'System Design', NULL, 101,
 'Amit', '2026-10-06', '2026-10-12', 'Completed'),

(103, 1, 'Backend Development', NULL, 102,
 'Priya', '2026-10-13', '2026-10-25', 'In Progress'),

(104, 1, 'Frontend Development', NULL, 102,
 'Neha', '2026-10-13', '2026-10-27', 'In Progress'),

(105, 1, 'Testing', NULL, 103,
 'Rohit', '2026-10-28', '2026-11-05', 'Pending'),

-- Subtasks of Backend Development
(106, 1, 'Database Design', 103, NULL,
 'Amit', '2026-10-13', '2026-10-16', 'Completed'),

(107, 1, 'Develop API', 103, 106,
 'Priya', '2026-10-17', '2026-10-23', 'In Progress'),

(108, 1, 'API Unit Testing', 103, 107,
 'Rohit', '2026-10-24', '2026-10-25', 'Pending'),

-- Project 2
(201, 2, 'Gather Employee Requirements', NULL, NULL,
 'Sneha', '2026-10-05', '2026-10-10', 'Planned'),

(202, 2, 'Design Employee Database', NULL, 201,
 'Amit', '2026-10-11', '2026-10-15', 'Planned');


 select * from dbo.Projects
 select * from dbo.Tasks