
INSERT INTO `FOO` VALUES (1,'sajal',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),26),(2,'sj',STR_TO_DATE('11-08-2016', '%d-%m-%Y'),27),(3,'sajalj',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),27);

--//@UNDO
DROP TABLE FOO;
