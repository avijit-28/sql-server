CREATE TABLE USERS
(

UserID BIGINT PRIMARY KEY IDENTITY,
UserName VARCHAR(100) NOT NULL,
Roles VARCHAR(100) NOT NULL,
[Password] VARCHAR(100) NOT NULL,-- UserID is the auto-generated unique id-- UserName is the unique value i.e. Email ID of the user-- Roles can be ADMIN, SUPERADMIN OR USER-- WE CAN PROVIDE 1 OR MORE USER SEPARATED BY ','--INSERT THE FOLLOWING TEST DATA FOR TESTING PURPOSE
);
INSERT INTO USERS VALUES('superadmin@gmail.com','SUPERADMIN,ADMIN,USER', 'superadmin')
INSERT INTO USERS VALUES('admin@gmail.com','ADMIN', 'admin')
INSERT INTO USERS VALUES('adminuser@gmail.com','ADMIN,USER', 'adminuser')
INSERT INTO USERS VALUES('user@gmail.com','USER', 'user')