USE academic_paper_db;

-- 1. author：作者表
CREATE TABLE IF NOT EXISTS author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    institution VARCHAR(200),
    email VARCHAR(254),
    research_area VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. venue：期刊/会议表
CREATE TABLE IF NOT EXISTS venue (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(200) NOT NULL,
    venue_type VARCHAR(10),
    publisher VARCHAR(100),
    paper_count INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. paper：论文表
CREATE TABLE IF NOT EXISTS paper (
    paper_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    abstract TEXT,
    publish_year YEAR NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'Draft',
    venue_id INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. keyword：关键词表
CREATE TABLE IF NOT EXISTS keyword (
    keyword_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword_name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. paper_author：论文作者关系表
CREATE TABLE IF NOT EXISTS paper_author (
    paper_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    is_corresponding BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (paper_id, author_id),
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. paper_keyword：论文关键词关系表
CREATE TABLE IF NOT EXISTS paper_keyword (
    paper_id INT NOT NULL,
    keyword_id INT NOT NULL,
    PRIMARY KEY (paper_id, keyword_id),
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. submission：投稿记录表
CREATE TABLE IF NOT EXISTS submission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    paper_id INT NOT NULL,
    venue_id INT NOT NULL,
    submit_date DATE NOT NULL,
    result VARCHAR(20) NOT NULL DEFAULT 'Under Review',
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. review：审稿记录表
CREATE TABLE IF NOT EXISTS review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    reviewer_name VARCHAR(100),
    score TINYINT UNSIGNED,
    comment TEXT,
    review_date DATE,
    CHECK (score IS NULL OR score BETWEEN 1 AND 5),
    FOREIGN KEY (submission_id) REFERENCES submission(submission_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. citation：论文引用关系表
CREATE TABLE IF NOT EXISTS citation (
    citing_paper_id INT NOT NULL,
    cited_paper_id INT NOT NULL,
    PRIMARY KEY (citing_paper_id, cited_paper_id),
    FOREIGN KEY (citing_paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (cited_paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
