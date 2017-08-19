##booksanalysis

cd $HOME


hive -e "

SHOW DATABASES;

USE BOOKS;

SET hive.enforce.bucketing=true;

DROP TABLE IF EXISTS BOOKS;
DROP TABLE IF EXISTS RATINGS;

CREATE TABLE RATINGS (BOOK_ID INT, GOODREADS_BOOK_ID INT, RATING INT) CLUSTERED BY (BOOK_ID) INTO 5 BUCKETS;

CREATE TABLE BOOKS ( BOOK_ID INT, TITLE STRING,GOODREADS_BOOK_ID INT ,GOODREADS_WORK_ID INT) 
 CLUSTERED BY (BOOK_ID) INTO 5 BUCKETS
 ROW FORMAT SERDE'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS TEXTFILE;


LOAD DATA LOCAL INPATH '/home/nir0303/Downloads/books2.csv' into TABLE BOOKS;

LOAD DATA LOCAL INPATH '/home/nir0303/Downloads/books2.csv' into TABLE RATINGS;


CREATE TABLE BOOKS2 AS
SELECT cast(BOOK_ID as INT) BOOK_ID,TITLE, cast(GOODREADS_BOOK_ID as INT) GOODREADS_BOOK_ID,cast(GOODREADS_WORK_ID as INT) GOODREADS_WORK_ID FROM BOOKS;

DROP TABLE BOOKS;

ALTER TABLE BOOKS2 RENAME TO BOOKS;



"