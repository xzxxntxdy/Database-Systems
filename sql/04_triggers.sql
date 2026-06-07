USE academic_paper_db;

DROP TRIGGER IF EXISTS trg_check_paper_year;
DROP TRIGGER IF EXISTS trg_check_paper_status;
DROP TRIGGER IF EXISTS trg_check_paper_venue_insert;
DROP TRIGGER IF EXISTS trg_check_paper_venue_update;
DROP TRIGGER IF EXISTS trg_update_venue_paper_count;
DROP TRIGGER IF EXISTS trg_decrease_venue_paper_count;
DROP TRIGGER IF EXISTS trg_update_venue_count_on_paper_move;
DROP TRIGGER IF EXISTS trg_no_duplicate_under_review_insert;
DROP TRIGGER IF EXISTS trg_no_duplicate_under_review_update;
DROP TRIGGER IF EXISTS trg_no_self_citation_insert;
DROP TRIGGER IF EXISTS trg_no_self_citation_update;

DELIMITER //

-- Before inserting a paper, validate publish_year.
CREATE TRIGGER trg_check_paper_year
BEFORE INSERT ON paper
FOR EACH ROW
BEGIN
    IF NEW.publish_year IS NOT NULL
       AND (NEW.publish_year < 1901 OR NEW.publish_year > YEAR(CURDATE()) + 1) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid publish year: must be between 1901 and current year plus 1';
    END IF;
END //

-- Before inserting a paper, validate paper.status.
CREATE TRIGGER trg_check_paper_status
BEFORE INSERT ON paper
FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('Draft', 'Submitted', 'Accepted', 'Rejected') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid paper status';
    END IF;
END //

-- Validate the relationship between paper.status and paper.venue_id on insert.
CREATE TRIGGER trg_check_paper_venue_insert
BEFORE INSERT ON paper
FOR EACH ROW
BEGIN
    IF NEW.status = 'Draft' AND NEW.venue_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Draft paper should not have a venue';
    END IF;

    IF NEW.status = 'Accepted' AND NEW.venue_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Accepted paper must have a venue';
    END IF;
END //

-- Validate the relationship between paper.status and paper.venue_id on update.
CREATE TRIGGER trg_check_paper_venue_update
BEFORE UPDATE ON paper
FOR EACH ROW
BEGIN
    IF NEW.status = 'Draft' AND NEW.venue_id IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Draft paper should not have a venue';
    END IF;

    IF NEW.status = 'Accepted' AND NEW.venue_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Accepted paper must have a venue';
    END IF;
END //

-- After inserting a paper, maintain venue.paper_count.
CREATE TRIGGER trg_update_venue_paper_count
AFTER INSERT ON paper
FOR EACH ROW
BEGIN
    IF NEW.venue_id IS NOT NULL THEN
        UPDATE venue
        SET paper_count = paper_count + 1
        WHERE venue_id = NEW.venue_id;
    END IF;
END //

-- After deleting a paper, maintain venue.paper_count.
CREATE TRIGGER trg_decrease_venue_paper_count
AFTER DELETE ON paper
FOR EACH ROW
BEGIN
    IF OLD.venue_id IS NOT NULL THEN
        UPDATE venue
        SET paper_count = GREATEST(paper_count - 1, 0)
        WHERE venue_id = OLD.venue_id;
    END IF;
END //

-- After moving a paper to another venue, maintain both venue counters.
CREATE TRIGGER trg_update_venue_count_on_paper_move
AFTER UPDATE ON paper
FOR EACH ROW
BEGIN
    IF NOT (OLD.venue_id <=> NEW.venue_id) THEN
        IF OLD.venue_id IS NOT NULL THEN
            UPDATE venue
            SET paper_count = GREATEST(paper_count - 1, 0)
            WHERE venue_id = OLD.venue_id;
        END IF;

        IF NEW.venue_id IS NOT NULL THEN
            UPDATE venue
            SET paper_count = paper_count + 1
            WHERE venue_id = NEW.venue_id;
        END IF;
    END IF;
END //

-- Prevent one paper from having two active Under Review submissions.
CREATE TRIGGER trg_no_duplicate_under_review_insert
BEFORE INSERT ON submission
FOR EACH ROW
BEGIN
    DECLARE v_under_review_count INT DEFAULT 0;
    DECLARE v_paper_status VARCHAR(10) DEFAULT NULL;

    IF NEW.result = 'Under Review' THEN
        SELECT status INTO v_paper_status
        FROM paper
        WHERE paper_id = NEW.paper_id;

        IF v_paper_status = 'Accepted' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Accepted paper cannot create a new Under Review submission';
        END IF;

        SELECT COUNT(*) INTO v_under_review_count
        FROM submission
        WHERE paper_id = NEW.paper_id
          AND result = 'Under Review';

        IF v_under_review_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A paper cannot have multiple Under Review submissions at the same time';
        END IF;
    END IF;
END //

-- Prevent updates from creating two active Under Review submissions.
CREATE TRIGGER trg_no_duplicate_under_review_update
BEFORE UPDATE ON submission
FOR EACH ROW
BEGIN
    DECLARE v_under_review_count INT DEFAULT 0;
    DECLARE v_paper_status VARCHAR(10) DEFAULT NULL;

    IF NEW.result = 'Under Review' THEN
        SELECT status INTO v_paper_status
        FROM paper
        WHERE paper_id = NEW.paper_id;

        IF v_paper_status = 'Accepted' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Accepted paper cannot be changed back to Under Review';
        END IF;

        SELECT COUNT(*) INTO v_under_review_count
        FROM submission
        WHERE paper_id = NEW.paper_id
          AND submission_id <> OLD.submission_id
          AND result = 'Under Review';

        IF v_under_review_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A paper cannot have multiple Under Review submissions at the same time';
        END IF;
    END IF;
END //

-- A paper cannot cite itself.
CREATE TRIGGER trg_no_self_citation_insert
BEFORE INSERT ON citation
FOR EACH ROW
BEGIN
    IF NEW.citing_paper_id = NEW.cited_paper_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A paper cannot cite itself';
    END IF;
END //

-- A citation cannot be changed into a self-citation.
CREATE TRIGGER trg_no_self_citation_update
BEFORE UPDATE ON citation
FOR EACH ROW
BEGIN
    IF NEW.citing_paper_id = NEW.cited_paper_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A paper cannot cite itself';
    END IF;
END //

DELIMITER ;
