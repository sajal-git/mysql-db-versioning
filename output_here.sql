
-- START CHANGE SCRIPT #102: 102_alter-foo-table.sql

ALTER TABLE FOO ADD (
FOO_DATE DATE NULL);




INSERT INTO CHANGELOG (change_number, complete_dt, applied_by, description)
 VALUES (102, CURRENT_TIMESTAMP, USER(), '102_alter-foo-table.sql');

COMMIT;

-- END CHANGE SCRIPT #102: 102_alter-foo-table.sql


-- START CHANGE SCRIPT #103: 103_alter-foo-add-column.sql

ALTER TABLE FOO ADD (
FOO_AGE INTEGER NULL);



INSERT INTO CHANGELOG (change_number, complete_dt, applied_by, description)
 VALUES (103, CURRENT_TIMESTAMP, USER(), '103_alter-foo-add-column.sql');

COMMIT;

-- END CHANGE SCRIPT #103: 103_alter-foo-add-column.sql


-- START CHANGE SCRIPT #104: 104_update-foo-table.sql


INSERT INTO `FOO` VALUES (1,'sajal',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),26),(2,'sj',STR_TO_DATE('11-08-2016', '%d-%m-%Y'),27),(3,'sajalj',STR_TO_DATE('10-08-2016', '%d-%m-%Y'),27);



INSERT INTO CHANGELOG (change_number, complete_dt, applied_by, description)
 VALUES (104, CURRENT_TIMESTAMP, USER(), '104_update-foo-table.sql');

COMMIT;

-- END CHANGE SCRIPT #104: 104_update-foo-table.sql

