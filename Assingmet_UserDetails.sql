drop table UserDetails

CREATE TABLE UserDetails
(
    UserId INT  PRIMARY KEY,
    UserName VARCHAR(50),
    Password VARCHAR(50),
    Email VARCHAR(100),
    MobileNo VARCHAR(15),
    City VARCHAR(50)
);

INSERT INTO UserDetails
(UserId, UserName, Password, Email, MobileNo, City)
VALUES
(1,'AmitSharma','Amit@123','amit.sharma@gmail.com','9876543201','Delhi'),
(2,'PriyaVerma','Priya@123','priya.verma@gmail.com','9876543202','Mumbai'),
(3,'RahulGupta','Rahul@123','rahul.gupta@gmail.com','9876543203','Kolkata'),
(4,'SnehaPatel','Sneha@123','sneha.patel@gmail.com','9876543204','Ahmedabad'),
(5,'VikasSingh','Vikas@123','vikas.singh@gmail.com','9876543205','Lucknow'),
(6,'PoojaMehta','Pooja@123','pooja.mehta@gmail.com','9876543206','Pune'),
(7,'RohanDas','Rohan@123','rohan.das@gmail.com','9876543207','Bhubaneswar'),
(8,'NehaRoy','Neha@123','neha.roy@gmail.com','9876543208','Kolkata'),
(9,'ArjunKumar','Arjun@123','arjun.kumar@gmail.com','9876543209','Patna'),
(10,'AnjaliSaha','Anjali@123','anjali.saha@gmail.com','9876543210','Ranchi'),
(11,'SouravGhosh','Sourav@123','sourav.ghosh@gmail.com','9876543211','Howrah'),
(12,'RitikaMishra','Ritika@123','ritika.mishra@gmail.com','9876543212','Varanasi'),
(13,'DeepakYadav','Deepak@123','deepak.yadav@gmail.com','9876543213','Kanpur'),
(14,'KavitaJain','Kavita@123','kavita.jain@gmail.com','9876543214','Jaipur'),
(15,'ManishPandey','Manish@123','manish.pandey@gmail.com','9876543215','Indore'),
(16,'SwatiAgarwal','Swati@123','swati.agarwal@gmail.com','9876543216','Nagpur'),
(17,'AbhishekBose','Abhi@123','abhishek.bose@gmail.com','9876543217','Durgapur'),
(18,'NandiniSen','Nandini@123','nandini.sen@gmail.com','9876543218','Siliguri'),
(19,'KaranChatterjee','Karan@123','karan.chatterjee@gmail.com','9876543219','Asansol'),
(20,'MadhuriPaul','Madhuri@123','madhuri.paul@gmail.com','9876543220','Kharagpur');