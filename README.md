# 学术论文数据库管理系统

南开大学数据库作业，基于 Flask + MySQL 开发，用于管理论文、作者、期刊/会议、投稿记录、审稿记录、关键词和引用关系。

本项目采用 B/S 模式，浏览器访问 Flask Web 系统，后端通过 PyMySQL 操作 MySQL 数据库。

## 项目特点

- 使用 MySQL 8.0 作为后台数据库。
- 使用 Flask + PyMySQL 实现 Web 后端。
- 使用 Bootstrap 页面展示核心数据库操作。
- 覆盖数据库工程作业要求的事务、触发器、存储过程和视图。
- 示例数据使用公开论文元数据整理，投稿和审稿记录为课程演示数据。

## 开发环境

- **操作系统**: Windows 11
- **数据库**: MySQL 8.0.37 Community Server
- **高级语言**: Python 3.12.7
- **Web 框架**: Flask 3.0.3
- **数据库连接**: PyMySQL 1.1.3
- **开发工具**: VS Code
- **浏览器**: Chrome / Edge

## 功能结构

### 核心功能

| 功能 | 页面 | 数据库技术点 |
|---|---|---|
| 添加论文 | `/add_paper` | 触发器检查年份、状态和 venue 规则 |
| 添加投稿 | `/add_submission` | 防止一稿多投，新增 Under Review 投稿 |
| 更新投稿状态 | `/update_submission` | 调用存储过程同步 `submission` 和 `paper` |
| 删除论文 | `/delete_paper` | 使用事务删除论文及关联数据 |
| 添加引用 | `/add_citation` | 维护论文引用关系 |
| 综合查询 | `/query_papers` | 查询综合视图 `v_paper_info` |

### 状态设计

论文状态 `paper.status`：

```text
Draft、Submitted、Accepted、Rejected
```

投稿结果 `submission.result`：

```text
Under Review、Accepted、Rejected
```

说明：

- `Draft`：草稿论文，不能绑定期刊/会议。
- `Submitted`：论文已有投稿记录，投稿目标保存在 `submission.venue_id`。
- `Accepted`：论文已被接收，`paper.venue_id` 同步为接收的期刊/会议。
- `Rejected`：论文被拒，`paper.venue_id` 为空。

## 数据库结构

| 序号 | 表名 | 说明 |
|---|---|---|
| 1 | `author` | 作者表 |
| 2 | `venue` | 期刊/会议表 |
| 3 | `paper` | 论文表 |
| 4 | `keyword` | 关键词表 |
| 5 | `paper_author` | 论文作者关系表 |
| 6 | `paper_keyword` | 论文关键词关系表 |
| 7 | `submission` | 投稿记录表 |
| 8 | `review` | 审稿记录表 |
| 9 | `citation` | 论文引用关系表 |

数据库对象：

| 类型 | 名称 |
|---|---|
| 触发器 | `trg_check_paper_year`、`trg_check_paper_status`、`trg_check_paper_venue_insert`、`trg_update_venue_paper_count` 等 |
| 存储过程 | `sp_update_submission_result` |
| 视图 | `v_paper_info` |

## 安装和运行

### 1. 安装 Python 依赖

```bash
pip install -r requirements.txt
```

### 2. 配置 MySQL 数据库

确保 MySQL 服务已启动，然后执行以下命令初始化数据库：

```bash
mysql -u root -p < sql/01_create_database.sql
mysql -u root -p academic_paper_db < sql/02_create_tables.sql
mysql -u root -p academic_paper_db --default-character-set=utf8mb4 < sql/03_insert_sample_data.sql
mysql -u root -p academic_paper_db --default-character-set=utf8mb4 < sql/04_triggers.sql
mysql -u root -p academic_paper_db --default-character-set=utf8mb4 < sql/05_procedures.sql
mysql -u root -p academic_paper_db --default-character-set=utf8mb4 < sql/06_views.sql
```

如果 MySQL root 用户没有密码，可以去掉命令中的 `-p`。

### 3. 修改数据库连接配置

编辑 `app.py` 中的 `DB_CONFIG` 字典，修改数据库连接参数：

```python
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'your_password',
    'database': 'academic_paper_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
    'autocommit': False
}
```

### 4. 启动系统

```bash
python app.py
```

浏览器访问: http://127.0.0.1:5000

### 5. Windows 本地辅助脚本

仓库中可能存在本地演示用的 `start.bat` 和 `stop.bat`，但 `.bat` 文件已加入 `.gitignore`，不会作为正式提交内容。

- `start.bat`：本机一键启动 MySQL、初始化数据库并启动 Flask。
- `stop.bat`：本机一键停止 `mysqld.exe` 和 `python.exe`。

这些脚本依赖本机路径配置，换电脑运行时应优先使用上面的手动命令。

## 演示顺序

1. 首页查看论文、作者、期刊/会议、投稿数量。
2. “添加论文”演示合法插入和触发器拦截非法年份、非法状态与 venue 组合。
3. “添加投稿”演示新增 Under Review 投稿，并说明投稿目标记录在 `submission.venue_id`。
4. “更新投稿状态”演示调用存储过程把最新投稿更新为 Accepted 或 Rejected。
5. “添加引用”演示添加论文引用关系。
6. “综合查询”演示通过 `v_paper_info` 查询论文综合信息和引用统计。
7. “删除论文”演示事务删除论文及关联数据。

## 项目结构

```text
Database-Systems/
├── app.py
├── requirements.txt
├── README.md
├── .gitignore
├── .gitattributes
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   ├── 04_triggers.sql
│   ├── 05_procedures.sql
│   └── 06_views.sql
├── templates/
│   ├── base.html
│   ├── index.html
│   ├── add_paper.html
│   ├── add_submission.html
│   ├── add_citation.html
│   ├── delete_paper.html
│   ├── update_submission.html
│   └── query_papers.html
└── static/
    ├── css/
    │   └── style.css
    └── js/
        └── main.js
```

说明：报告材料、除 `README.md` 外的 Markdown 文档、`.claude/`、`.bat` 本地脚本、日志和缓存文件已加入 `.gitignore`。

## Git 配置

`.gitignore` 当前会忽略：

- 除 `README.md` 外的 Markdown 文件。
- `report/` 报告材料目录。
- `.claude/` 本地配置目录。
- `.bat` 本地辅助脚本。
- Python 缓存、虚拟环境、日志、编辑器配置、系统临时文件和常见压缩/文档导出文件。

`.gitattributes` 用于统一文本文件换行，避免 Windows 与其他系统之间出现换行差异。

## AI 使用说明

AI工具仅作为前端代码辅助设计工具，未替代本人对数据库原理、事务、触发器、存储过程和视图的理解与实现。
