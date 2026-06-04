USE academic_paper_db;

-- 1. author：作者表
CREATE TABLE IF NOT EXISTS author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    institution VARCHAR(200),
    email VARCHAR(100),
    research_area VARCHAR(200)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. venue：期刊/会议表
CREATE TABLE IF NOT EXISTS venue (
    venue_id INT AUTO_INCREMENT PRIMARY KEY,
    venue_name VARCHAR(200) NOT NULL,
    venue_type VARCHAR(50),
    publisher VARCHAR(200),
    paper_count INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. paper：论文表
CREATE TABLE IF NOT EXISTS paper (
    paper_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(300) NOT NULL,
    abstract TEXT,
    publish_year INT NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Draft',
    venue_id INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. keyword：关键词表
CREATE TABLE IF NOT EXISTS keyword (
    keyword_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. paper_author：论文作者关系表
CREATE TABLE IF NOT EXISTS paper_author (
    paper_id INT,
    author_id INT,
    author_order INT DEFAULT 1,
    is_corresponding BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (paper_id, author_id),
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES author(author_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. paper_keyword：论文关键词关系表
CREATE TABLE IF NOT EXISTS paper_keyword (
    paper_id INT,
    keyword_id INT,
    PRIMARY KEY (paper_id, keyword_id),
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (keyword_id) REFERENCES keyword(keyword_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. submission：投稿记录表
CREATE TABLE IF NOT EXISTS submission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    paper_id INT NOT NULL,
    venue_id INT NOT NULL,
    submit_date DATE,
    result VARCHAR(50) NOT NULL DEFAULT 'Under Review',
    FOREIGN KEY (paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. review：审稿记录表
CREATE TABLE IF NOT EXISTS review (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    reviewer_name VARCHAR(100),
    score INT,
    comment TEXT,
    review_date DATE,
    FOREIGN KEY (submission_id) REFERENCES submission(submission_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. citation：论文引用关系表
CREATE TABLE IF NOT EXISTS citation (
    citing_paper_id INT,
    cited_paper_id INT,
    PRIMARY KEY (citing_paper_id, cited_paper_id),
    FOREIGN KEY (citing_paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE,
    FOREIGN KEY (cited_paper_id) REFERENCES paper(paper_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
