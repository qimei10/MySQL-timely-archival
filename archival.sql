-- first turn the scheduler on, make sure to be on root user for SUPER privilege 
SET GLOBAL event_scheduler = on 

-- to create/ make own delimiter instead of using default ; delimiter
DELIMITER $$ 

CREATE PROCEDURE sample_procedure ()

BEGIN

-- this to name table dynamically based on current date
SET @sample_table_name = CONCAT('sample_', year(now()), '_', lpad(month(now()),2,0)); 
SELECT @sample_table_name

SET @create_sample_table = CONCAT('CREATE TABLE IF NOT EXISTS ', @sample_table_name, ' (
    id bignit not null,
    sample_column_a longtext,
    sample_column_b longblob,
    sample_column_c varchar(6),
    sample_column_d datetime
    ) ENGINE=InnoDB;'
);

PREPARE stmt FROM @create_sample_table;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @insert_into_sample_table = 
CONCAT('insert into ', @sample_table_name, ' SELECT * FROM another_table WHERE sample_column_a =\'ITS JUST A SAMPLE\' AND sample_column_d<\'', year(now()), '-', lpad(month(now())+1,2,0), '-01 00:00:00\';');

PREPARE stmt1 FROM @insert_into_sample_table;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @delete_from_another_table =
CONCAT('DELETE FROM another_table WHERE id IN \(SELECT id FROM ', @create_sample_table, '\) AND sample_column_a=\'ITS JUST A SAMPLE\' AND sample_column_d<\'', year(now()), '-', lpad(month(now())+1,2,0), '-01 00:00:00\' AND id>0;'

PREPARE stmt2 FROM @delete_from_another_table;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

END $$

-- delimiter $$ ends here and resume the default delimiter
DELIMITER ; 

-- scheduler created with interval
CREATE EVENT [IF NOT EXISTS] sample_event_scheduler
ON SCHEDULE EVERY 24 HOUR
DO 
CALL sample_procedure;
