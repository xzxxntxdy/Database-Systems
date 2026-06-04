USE academic_paper_db;

DROP PROCEDURE IF EXISTS sp_update_submission_result;

DELIMITER //

-- Stored procedure: update the latest submission result of a paper.
-- Rules:
-- 1. submission_id must belong to paper_id.
-- 2. Only the latest submission record of a paper can be updated.
-- 3. result must be one of: Under Review, Accepted, Rejected.
-- 4. A paper cannot be under review at multiple venues at the same time.
-- 5. paper.status is synchronized with the latest submission result.
CREATE PROCEDURE sp_update_submission_result(
    IN p_submission_id INT,
    IN p_paper_id INT,
    IN p_new_result VARCHAR(50)
)
BEGIN
    DECLARE v_count INT DEFAULT 0;
    DECLARE v_latest_submission_id INT DEFAULT NULL;
    DECLARE v_submission_venue_id INT DEFAULT NULL;
    DECLARE v_other_under_review_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM submission
    WHERE submission_id = p_submission_id
      AND paper_id = p_paper_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Submission does not match the paper';
    END IF;

    SELECT submission_id INTO v_latest_submission_id
    FROM submission
    WHERE paper_id = p_paper_id
    ORDER BY submit_date DESC, submission_id DESC
    LIMIT 1;

    IF v_latest_submission_id <> p_submission_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Only the latest submission record of this paper can be updated';
    END IF;

    IF p_new_result NOT IN ('Under Review', 'Accepted', 'Rejected') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid submission result';
    END IF;

    IF p_new_result = 'Under Review' THEN
        SELECT COUNT(*) INTO v_other_under_review_count
        FROM submission
        WHERE paper_id = p_paper_id
          AND submission_id <> p_submission_id
          AND result = 'Under Review';

        IF v_other_under_review_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A paper cannot have multiple Under Review submissions at the same time';
        END IF;
    END IF;

    SELECT venue_id INTO v_submission_venue_id
    FROM submission
    WHERE submission_id = p_submission_id
      AND paper_id = p_paper_id;

    UPDATE submission
    SET result = p_new_result
    WHERE submission_id = p_submission_id
      AND paper_id = p_paper_id;

    UPDATE paper
    SET
        status = CASE
            WHEN p_new_result = 'Under Review' THEN 'Submitted'
            WHEN p_new_result = 'Accepted' THEN 'Accepted'
            WHEN p_new_result = 'Rejected' THEN 'Rejected'
            ELSE status
        END,
        venue_id = CASE
            WHEN p_new_result = 'Accepted' THEN v_submission_venue_id
            WHEN p_new_result IN ('Under Review', 'Rejected') THEN NULL
            ELSE venue_id
        END
    WHERE paper_id = p_paper_id;
END //

DELIMITER ;
