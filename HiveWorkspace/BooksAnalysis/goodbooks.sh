##booksanalysis




hive  -e"

SHOW DATABASES;



USE BOOKS;

SET hive.enforce.bucketing=true;
SET hive.mapred.mode=true;
SET hive.auto.convert.join = false;

DROP TABLE IF EXISTS BOOKS;
DROP TABLE IF EXISTS RATINGS;

CREATE TABLE RATINGS (BOOK_ID INT, USER_ID INT, RATING INT) CLUSTERED BY (BOOK_ID) INTO 5 BUCKETS;

CREATE TABLE BOOKS ( BOOK_ID INT, TITLE STRING,GOODREADS_BOOK_ID INT ,GOODREADS_WORK_ID INT) 
CLUSTERED BY (BOOK_ID) INTO 5 BUCKETS
ROW FORMAT SERDE'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH '/home/nir0303/Downloads/books2.csv' into TABLE BOOKS;
LOAD DATA LOCAL INPATH '/home/nir0303/Downloads/ratings2.csv' into TABLE RATINGS;


CREATE TABLE BOOKS2 AS
SELECT CAST(BOOK_ID AS INT) BOOKS_ID,TITLE, CAST(GOODREADS_BOOK_ID AS INT) GOODREADS_BOOKS_ID,CAST(GOODREADS_WORK_ID AS INT) GOODREADS_WORK_ID FROM BOOKS;


DROP TABLE BOOKS;
ALTER TABLE BOOKS2 RENAME TO BOOKS;



DROP VIEW  IF EXISTS  BOOKS_ANA_INNERJOIN;
CREATE VIEW BOOKS_ANA_INNERJOIN AS
SELECT BOOKS.*, RATINGS.* FROM BOOKS JOIN RATINGS ON BOOKS.BOOKS_ID = RATINGS.BOOK_ID ;

DROP VIEW  IF EXISTS BOOKS_ANA_SEMIJOIN;
CREATE VIEW BOOKS_ANA_SEMIJOIN AS
SELECT BOOKS.* FROM BOOKS LEFT SEMI JOIN RATINGS ON BOOKS.BOOKS_ID = RATINGS.BOOK_ID;

DELETE FILES /home/nir0303/working/BigDataWorkspace/HiveWorkspace/BooksAnalysis/;
ADD FILE /home/nir0303/working/BigDataWorkspace/HiveWorkspace/BooksAnalysis/reduce.py;
ADD FILE /home/nir0303/working/BigDataWorkspace/HiveWorkspace/BooksAnalysis/mapper.py;


FROM(
FROM RATINGS 
MAP BOOK_ID,USER_ID,RATING USING 'mapper.py' as book_id,rating
) map_output
Reduce book_id,rating using 'reduce.py' 
as MAX_RATING;

DROP TABLE IF EXISTS GOODBOOKS;

CREATE TABLE GOODBOOKS AS
SELECT BOOK_ID,GOODREADS_BOOKS_ID,TITLE,GOODREADS_WORK_ID,RATING FROM BOOKS_ANA_INNERJOIN
WHERE RATING >=4;

SELECT COUNT(0) FROM GOODBOOKS;

SELECT * FROM GOODBOOKS ORDER BY RATING DESC LIMIT 20;

dfs -ls /user/hive/warehouse/
" > output.txt