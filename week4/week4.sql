-- update acc to your schema and use

USE CS405_FestMgmt;
DESCRIBE Event;
DESCRIBE Team;
INSERT INTO Team(team_id, team_name, team_type)
VALUES(1, 'T4', 'ORG');

SELECT * FROM Event;

INSERT INTO Event(event_id, event_name, building, floor, room_no, price, team_id)
VALUES (1, 'AI Hackathon', 'Seminar Hall', 2, 205, 900.00, 1);

SELECT * FROM Event;

-- Update the quantity of 'Mushroom Risotto' in stall 'S1' to 25.
INSERT INTO Stall(stall_id, name)
VALUES (1, 'S1');

INSERT INTO Item(name)
VALUES ('Mushroom Risotto');

DESCRIBE Stall_Items;
ALTER TABLE Stall_Items 
ADD COLUMN price_per_unit FLOAT(5,2);

INSERT INTO Stall_Items(stall_id, item_name, price_per_unit)
VALUES (1, "Mushroom Risotto", 25);

SELECT * FROM Stall_Items;

-- Delete all registrations where the event ID is '1' and SRN starts with 'P100'
DESCRIBE Registration;
-- update participants table
DESCRIBE Participant;
INSERT INTO Participant(srn, name, gender, department, semester)
VALUES ('P100ABC', 'Pranav', 'M', 'CSE', 5);

-- add dummy value
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (1, 001, 'P100ABC');

SELECT * FROM Registration
WHERE event_id = '1'
  AND srn LIKE 'P100%';
  
-- now delete it
DELETE FROM Registration
WHERE event_id = '1'
  AND srn LIKE 'P100%';

SELECT * FROM Registration
WHERE event_id = '1'
  AND srn LIKE 'P100%';
  
-- Insert a new purchase: 'P1017' buys 3 'Fish Tacos' from stall 'S6' at '2025-07-10 14:00:00'
-- add dummy value
INSERT INTO Participant(srn, name, gender, department, semester)
VALUES ('P1017', 'Rajesh', 'M', 'CSE', 5);
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (1, 002, 'P1017');

-- add stall 6 and fish taco
INSERT INTO Stall(stall_id, name)
VALUES (6, 'S6');

INSERT INTO Item(name)
VALUES ('Fish Taco');

INSERT INTO Stall_Items(stall_id, item_name, price_per_unit)
VALUES (6, "Fish Taco", 50);

SELECT * FROM Stall_Items;

SELECT * FROM Purchased
WHERE srn LIKE 'P1017';

INSERT INTO Purchased(srn, stall_id, item_name, time_stamp, quantity)
Values('P1017', 6, 'Fish Taco', '2025-07-10 14:00:00', 3);

SELECT * FROM Purchased
WHERE srn LIKE 'P1017';

-- Task 2

-- chapri college gave wrong schema last lab so gotta fix it to complete this assignment
DROP TABLE Registration;
CREATE TABLE Registration(
    reg_no INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    srn VARCHAR(20),
    FOREIGN KEY (srn) REFERENCES Participant(srn),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
);
-- dummy values

INSERT INTO Team(team_id, team_name, team_type)
VALUES (2, 'T5', 'ORG'),
       (3, 'Alpha', 'ORG');
       
INSERT INTO Event(event_id, event_name, building, floor, room_no, price, team_id)
VALUES (2, 'Code Sprint', 'Auditorium', 1, 101, 500.00, 2),
       (3, 'Math Quiz', 'Library', 3, 305, 200.00, 3),
       (4, 'Robotics Expo', 'Lab Block', 1, 110, 1000.00, 1),
       (5, 'Cybersecurity Workshop', 'Seminar Hall', 2, 206, 750.00, 2),
       (6, 'Golden Jubilee Special', 'MRD Auditorium', 0, 1, 0.00, 3);
       
INSERT INTO Participant(srn, name, gender, department, semester)
VALUES ('P1001', 'Aarav', 'M', 'CSE', 5),
       ('P1002', 'Ananya', 'F', 'ECE', 3),
       ('P1003', 'Ravi', 'M', 'ME', 7),
       ('P1004', 'Sneha', 'F', 'CSE', 1),
       ('P1005', 'Vikram', 'M', 'EEE', 5),
       ('P1006', 'Meera', 'F', 'CSE', 3);

-- Event 1 registrations
DESCRIBE Registration;
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (1, 003, 'P1001'),
       (1, 004, 'P1002'),
       (1, 005, 'P1003');



-- Event 5 registrations
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (5, 006, 'P1004'),
       (5, 007, 'P1005'),
       (5, 008, 'P1002');  -- note: P1002 appears in both 2 & 5
       
-- Event 2 regs
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (2, 009, 'P1001'),
       (2, 010, 'P1002'),
       (2, 011, 'P1003');

SELECT * from REGISTRATION WHERE event_id = 2;
-- Retrieve participants’s SRN who are registered only for event 'E2' or 'E5', but not both (using SET operations).
SELECT srn
FROM Registration
WHERE event_id = '2'
  AND srn NOT IN (
      SELECT srn FROM Registration WHERE event_id = '5'
  )
UNION
SELECT srn
FROM Registration
WHERE event_id = '5'
  AND srn NOT IN (
      SELECT srn FROM Registration WHERE event_id = '2'
  );

-- Display all participants and the names of all their visitors(if any) with a count of visitors.

-- dummy values for visitor
INSERT INTO Visitor(name, gender, age, participant_srn)
VALUES ('Kiran', 'M', 50, 'P1001'),
       ('Divya', 'F', 45, 'P1001'),
       ('Rohit', 'M', 24, 'P1004'),
       ('Rohan', 'M', 26, 'P1005');

SELECT 
    p.srn,
    p.name AS participant_name,
    v.name AS visitor_name,
    COUNT(v.name) OVER (PARTITION BY p.srn) AS visitor_count
FROM Participant p
LEFT JOIN Visitor v 
    ON p.srn = v.participant_srn
ORDER BY p.srn;

-- List events that have equal number of male and female participants
-- adding
INSERT INTO Registration(event_id, reg_no, srn)
VALUES (3, 012, 'P1001'),
       (3, 013, 'P1002'),
       (3, 014, 'P1003'),
       (3, 015, 'P1004');
       
SELECT e.event_id, e.event_name
FROM Event e
JOIN Registration r ON e.event_id = r.event_id
JOIN Participant p ON r.srn = p.srn
GROUP BY e.event_id, e.event_name
HAVING SUM(p.gender = 'M') = SUM(p.gender = 'F');

-- Display each event's name and a binary indicator of whether it occurred after the Golden Jubilee (year > 2047)

-- updating shit cuz these guys havent mentioed year before this section
INSERT INTO Fest(fest_id, fest_name, year, head_team_id)
VALUES (1, 'TechFest', 2045, 1),
       (2, 'FutureFest', 2050, 2);

UPDATE Team SET fest_id = 1 WHERE team_id = 1;
UPDATE Team SET fest_id = 2 WHERE team_id = 2;
UPDATE Team SET fest_id = 2 WHERE team_id = 3;

SELECT 
    e.event_name,
    CASE 
        WHEN f.year > 2047 THEN 1
        ELSE 0
    END AS after_golden_jubilee
FROM Event e
JOIN Team t ON e.team_id = t.team_id
JOIN Fest f ON t.fest_id = f.fest_id;


