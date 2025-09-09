USE CS405_FestMgmt;
-- Task 1: Triggers
/*
1) AFTER INSERT on Purchased: decrease stock in stall_items for that (stall_id, item_name).
2) BEFORE INSERT on Purchased: prevent quantity > 5 (raise error).
*/

DELIMITER $$
-- 1) AFTER INSERT trigger: decrement stock

DROP TRIGGER IF EXISTS purchase_decrement_stock$$
CREATE TRIGGER purchase_decrement_stock
AFTER INSERT ON Purchased
FOR EACH ROW
BEGIN
    -- Update stock in Stall_items
    UPDATE Stall_items
    SET stock = stock - NEW.quantity
    WHERE stall_id = NEW.stall_id
      AND item_name = NEW.item_name;
END$$

-- 2) BEFORE INSERT trigger: prevent quantity > 5
DROP TRIGGER IF EXISTS trg_max_qty$$
CREATE TRIGGER trg_max_qty
BEFORE INSERT ON Purchased
FOR EACH ROW
BEGIN
    IF NEW.quantity > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Purchase quantity cannot be greater than 5 units per transaction.';
    END IF;
END$$

/*
TASK 2: PROCEDURES
1) GetStallSales(stall_id): prints total revenue for that stall by summing price_per_unit * quantity
2) RegisterParticipant(event_id, in_srn, in_reg_no): inserts into Registration. If in_reg_no IS NULL, use auto-inc.
*/

-- Procedure: GetStallSales
DROP PROCEDURE IF EXISTS GetStallSales$$
CREATE PROCEDURE GetStallSales(IN in_stall_id INT)
BEGIN
    DECLARE total_revenue DECIMAL(15,2) DEFAULT 0.00;

    SELECT SUM(si.price_per_unit * p.quantity)
    INTO total_revenue
    FROM Purchased p
    JOIN Stall_items si
      ON p.stall_id = si.stall_id
     AND p.item_name = si.item_name
    WHERE p.stall_id = in_stall_id;

    -- If NULL (no sales), set to 0.00
    IF total_revenue IS NULL THEN
        SET total_revenue = 0.00;
    END IF;

    -- Print/return result (SELECT to show output in client)
    SELECT CONCAT('Total revenue for stall ', in_stall_id, ' = ') AS info, total_revenue AS total_revenue;
END$$

-- Procedure: RegisterParticipant
-- If in_reg_no IS NULL -> insert without reg_no (AUTO_INCREMENT), else insert with provided reg_no
DROP PROCEDURE IF EXISTS RegisterParticipant$$
CREATE PROCEDURE RegisterParticipant(
    IN in_event_id INT,
    IN in_srn VARCHAR(20),
    IN in_reg_no INT  -- pass NULL if you want AUTO_INCREMENT
)
BEGIN
    IF in_reg_no IS NULL THEN
        INSERT INTO Registration(event_id, srn) VALUES (in_event_id, in_srn);
    ELSE
        INSERT INTO Registration(reg_no, event_id, srn) VALUES (in_reg_no, in_event_id, in_srn);
    END IF;
END$$

/*
TASK 3: FUNCTIONS
1) GetEventCost(event_id) -> returns event.price
2) GetParticipantPurchaseTotal(in_srn) -> returns sum of price_per_unit * quantity for that participant
*/

-- Function: GetEventCost
DROP FUNCTION IF EXISTS GetEventCost$$
CREATE FUNCTION GetEventCost(in_event_id INT) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE ev_price DECIMAL(10,2) DEFAULT 0.00;

    SELECT price INTO ev_price
    FROM Event
    WHERE event_id = in_event_id
    LIMIT 1;

    IF ev_price IS NULL THEN
        SET ev_price = 0.00;
    END IF;

    RETURN ev_price;
END$$

-- Function: GetParticipantPurchaseTotal
DROP FUNCTION IF EXISTS GetParticipantPurchaseTotal$$
CREATE FUNCTION GetParticipantPurchaseTotal(in_srn VARCHAR(20)) RETURNS DECIMAL(15,2)
DETERMINISTIC
BEGIN
    DECLARE total_spent DECIMAL(15,2) DEFAULT 0.00;

    SELECT SUM(si.price_per_unit * p.quantity)
    INTO total_spent
    FROM Purchased p
    JOIN Stall_items si
      ON p.stall_id = si.stall_id
     AND p.item_name = si.item_name
    WHERE p.srn = in_srn;

    IF total_spent IS NULL THEN
        SET total_spent = 0.00;
    END IF;

    RETURN total_spent;
END$$

-- restore normal delimiter
DELIMITER ;


-- ----------------------------------------------------------------
-- Demonstration / sample runs (BEFORE / COMMAND / AFTER) for screenshots
-- ----------------------------------------------------------------

-- TASK 1 Demonstration
-- BEFORE: show Stall_items and Purchased definitions / sample data
DESCRIBE Stall_items;
DESCRIBE Purchased;
SELECT * FROM Stall_items;

INSERT INTO Item(name)
VALUES ('Sandwich'),
		('Shawarma');
        
-- Insert a known stall/item with stock and price_per_unit if not present (safe to run)
INSERT INTO Stall_items (stall_id, item_name, stock, price_per_unit)
VALUES (1, 'Sandwich', 100, 25.00),
       (6, 'Shawarma', 50, 50.00);

-- Show current stock for shawarma in stall 6
SELECT * FROM Stall_items WHERE stall_id = 6 AND item_name = 'Shawarma';

-- Valid purchase <=5 units (this should succeed and decrease stock)
INSERT INTO Purchased(srn, stall_id, item_name, time_stamp, quantity)
VALUES ('P1001', 6, 'Shawarma', '2025-09-09 10:00:00', 3);

-- check Stall_items stock decreased by 3
SELECT * FROM Stall_items WHERE stall_id = 6 AND item_name = 'Shawarma';

-- COMMAND: Invalid purchase > 5 units (should be blocked by BEFORE INSERT trigger)
-- This should raise an error: 'Purchase quantity cannot be greater than 5 units per transaction.'

INSERT INTO Purchased(srn, stall_id, item_name, time_stamp, quantity)
VALUES ('P1002', 6, 'Shawarma', '2025-09-09 11:00:00', 6);
SELECT * FROM Stall_items WHERE stall_id = 6 AND item_name = 'Shawarma';
-- TASK 2 Demonstration (Procedures)
-- BEFORE: show Purchased and Stall_items
DESCRIBE Purchased;
DESCRIBE Stall_items;

-- Adding pizza + shawarma, GetStallSales for stall 6
INSERT INTO Item(name)
VALUES ('Pizza');
INSERT INTO Stall_items (stall_id, item_name, stock, price_per_unit)
VALUES (6, 'Pizza', 100, 125.00);
INSERT INTO Purchased(srn, stall_id, item_name, time_stamp, quantity)
VALUES ('P1001', 6, 'Pizza', '2025-09-09 10:00:00', 3);
       
CALL GetStallSales(6);

-- COMMAND: RegisterParticipant demonstration
-- BEFORE: Show Registration rows for event 2
SELECT * FROM Registration WHERE event_id = 2;

-- Use procedure to register new SRN 'P1006' to event 2 using AUTO_INCREMENT
CALL RegisterParticipant(2, 'P1006', NULL);
SELECT * FROM Registration WHERE event_id = 2 AND srn = 'P1006';

-- Use procedure to insert with an explicit reg_no (example reg_no = 9999)
CALL RegisterParticipant(3, 'P1006', 9999);
SELECT * FROM Registration WHERE reg_no = 9999;

-- TASK 3 Demonstration (Functions)
DESCRIBE Event;

-- Get cost for event_id = 1
SELECT GetEventCost(1) AS event1_price;

SELECT GetParticipantPurchaseTotal('P1001') AS total_spent_by_P1001;

-- Extra: show all purchases and per-participant totals
SELECT p.srn, p.item_name, p.quantity, si.price_per_unit, (si.price_per_unit * p.quantity) AS amount
FROM Purchased p
JOIN Stall_items si ON p.stall_id = si.stall_id AND p.item_name = si.item_name
ORDER BY p.srn;

-- Show totals by participant using the function in a query
SELECT srn, GetParticipantPurchaseTotal(srn) AS total_spent
FROM (
    SELECT DISTINCT srn FROM Purchased
) t;

