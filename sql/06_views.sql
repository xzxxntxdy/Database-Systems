USE academic_paper_db;

DROP VIEW IF EXISTS v_citation_stats;

-- Comprehensive paper information view.
-- This single view is used by the front-end query page.
CREATE OR REPLACE VIEW v_paper_info AS
SELECT
    p.paper_id,
    p.title,
    p.abstract,
    p.publish_year,
    p.status,
    v.venue_name,
    v.venue_type,
    v.publisher,
    GROUP_CONCAT(DISTINCT a.name ORDER BY pa.author_order SEPARATOR ', ') AS authors,
    GROUP_CONCAT(DISTINCT k.keyword_name SEPARATOR ', ') AS keywords,
    sub.result AS submission_result,
    sub.submit_date,
    COUNT(DISTINCT cited_by.citing_paper_id) AS cited_by_count,
    COUNT(DISTINCT refs.cited_paper_id) AS reference_count
FROM paper p
LEFT JOIN venue v ON p.venue_id = v.venue_id
LEFT JOIN paper_author pa ON p.paper_id = pa.paper_id
LEFT JOIN author a ON pa.author_id = a.author_id
LEFT JOIN paper_keyword pk ON p.paper_id = pk.paper_id
LEFT JOIN keyword k ON pk.keyword_id = k.keyword_id
LEFT JOIN (
    SELECT submission_id, paper_id, result, submit_date
    FROM (
        SELECT
            s.submission_id,
            s.paper_id,
            s.result,
            s.submit_date,
            ROW_NUMBER() OVER (
                PARTITION BY s.paper_id
                ORDER BY s.submit_date DESC, s.submission_id DESC
            ) AS rn
        FROM submission s
    ) ranked_submission
    WHERE rn = 1
) sub ON p.paper_id = sub.paper_id
LEFT JOIN citation cited_by ON p.paper_id = cited_by.cited_paper_id
LEFT JOIN citation refs ON p.paper_id = refs.citing_paper_id
GROUP BY
    p.paper_id,
    p.title,
    p.abstract,
    p.publish_year,
    p.status,
    v.venue_name,
    v.venue_type,
    v.publisher,
    sub.result,
    sub.submit_date;
