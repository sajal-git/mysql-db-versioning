ALTER TABLE FOO ADD (
FOO_DATE DATE NULL);


--//@UNDO
ALTER TABLE FOO DROP COLUMN FOO_DATE;

