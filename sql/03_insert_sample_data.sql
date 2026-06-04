USE academic_paper_db;
SET NAMES utf8mb4;

/*
  Expanded sample data for the Academic Paper Database Management System.

  Data policy:
  1. Paper titles, publication years, venues and author names are based on
     public bibliographic records such as DBLP and public paper pages.
  2. Email values are left NULL because public bibliographic records normally
     do not provide reliable current email addresses.
  3. Submission dates, review records and reviewer names are simulated for
     course demonstration. Real submission/review histories are usually not
     public.
  4. The author list records representative/main authors for the demo system;
     some large systems papers have more authors in the original publication.

  Reference examples used when preparing this dataset:
  - DBLP: https://dblp.org/
  - E. F. Codd, CACM 1970: https://dblp.org/rec/journals/cacm/Codd70.html
  - OSDI 2012 Spanner entry: https://dblp.org/db/conf/osdi/osdi2012
  - Google Spanner paper PDF: https://research.google.com/archive/spanner-osdi2012.pdf
  - Snowflake SIGMOD 2016 paper page:
    https://www.snowflake.com/resource/sigmod-2016-paper-snowflake-elastic-data-warehouse/
*/

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM review;
ALTER TABLE review AUTO_INCREMENT = 1;
DELETE FROM submission;
ALTER TABLE submission AUTO_INCREMENT = 1;
DELETE FROM citation;
DELETE FROM paper_keyword;
DELETE FROM paper_author;
DELETE FROM paper;
ALTER TABLE paper AUTO_INCREMENT = 1;
DELETE FROM keyword;
ALTER TABLE keyword AUTO_INCREMENT = 1;
DELETE FROM venue;
ALTER TABLE venue AUTO_INCREMENT = 1;
DELETE FROM author;
ALTER TABLE author AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Authors: real author names from public bibliographic metadata.
INSERT INTO author (author_id, name, institution, email, research_area) VALUES
(1, 'E. F. Codd', 'IBM Research', NULL, 'Relational database theory'),
(2, 'C. Mohan', 'IBM Research', NULL, 'Transaction processing and recovery'),
(3, 'Don Haderle', 'IBM Research', NULL, 'Database systems'),
(4, 'Bruce Lindsay', 'IBM Research', NULL, 'Database systems'),
(5, 'Hamid Pirahesh', 'IBM Research', NULL, 'Query processing'),
(6, 'Peter Schwarz', 'IBM Research', NULL, 'Database systems'),
(7, 'Hal Berenson', 'Microsoft', NULL, 'Transaction isolation'),
(8, 'Philip A. Bernstein', 'Microsoft Research', NULL, 'Transaction processing'),
(9, 'Jim Gray', 'Microsoft Research', NULL, 'Database systems'),
(10, 'Jim Melton', 'Oracle', NULL, 'SQL standards'),
(11, 'Elizabeth J. O''Neil', 'University of Massachusetts Boston', NULL, 'Database systems'),
(12, 'Patrick E. O''Neil', 'University of Massachusetts Boston', NULL, 'Database systems'),
(13, 'Sanjay Ghemawat', 'Google', NULL, 'Distributed systems'),
(14, 'Howard Gobioff', 'Google', NULL, 'Distributed file systems'),
(15, 'Shun-Tak Leung', 'Google', NULL, 'Distributed systems'),
(16, 'Jeffrey Dean', 'Google', NULL, 'Large-scale distributed systems'),
(17, 'Fay Chang', 'Google', NULL, 'Distributed storage'),
(18, 'Wilson C. Hsieh', 'Google', NULL, 'Distributed storage'),
(19, 'Deborah A. Wallach', 'Google', NULL, 'Distributed storage'),
(20, 'Michael Burrows', 'Google', NULL, 'Distributed systems'),
(21, 'Giuseppe DeCandia', 'Amazon', NULL, 'Distributed storage'),
(22, 'Deniz Hastorun', 'Amazon', NULL, 'Distributed storage'),
(23, 'Madan Jampani', 'Amazon', NULL, 'Distributed storage'),
(24, 'Avinash Lakshman', 'Amazon', NULL, 'Distributed storage'),
(25, 'Werner Vogels', 'Amazon', NULL, 'Distributed systems'),
(26, 'James C. Corbett', 'Google', NULL, 'Distributed databases'),
(27, 'Michael Epstein', 'Google', NULL, 'Distributed databases'),
(28, 'Andrew Fikes', 'Google', NULL, 'Distributed systems'),
(29, 'Christopher Frost', 'Google', NULL, 'Distributed databases'),
(30, 'J. J. Furman', 'Google', NULL, 'Distributed databases'),
(31, 'Jeff Shute', 'Google', NULL, 'Distributed SQL'),
(32, 'Radek Vingralek', 'Google', NULL, 'Distributed SQL'),
(33, 'Bart Samwel', 'Google', NULL, 'Distributed SQL'),
(34, 'Michael Stonebraker', 'MIT', NULL, 'Database architecture'),
(35, 'Daniel J. Abadi', 'University of Maryland', NULL, 'Column-oriented databases'),
(36, 'Samuel Madden', 'MIT', NULL, 'Database systems'),
(37, 'Stanley B. Zdonik', 'Brown University', NULL, 'Database systems'),
(38, 'Robert Kallman', 'Brown University', NULL, 'Main-memory OLTP'),
(39, 'Andrew Pavlo', 'Carnegie Mellon University', NULL, 'Database systems'),
(40, 'Evan P. C. Jones', 'MIT', NULL, 'Database systems'),
(41, 'Cristian Diaconu', 'Microsoft', NULL, 'In-memory OLTP'),
(42, 'Craig Freedman', 'Microsoft', NULL, 'Database engine'),
(43, 'Per-Ake Larson', 'Microsoft Research', NULL, 'Query processing'),
(44, 'Nitin Verma', 'Microsoft', NULL, 'Database engine'),
(45, 'Peter A. Boncz', 'CWI', NULL, 'Column stores'),
(46, 'Stavros Harizopoulos', 'HP Labs', NULL, 'Database systems'),
(47, 'Stratos Idreos', 'Harvard University', NULL, 'Data systems'),
(48, 'Benoit Dageville', 'Snowflake', NULL, 'Cloud data warehouse'),
(49, 'Thierry Cruanes', 'Snowflake', NULL, 'Cloud data warehouse'),
(50, 'Marcin Zukowski', 'Snowflake', NULL, 'Analytical database systems'),
(51, 'Alexander Thomson', 'Yale University', NULL, 'Distributed transactions'),
(52, 'Thaddeus Diamond', 'Yale University', NULL, 'Distributed transactions'),
(53, 'Shu-Chun Weng', 'Yale University', NULL, 'Distributed transactions'),
(54, 'Kun Ren', 'Yale University', NULL, 'Distributed transactions'),
(55, 'Philip Shao', 'Yale University', NULL, 'Distributed transactions'),
(56, 'Matei Zaharia', 'University of California, Berkeley', NULL, 'Cluster computing'),
(57, 'Mosharaf Chowdhury', 'University of California, Berkeley', NULL, 'Distributed systems'),
(58, 'Michael J. Franklin', 'University of California, Berkeley', NULL, 'Data management'),
(59, 'Scott Shenker', 'University of California, Berkeley', NULL, 'Computer networks'),
(60, 'Ion Stoica', 'University of California, Berkeley', NULL, 'Distributed systems'),
(61, 'Grzegorz Malewicz', 'Google', NULL, 'Graph processing'),
(62, 'Matthew H. Austern', 'Google', NULL, 'Graph processing'),
(63, 'Aart J. C. Bik', 'Google', NULL, 'Graph processing'),
(64, 'James C. Dehnert', 'Google', NULL, 'Graph processing'),
(65, 'Sergey Brin', 'Stanford University', NULL, 'Web search'),
(66, 'Lawrence Page', 'Stanford University', NULL, 'Web search'),
(67, 'Jon Gjengset', 'MIT', NULL, 'Dataflow systems'),
(68, 'Malte Schwarzkopf', 'MIT', NULL, 'Distributed systems'),
(69, 'Jonathan Behrens', 'MIT', NULL, 'Systems research'),
(70, 'Eddie Kohler', 'Harvard University', NULL, 'Systems research'),
(71, 'M. Frans Kaashoek', 'MIT', NULL, 'Operating systems'),
(72, 'Robert Morris', 'MIT', NULL, 'Operating systems'),
(73, 'Jason Baker', 'Google', NULL, 'Distributed storage'),
(74, 'Chris Bond', 'Google', NULL, 'Distributed storage'),
(75, 'Andrey Khorlin', 'Google', NULL, 'Distributed storage'),
(76, 'James Larson', 'Google', NULL, 'Distributed storage');

-- 2. Venues: real journals, conferences and workshops.
INSERT INTO venue (venue_id, venue_name, venue_type, publisher, paper_count) VALUES
(1, 'Communications of the ACM', 'Journal', 'ACM', 0),
(2, 'ACM Transactions on Database Systems', 'Journal', 'ACM', 0),
(3, 'ACM SIGMOD Conference', 'Conference', 'ACM', 0),
(4, 'ACM Symposium on Operating Systems Principles', 'Conference', 'ACM', 0),
(5, 'USENIX Symposium on Operating Systems Design and Implementation', 'Conference', 'USENIX Association', 0),
(6, 'Conference on Innovative Data Systems Research', 'Conference', 'CIDR', 0),
(7, 'Proceedings of the VLDB Endowment', 'Journal', 'VLDB Endowment', 0),
(8, 'VLDB Conference', 'Conference', 'VLDB Endowment', 0),
(9, 'Foundations and Trends in Databases', 'Journal', 'now Publishers', 0),
(10, 'USENIX Workshop on Hot Topics in Cloud Computing', 'Conference', 'USENIX Association', 0),
(11, 'Computer Networks', 'Journal', 'Elsevier', 0);

-- 3. Papers: real public paper metadata, with concise paraphrased abstracts.
INSERT INTO paper (paper_id, title, abstract, publish_year, status, venue_id, created_at) VALUES
(1, 'A Relational Model of Data for Large Shared Data Banks', 'Introduces the relational model and separates logical data representation from physical storage details.', 1970, 'Accepted', 1, '1970-06-01 09:00:00'),
(2, 'ARIES: A Transaction Recovery Method Supporting Fine-Granularity Locking and Partial Rollbacks Using Write-Ahead Logging', 'Presents ARIES, a recovery algorithm based on write-ahead logging, repeating history during redo and selective undo.', 1992, 'Accepted', 2, '1992-03-01 09:00:00'),
(3, 'A Critique of ANSI SQL Isolation Levels', 'Analyzes SQL isolation level definitions and explains anomalies that can still occur under several isolation settings.', 1995, 'Accepted', 3, '1995-05-01 09:00:00'),
(4, 'The Google File System', 'Describes a scalable distributed file system designed for large files, commodity machines and fault tolerance.', 2003, 'Accepted', 4, '2003-10-01 09:00:00'),
(5, 'MapReduce: Simplified Data Processing on Large Clusters', 'Introduces a programming model and runtime for large-scale data processing across clusters.', 2004, 'Accepted', 5, '2004-12-01 09:00:00'),
(6, 'Bigtable: A Distributed Storage System for Structured Data', 'Describes a distributed storage system for managing structured data at large scale.', 2006, 'Accepted', 5, '2006-11-01 09:00:00'),
(7, 'Dynamo: Amazon''s Highly Available Key-value Store', 'Describes a highly available key-value storage system emphasizing scalability, availability and eventual consistency.', 2007, 'Accepted', 4, '2007-10-01 09:00:00'),
(8, 'Megastore: Providing Scalable, Highly Available Storage for Interactive Services', 'Presents a storage system that combines scalable partitioning with synchronous replication for interactive services.', 2011, 'Accepted', 6, '2011-01-01 09:00:00'),
(9, 'Spanner: Google''s Globally-Distributed Database', 'Describes a globally distributed database providing replication, transactions and externally consistent reads and writes.', 2012, 'Accepted', 5, '2012-10-01 09:00:00'),
(10, 'F1: A Distributed SQL Database That Scales', 'Presents a distributed SQL database built for Google advertising workloads on top of Spanner.', 2013, 'Accepted', 7, '2013-08-01 09:00:00'),
(11, 'C-Store: A Column-oriented DBMS', 'Proposes a column-oriented database architecture optimized for read-heavy analytical workloads.', 2005, 'Accepted', 8, '2005-08-01 09:00:00'),
(12, 'H-Store: A High-Performance, Distributed Main Memory Transaction Processing System', 'Describes a distributed main-memory OLTP system designed around high-throughput transaction processing.', 2008, 'Accepted', 7, '2008-08-01 09:00:00'),
(13, 'Hekaton: SQL Server''s Memory-Optimized OLTP Engine', 'Introduces the memory-optimized OLTP engine in Microsoft SQL Server and its concurrency control approach.', 2013, 'Accepted', 3, '2013-06-01 09:00:00'),
(14, 'The Design and Implementation of Modern Column-Oriented Database Systems', 'Surveys implementation techniques used by modern column-oriented database management systems.', 2013, 'Accepted', 9, '2013-12-01 09:00:00'),
(15, 'The Snowflake Elastic Data Warehouse', 'Presents Snowflake, a cloud data warehouse architecture that separates storage from elastic compute.', 2016, 'Accepted', 3, '2016-06-01 09:00:00'),
(16, 'Calvin: Fast Distributed Transactions for Partitioned Database Systems', 'Describes a deterministic transaction scheduling approach for distributed partitioned database systems.', 2012, 'Accepted', 3, '2012-05-01 09:00:00'),
(17, 'Spark: Cluster Computing with Working Sets', 'Introduces Spark, a cluster computing framework designed to efficiently reuse working sets across parallel operations.', 2010, 'Accepted', 10, '2010-06-01 09:00:00'),
(18, 'Pregel: A System for Large-Scale Graph Processing', 'Presents a vertex-centric system for large-scale graph processing inspired by bulk synchronous parallel computation.', 2010, 'Accepted', 3, '2010-06-01 09:00:00'),
(19, 'The Anatomy of a Large-Scale Hypertextual Web Search Engine', 'Describes the architecture and ranking ideas behind the early Google search engine.', 1998, 'Accepted', 11, '1998-04-01 09:00:00'),
(20, 'Noria: Dynamic, Partially-Stateful Data-Flow for High-Performance Web Applications', 'Presents a data-flow approach for maintaining partially materialized state in high-performance web applications.', 2018, 'Accepted', 5, '2018-10-01 09:00:00');

-- Keep venue.paper_count correct even if triggers were created before this script.
UPDATE venue v
LEFT JOIN (
    SELECT venue_id, COUNT(*) AS paper_total
    FROM paper
    GROUP BY venue_id
) pc ON v.venue_id = pc.venue_id
SET v.paper_count = COALESCE(pc.paper_total, 0);

-- 4. Keywords.
INSERT INTO keyword (keyword_id, keyword_name) VALUES
(1, 'Relational Model'),
(2, 'Database Systems'),
(3, 'Transaction Processing'),
(4, 'Recovery'),
(5, 'Write-Ahead Logging'),
(6, 'Isolation Level'),
(7, 'Distributed Storage'),
(8, 'File System'),
(9, 'MapReduce'),
(10, 'Big Data'),
(11, 'Structured Data'),
(12, 'Key-Value Store'),
(13, 'High Availability'),
(14, 'Distributed SQL'),
(15, 'Replication'),
(16, 'Column Store'),
(17, 'Data Warehouse'),
(18, 'In-Memory Database'),
(19, 'OLTP'),
(20, 'Graph Processing'),
(21, 'Search Engine'),
(22, 'Dataflow'),
(23, 'Web Applications'),
(24, 'Query Processing'),
(25, 'Consistency'),
(26, 'Fault Tolerance'),
(27, 'ACID'),
(28, 'Cloud Computing'),
(29, 'Main-Memory Database'),
(30, 'Concurrency Control'),
(31, 'Scalability'),
(32, 'NoSQL'),
(33, 'Analytics'),
(34, 'Stream Processing'),
(35, 'Indexing'),
(36, 'Paxos'),
(37, 'Wide-Area Replication'),
(38, 'System Architecture'),
(39, 'SQL Engine'),
(40, 'Research Survey');

-- 5. Paper-author relationships.
INSERT INTO paper_author (paper_id, author_id, author_order, is_corresponding) VALUES
(1, 1, 1, TRUE),
(2, 2, 1, TRUE), (2, 3, 2, FALSE), (2, 4, 3, FALSE), (2, 5, 4, FALSE), (2, 6, 5, FALSE),
(3, 7, 1, TRUE), (3, 8, 2, FALSE), (3, 9, 3, FALSE), (3, 10, 4, FALSE), (3, 11, 5, FALSE), (3, 12, 6, FALSE),
(4, 13, 1, TRUE), (4, 14, 2, FALSE), (4, 15, 3, FALSE),
(5, 16, 1, TRUE), (5, 13, 2, FALSE),
(6, 17, 1, TRUE), (6, 16, 2, FALSE), (6, 13, 3, FALSE), (6, 18, 4, FALSE), (6, 19, 5, FALSE), (6, 20, 6, FALSE),
(7, 21, 1, TRUE), (7, 22, 2, FALSE), (7, 23, 3, FALSE), (7, 24, 4, FALSE), (7, 25, 5, FALSE),
(8, 73, 1, TRUE), (8, 74, 2, FALSE), (8, 26, 3, FALSE), (8, 30, 4, FALSE), (8, 75, 5, FALSE), (8, 76, 6, FALSE),
(9, 26, 1, TRUE), (9, 16, 2, FALSE), (9, 27, 3, FALSE), (9, 28, 4, FALSE), (9, 29, 5, FALSE), (9, 30, 6, FALSE), (9, 13, 7, FALSE), (9, 18, 8, FALSE),
(10, 31, 1, TRUE), (10, 32, 2, FALSE), (10, 33, 3, FALSE),
(11, 34, 1, TRUE), (11, 35, 2, FALSE), (11, 36, 3, FALSE), (11, 37, 4, FALSE),
(12, 38, 1, TRUE), (12, 39, 2, FALSE), (12, 40, 3, FALSE), (12, 36, 4, FALSE), (12, 34, 5, FALSE), (12, 35, 6, FALSE),
(13, 41, 1, TRUE), (13, 42, 2, FALSE), (13, 43, 3, FALSE), (13, 44, 4, FALSE),
(14, 35, 1, TRUE), (14, 45, 2, FALSE), (14, 46, 3, FALSE), (14, 47, 4, FALSE), (14, 36, 5, FALSE),
(15, 48, 1, TRUE), (15, 49, 2, FALSE), (15, 50, 3, FALSE),
(16, 51, 1, TRUE), (16, 52, 2, FALSE), (16, 53, 3, FALSE), (16, 54, 4, FALSE), (16, 55, 5, FALSE), (16, 35, 6, FALSE),
(17, 56, 1, TRUE), (17, 57, 2, FALSE), (17, 58, 3, FALSE), (17, 59, 4, FALSE), (17, 60, 5, FALSE),
(18, 61, 1, TRUE), (18, 62, 2, FALSE), (18, 63, 3, FALSE), (18, 64, 4, FALSE),
(19, 65, 1, TRUE), (19, 66, 2, FALSE),
(20, 67, 1, TRUE), (20, 68, 2, FALSE), (20, 69, 3, FALSE), (20, 70, 4, FALSE), (20, 71, 5, FALSE), (20, 72, 6, FALSE);

-- 6. Paper-keyword relationships.
INSERT INTO paper_keyword (paper_id, keyword_id) VALUES
(1, 1), (1, 2), (1, 24),
(2, 3), (2, 4), (2, 5), (2, 27),
(3, 6), (3, 27), (3, 30),
(4, 7), (4, 8), (4, 26),
(5, 9), (5, 10), (5, 31),
(6, 7), (6, 11), (6, 31), (6, 38),
(7, 12), (7, 13), (7, 15), (7, 25), (7, 32),
(8, 14), (8, 15), (8, 25), (8, 36), (8, 37),
(9, 14), (9, 25), (9, 31), (9, 36), (9, 37),
(10, 14), (10, 25), (10, 31), (10, 39),
(11, 16), (11, 24), (11, 33),
(12, 18), (12, 19), (12, 29), (12, 31),
(13, 18), (13, 19), (13, 29), (13, 30),
(14, 16), (14, 24), (14, 33), (14, 40),
(15, 17), (15, 28), (15, 31), (15, 33),
(16, 3), (16, 14), (16, 25), (16, 30),
(17, 22), (17, 28), (17, 31), (17, 34),
(18, 10), (18, 20), (18, 31),
(19, 21), (19, 31), (19, 38),
(20, 22), (20, 23), (20, 24), (20, 34);

-- 7. Submission records: simulated for demo because real submission histories are not public.
INSERT INTO submission (submission_id, paper_id, venue_id, submit_date, result) VALUES
(1, 1, 1, '1969-11-01', 'Accepted'),
(2, 2, 2, '1991-06-15', 'Accepted'),
(3, 3, 3, '1995-01-10', 'Accepted'),
(4, 4, 4, '2003-03-20', 'Accepted'),
(5, 5, 5, '2004-04-12', 'Accepted'),
(6, 6, 5, '2006-03-15', 'Accepted'),
(7, 7, 4, '2007-04-10', 'Accepted'),
(8, 8, 6, '2010-10-01', 'Accepted'),
(9, 9, 5, '2012-03-15', 'Accepted'),
(10, 10, 7, '2013-02-01', 'Accepted'),
(11, 11, 8, '2005-02-20', 'Accepted'),
(12, 12, 7, '2008-05-10', 'Accepted'),
(13, 13, 3, '2013-01-08', 'Accepted'),
(14, 14, 9, '2012-08-01', 'Accepted'),
(15, 15, 3, '2016-01-12', 'Accepted'),
(16, 16, 3, '2011-11-01', 'Accepted'),
(17, 17, 10, '2010-04-21', 'Accepted'),
(18, 18, 3, '2010-01-15', 'Accepted'),
(19, 19, 11, '1998-02-10', 'Accepted'),
(20, 20, 5, '2018-03-12', 'Accepted'),
(21, 16, 7, '2011-05-15', 'Rejected'),
(22, 20, 6, '2017-10-18', 'Rejected'),
(23, 10, 3, '2012-08-20', 'Rejected'),
(24, 15, 7, '2015-09-20', 'Rejected');

-- 8. Review records: simulated reviewer names and comments for demonstration.
INSERT INTO review (review_id, submission_id, reviewer_name, score, comment, review_date) VALUES
(1, 1, 'Reviewer A', 5, 'Foundational database model with clear long-term impact.', '1970-01-15'),
(2, 1, 'Reviewer B', 5, 'The abstraction is concise and influential.', '1970-01-18'),
(3, 2, 'Reviewer C', 5, 'Strong recovery design and detailed transaction discussion.', '1991-08-01'),
(4, 2, 'Reviewer D', 4, 'The logging protocol is convincing and practical.', '1991-08-06'),
(5, 3, 'Reviewer E', 4, 'Useful critique of isolation definitions and anomalies.', '1995-02-14'),
(6, 3, 'Reviewer F', 4, 'The examples are valuable for database implementation.', '1995-02-16'),
(7, 4, 'Reviewer G', 5, 'Compelling large-scale storage architecture.', '2003-05-10'),
(8, 4, 'Reviewer H', 4, 'The design choices match the target workload well.', '2003-05-13'),
(9, 5, 'Reviewer I', 5, 'Simple programming model with strong practical impact.', '2004-06-01'),
(10, 5, 'Reviewer J', 4, 'The evaluation shows convincing scalability.', '2004-06-04'),
(11, 6, 'Reviewer K', 5, 'Important structured storage system for large-scale services.', '2006-05-05'),
(12, 6, 'Reviewer L', 4, 'The system design is clear and well motivated.', '2006-05-08'),
(13, 7, 'Reviewer M', 5, 'Strong contribution to highly available key-value storage.', '2007-06-02'),
(14, 7, 'Reviewer N', 4, 'The availability and consistency tradeoffs are well explained.', '2007-06-06'),
(15, 8, 'Reviewer O', 4, 'Good discussion of replication and interactive service needs.', '2010-11-20'),
(16, 8, 'Reviewer P', 4, 'The storage model is practical for large online services.', '2010-11-24'),
(17, 9, 'Reviewer Q', 5, 'Important global transaction and replication system.', '2012-05-15'),
(18, 9, 'Reviewer R', 5, 'The external consistency discussion is especially strong.', '2012-05-18'),
(19, 10, 'Reviewer S', 5, 'Clear demonstration that SQL can scale on distributed storage.', '2013-03-18'),
(20, 10, 'Reviewer T', 4, 'The production lessons are useful for database engineers.', '2013-03-21'),
(21, 11, 'Reviewer U', 4, 'Strong architectural argument for column-oriented storage.', '2005-04-02'),
(22, 11, 'Reviewer V', 4, 'The design is relevant to analytical workloads.', '2005-04-06'),
(23, 12, 'Reviewer W', 4, 'Interesting main-memory transaction processing architecture.', '2008-06-18'),
(24, 12, 'Reviewer X', 4, 'The system assumptions are clear and testable.', '2008-06-21'),
(25, 13, 'Reviewer Y', 5, 'Important production database engine contribution.', '2013-02-20'),
(26, 13, 'Reviewer Z', 4, 'The concurrency design is practical and well explained.', '2013-02-24'),
(27, 14, 'Reviewer AA', 5, 'Comprehensive survey of column-store implementation techniques.', '2012-10-01'),
(28, 14, 'Reviewer AB', 4, 'Useful synthesis for database system designers.', '2012-10-05'),
(29, 15, 'Reviewer AC', 5, 'Strong cloud data warehouse architecture paper.', '2016-03-10'),
(30, 15, 'Reviewer AD', 4, 'The separation of storage and compute is well motivated.', '2016-03-15'),
(31, 16, 'Reviewer AE', 5, 'Deterministic transaction scheduling is a clear contribution.', '2012-01-20'),
(32, 16, 'Reviewer AF', 4, 'The distributed transaction design is carefully evaluated.', '2012-01-23'),
(33, 17, 'Reviewer AG', 4, 'Good cluster computing model for iterative workloads.', '2010-05-10'),
(34, 17, 'Reviewer AH', 4, 'Working-set reuse is an important practical improvement.', '2010-05-13'),
(35, 18, 'Reviewer AI', 5, 'Useful vertex-centric model for graph processing at scale.', '2010-03-10'),
(36, 18, 'Reviewer AJ', 4, 'The abstraction is simple and expressive.', '2010-03-14'),
(37, 19, 'Reviewer AK', 5, 'Important system paper for large-scale web search.', '1998-03-01'),
(38, 19, 'Reviewer AL', 4, 'The ranking and crawling architecture is clearly described.', '1998-03-04'),
(39, 20, 'Reviewer AM', 4, 'Strong systems contribution for data-flow web applications.', '2018-05-10'),
(40, 20, 'Reviewer AN', 4, 'The partially materialized approach is promising.', '2018-05-13'),
(41, 21, 'Reviewer AO', 2, 'The deterministic scheduling idea needs clearer evaluation in this version.', '2011-06-10'),
(42, 21, 'Reviewer AP', 3, 'Promising work but not ready for this venue.', '2011-06-14'),
(43, 22, 'Reviewer AQ', 3, 'Interesting work; more comparison with existing systems is needed.', '2017-11-15'),
(44, 23, 'Reviewer AR', 2, 'The SQL scalability story needs stronger production evidence.', '2012-09-15'),
(45, 24, 'Reviewer AS', 3, 'The architecture is promising but the evaluation should be expanded.', '2015-10-18');

-- 9. Citation relationships: sample related-work links for the self-reference table.
INSERT INTO citation (citing_paper_id, cited_paper_id) VALUES
(2, 1),
(3, 1),
(3, 2),
(4, 1),
(5, 4),
(6, 4),
(6, 5),
(7, 4),
(8, 6),
(8, 7),
(9, 4),
(9, 6),
(9, 8),
(10, 6),
(10, 9),
(11, 1),
(12, 1),
(12, 11),
(13, 2),
(13, 3),
(13, 12),
(14, 11),
(15, 11),
(15, 14),
(16, 2),
(16, 3),
(16, 9),
(17, 5),
(17, 4),
(18, 5),
(18, 4),
(20, 10),
(20, 17);

-- Quick checks after import:
-- SELECT COUNT(*) AS author_count FROM author;
-- SELECT COUNT(*) AS paper_count FROM paper;
-- SELECT COUNT(*) AS submission_count FROM submission;
-- SELECT COUNT(*) AS review_count FROM review;
-- SELECT COUNT(*) AS citation_count FROM citation;
-- SELECT venue_id, venue_name, paper_count FROM venue ORDER BY venue_id;
