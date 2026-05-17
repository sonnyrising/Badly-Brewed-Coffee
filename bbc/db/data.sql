INSERT INTO Users VALUES (1, 'Guest', null, null, null, null, null, null, null, null, null,null, null);
INSERT INTO Users VALUES (2, 'Admin123!', '$2a$12$CaNu0UwgSlOyXiQK3H4GrupctjoZbTMDv51fLx67xXSuVABTGat5K', '', 0, 0, 0, 0, 0, 0, 0, '2026-01-01', 'admin');
INSERT INTO Users VALUES (3, 'Staff123!', '$2a$12$abLeT270BPYLJ080Cnpg5uueu2UD7G2cxMbqicgAao9SbvZehSoDa', '', 0, 0, 0, 0, 0, 0, 0, '2026-01-01', 'staff');
INSERT INTO Users VALUES (4, 'User123!', '$2a$12$uB1ft5Wdr8T5J66mnrKUo.uFBtggB7BLO0r2G9r/CELbBeYJuQO0S', '', 0, 0, 0, 0, 0, 0, 0, '2026-01-01', 'user');
INSERT INTO Users VALUES (5, 'Manager123!', '$2a$12$IOX8hQeTd3MMhM4.Krtp.OuVetpGe/PQ7KJN22IiKt.vtf7VO20rO', '', 0, 0, 0, 0, 0, 0, 0, '2026-01-01', 'manager');
INSERT INTO Users VALUES (6, 'Suspended', 'Suspended123!',null, null, null, null, null, 1, null, null,null, null);

INSERT INTO Products VALUES (1, 'JorgeBean','jorge_bean.jpeg', 'The rich mexican Jorge bean', 'Extra Dark ;)', 'Mexico', 12.99, 10, 1);
INSERT INTO Products VALUES (2, 'Ethiopian Yirgacheffe', 'Ethiopian_Yirgacheffe.webp','Filled with  joy and flavour', 'Medium', 'Ethiopia', 4.99, 256, 1);
INSERT INTO Products VALUES (3, 'Colombian Supremo', 'Colombian_Supremo.webp','Authentic colombian taste', 'Light', 'Colombia', 3.99, 300, 1);
INSERT INTO Products VALUES (4, 'Guatemalan Antigua', 'Guatemalan_Antigua.webp','Makes you taste nostalgia', 'Light', 'Guatamala', 7.99, 112, 1);
INSERT INTO Products VALUES (5, 'Kenyan AA','Kenyan_AA.jpg', 'Strong start to your morning', 'Dark', 'Kenya', 10.99, 400, 1);
INSERT INTO Products VALUES (6, 'Amazonian Blend','Amazonian_blend.jpeg', 'Feel the river flow', 'Medium', 'Brazil', 6.59, 398, 1);
INSERT INTO Products VALUES (7, 'Roniccino', 'roniccino.jpg', '', 'Dark', 'Guatemala', 2.99, 100000, 0);
INSERT INTO Products VALUES(8, 'Azmocha', 'Azmocha.png', '', 'Light', 'Colombia', 2.99, 100000, 0);
INSERT INTO Products VALUES(9, 'Steffspresso', 'Steffspresso.png', '', 'Dark', 'Ethiopia', 2.29, 100000, 0);
INSERT INTO Products VALUES(10, 'Sonnycaf', 'SonnyCaf.png', '', 'Medium', 'Kenya', 1.99, 100000, 0);
INSERT INTO Products VALUES (11, 'Jortado', 'Jortado.png', '', 'Dark', 'Mexico', 3.29, 100000, 0);
INSERT INTO Products VALUES (12, 'Samacchiato', 'Samacchiarto.png', '', 'Light', 'Brazil', 1.99, 100000, 0);

INSERT INTO Transactions VALUES (1,1, 12.99, "SteffanRoad",24032026, 'Pending', false, null);
INSERT INTO Transactions VALUES (2,2, 24.54,"Sam grove", 24032026, 'Pending', true, null);
INSERT INTO Transactions VALUES (3,3, 3.99, "Sonny park avenue", 24032026, 'Pending', true, null);

INSERT INTO Feedbacks VALUES (1, 1, 1, 'I dislike the fact that BBC coffee has not released more BBC into the world.', '0', 'true', 1);
INSERT INTO Feedbacks VALUES (2, 4, 2, 'I am scrumming right now. For no particular reason.', '0', 'true', 2);


