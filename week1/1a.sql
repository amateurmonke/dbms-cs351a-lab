CREATE DATABASE CS405_FestMgmt;
USE CS405_FestMgmt;

CREATE TABLE Fest (
	fest_id INT PRIMARY KEY,
    fest_name VARCHAR(100) NOT NULL,
    year YEAR NOT NULL,
    head_team_id INT
);

CREATE TABLE Team(
	team_id INT PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    team_type ENUM('MNG', 'ORG') DEFAULT 'ORG',
    fest_id INT,
    FOREIGN KEY (fest_id) REFERENCES Fest(fest_id)
);

CREATE TABLE Member (
	member_id INT PRIMARY KEY,
    mem_name VARCHAR(100) NOT NULL,
    age INT,
    dob DATE,
    team_id INT,
    head_id INT,
    FOREIGN KEY (team_id) REFERENCES Team(team_id),
    FOREIGN KEY (head_id) REFERENCES Member(member_id)
);

CREATE TABLE Participant(
	srn VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    gender ENUM('M', 'F', 'O'),
    department VARCHAR(10),
    semester INT
);

CREATE TABLE Event (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100) NOT NULL,
    building VARCHAR(50) NOT NULL,
    floor VARCHAR(20) NOT NULL,
    room_no VARCHAR(20) NOT NULL,
    price DECIMAL(8,2) CHECK (price <= 1500)
);

CREATE TABLE Event_conduction(
	event_id INT,
    date_of_conduction DATE NOT NULL,
    PRIMARY KEY (event_id, date_of_conduction),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

CREATE TABLE Visitor(
	name VARCHAR(100) PRIMARY KEY,
    gender ENUM ('M', 'F', 'O'),
    age INT,
    participant_srn VARCHAR(20),
    FOREIGN KEY (participant_srn) REFERENCES Participant(srn)
);

CREATE TABLE Registration(
	event_id INT PRIMARY KEY,
	reg_no INT,
    srn VARCHAR(20),
    FOREIGN KEY (srn) REFERENCES Participant(srn),
    FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

CREATE TABLE Stall(
	stall_id INT PRIMARY KEY,
    name VARCHAR(100),
    fest_id INT,
    FOREIGN KEY (fest_id) REFERENCES Fest(fest_id)
);

CREATE TABLE Item(
	name VARCHAR(100) PRIMARY KEY,
    type ENUM('VEG', 'NONVEG')
);

CREATE TABLE Stall_items(
	stall_id INT,
    item_name VARCHAR(100),
    PRIMARY KEY (stall_id, item_name),
    FOREIGN KEY (stall_id) REFERENCES Stall(stall_id),
    FOREIGN KEY (item_name) REFERENCES Item(name)
);

CREATE TABLE Purchased(
	srn VARCHAR(20),
    stall_id INT,
    item_name VARCHAR(20),
    time_stamp TIMESTAMP,
    quantity INT,
    PRIMARY KEY(srn, stall_id, item_name, time_stamp),
    FOREIGN KEY (srn) REFERENCES Participant(srn),
    FOREIGN KEY (stall_id) REFERENCES Stall(stall_id),
    FOREIGN KEY (item_name) REFERENCES Item(name)
);

