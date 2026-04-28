INSERT INTO Users VALUES (1, 'Guest', null,null, null,null, null, null, null);
INSERT INTO Users VALUES (2, 'Bill', 'PasswordHere', 'billboy@yahoo.com', 2, 1, 0, 0, 0);
INSERT INTO Users VALUES (3, 'Bob', 'PasswordHere', 'bobby@hotmail.co.uk', 7, 1, 0, 2, 0);
INSERT INTO Users VALUES (4, 'Ross', 'PasswordHere', 'rossbob@outlook.com', 6, 1, 0, 4, 0);
INSERT INTO Users VALUES (5, 'Steve', 'PasswordHere', 'steveneven@gmail.com', 4, 1, 0, 5, 20);
INSERT INTO Users VALUES (6,'test', '$2a$12$DK0nnutcRQTkgVMfVSqX3uBQY7YLkG06Cxr1FULFcdPZxrs9ZOcP2', 'test@gmail.com', 0, 0, 0, 6, 10);

INSERT INTO Products VALUES (1, 'JorgeBean','jorge_bean.jpeg', 'The rich mexican Jorge bean',12.99, 10);
INSERT INTO Products VALUES (2, 'Ethiopian Yirgacheffe', 'Ethiopian_Yirgacheffe.webp','Filled with  joy and flavour',4.99, 256);
INSERT INTO Products VALUES (3, 'Colombian Supremo', 'Colombian_Supremo.webp','Authentic colombian taste',3.99, 300);
INSERT INTO Products VALUES (4, 'Guatemalan Antigua', 'Guatemalan_Antigua.webp','Makes you taste nostalgia',7.99, 112);
INSERT INTO Products VALUES (5, 'Kenyan AA','Kenyan_AA.jpg', 'Strong start to your morning',10.99, 400);
INSERT INTO Products VALUES (6, 'Amazonian Blend','Amazonian_blend.jpeg', 'Feel the river flow',6.59, 398);

INSERT INTO Transactions VALUES (1,1, 10, 12.99, 24032026, 'Pending', false, 0);
INSERT INTO Transactions VALUES (2,2, 12, 24.54, 24032026, 'Pending', true, 0);
INSERT INTO Transactions VALUES (3,3, 3, 3.99, 24032026, 'Pending', true, 0);

INSERT INTO Feedbacks (FeedbackId, UserId, TransactionId, IssueContent, RefundRequest, RefundReason, TicketNumber)
VALUES (1, 1, 1, 'I dislike the fact that BBC coffee has not released more BBC into the world.', '1', 'I want to', 1);

INSERT INTO Feedbacks VALUES (2, 4, 2, 'I am scrumming right now. For no particular reason.', '1', '', 2);

INSERT INTO Coffees VALUES (1, 'Roniccino', 'roniccino.jpg', '', 2.99);

INSERT INTO Coffees VALUES(2, 'Azmocha', 'Azmocha.png', '', 2.99);

INSERT INTO Coffees VALUES(3, 'Steffspresso', 'Steffspresso.png', '', 2.29);

INSERT INTO Coffees VALUES(4, 'Sonnycaf', 'SonnyCaf.png', '', 1.99);

INSERT INTO Coffees VALUES (5, 'Jortado', 'Jortado.png', '', 3.29);

INSERT INTO Coffees VALUES (6, 'Samacchiato', 'Samacchiarto.png', '', 1.99);


INSERT INTO Sizes VALUES(1, 'Small', 0.8);
INSERT INTO Sizes VALUES(2, 'Medium', 1.4);
INSERT INTO Sizes VALUES(3, 'Large', 2);

INSERT INTO MilkTypes VALUES(1, 'Whole Milk', 0);
INSERT INTO MilkTypes VALUES(2, 'Oat Milk', 1);
INSERT INTO MilkTypes VALUES(3, 'Soy Milk', 2);
