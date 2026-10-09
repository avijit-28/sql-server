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