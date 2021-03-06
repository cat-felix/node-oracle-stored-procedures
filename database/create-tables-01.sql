﻿DROP TABLE T_GOODS CASCADE CONSTRAINTS PURGE;
DROP TABLE T_DEPARTMENTS CASCADE CONSTRAINTS PURGE;

CREATE TABLE T_DEPARTMENTS
(
	DEP_ID           NUMBER NOT NULL,
	DEP_NAME         VARCHAR2(200) NOT NULL,
	DEP_DATETIME     DATE DEFAULT SYSDATE NOT NULL 
);

CREATE UNIQUE INDEX XPKT_DEPARTMENTS ON T_DEPARTMENTS	(DEP_ID ASC);

ALTER TABLE T_DEPARTMENTS
	ADD CONSTRAINT XPKT_DEPARTMENTS PRIMARY KEY (DEP_ID);


CREATE TABLE T_GOODS
(
	GOOD_ID           NUMBER NOT NULL,
	GOOD_NAME					VARCHAR2(200) NOT NULL,
	GOOD_DATETIME     DATE DEFAULT SYSDATE NOT NULL,
	DEP_ID          	NUMBER NOT NULL
);

CREATE UNIQUE INDEX XPKT_GOODS ON T_GOODS	(GOOD_ID ASC);

ALTER TABLE T_GOODS
	ADD CONSTRAINT XPKT_T_GOODS PRIMARY KEY (GOOD_ID);

ALTER TABLE T_GOODS
	ADD (CONSTRAINT R_DEP_ID FOREIGN KEY (DEP_ID) 
	REFERENCES T_DEPARTMENTS (DEP_ID) ON DELETE SET NULL);

/* Fill down Departments*/
INSERT INTO T_DEPARTMENTS (DEP_ID, DEP_NAME)
	VALUES (10, 'Bath');

INSERT INTO T_DEPARTMENTS (DEP_ID, DEP_NAME)
	VALUES (20, 'Electrical');

INSERT INTO T_DEPARTMENTS (DEP_ID, DEP_NAME)
	VALUES (30, 'Kitchen & Kitchenware');

/* Fill down Goods fo Bath's department */
INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (100, 'Bathtubes', 10);

INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (110, 'Showers & Shower Doors', 10);

INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (120, 'Bathroom Cabinets & Storage', 10);

/* Fill down Goods fo Electrical's department */
INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (200, 'Dimmers, Switches & Outlets', 20);

INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (210, 'Electrical Tools & Accessories', 20);

/* Fill down Goods fo Kitchen & Kitchenware's department */
INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (300, 'Kitchen Cabinets', 30);

INSERT INTO T_GOODS (GOOD_ID, GOOD_NAME, DEP_ID)
	VALUES (310, 'Kitchen Sinks', 30);

COMMIT;
/