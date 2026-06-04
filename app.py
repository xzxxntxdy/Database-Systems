"""
学术论文数据库管理系统 - Flask 后端
"""
from flask import Flask, render_template, request, jsonify, redirect, url_for
import pymysql
from datetime import datetime

app = Flask(__name__)

# 数据库连接配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': '',
    'database': 'academic_paper_db',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor,
    'autocommit': False
}


def get_db_connection():
    """获取数据库连接"""
    conn = pymysql.connect(**DB_CONFIG)
    return conn


@app.route('/')
def index():
    """首页 - 系统导航页"""
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT COUNT(*) as cnt FROM paper")
            paper_count = cursor.fetchone()['cnt']
            cursor.execute("SELECT COUNT(*) as cnt FROM author")
            author_count = cursor.fetchone()['cnt']
            cursor.execute("SELECT COUNT(*) as cnt FROM venue")
            venue_count = cursor.fetchone()['cnt']
            cursor.execute("SELECT COUNT(*) as cnt FROM submission")
            submission_count = cursor.fetchone()['cnt']
    finally:
        conn.close()
    return render_template('index.html',
                         paper_count=paper_count,
                         author_count=author_count,
                         venue_count=venue_count,
                         submission_count=submission_count)


# ==================== 1. 事务删除操作：删除论文 ====================

@app.route('/delete_paper', methods=['GET', 'POST'])
def delete_paper():
    """删除论文及其相关数据（事务操作）"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT paper_id, title, status, publish_year FROM paper ORDER BY paper_id")
                papers = cursor.fetchall()
        finally:
            conn.close()
        return render_template('delete_paper.html', papers=papers)
    else:
        paper_id = request.form.get('paper_id')
        if not paper_id:
            return jsonify({'success': False, 'message': '请输入论文编号'})

        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                # 1. 删除审稿记录（通过 submission 关联）
                cursor.execute("""
                    DELETE r FROM review r
                    JOIN submission s ON r.submission_id = s.submission_id
                    WHERE s.paper_id = %s
                """, (paper_id,))

                # 2. 删除投稿记录
                cursor.execute("DELETE FROM submission WHERE paper_id = %s", (paper_id,))

                # 3. 删除论文作者关系
                cursor.execute("DELETE FROM paper_author WHERE paper_id = %s", (paper_id,))

                # 4. 删除论文关键词关系
                cursor.execute("DELETE FROM paper_keyword WHERE paper_id = %s", (paper_id,))

                # 5. 删除引用关系
                cursor.execute("""
                    DELETE FROM citation
                    WHERE citing_paper_id = %s OR cited_paper_id = %s
                """, (paper_id, paper_id))

                # 6. 删除论文本身
                cursor.execute("DELETE FROM paper WHERE paper_id = %s", (paper_id,))
                if cursor.rowcount == 0:
                    raise ValueError('论文编号不存在，未执行删除')

            conn.commit()
            return jsonify({'success': True, 'message': '论文及其关联数据已成功删除'})
        except Exception as e:
            conn.rollback()
            return jsonify({'success': False, 'message': f'删除失败，事务已回滚：{str(e)}'})
        finally:
            conn.close()


# ==================== 2. 触发器添加操作：添加论文 ====================

@app.route('/add_paper', methods=['GET', 'POST'])
def add_paper():
    """添加论文（触发器控制）"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT venue_id, venue_name, venue_type FROM venue ORDER BY venue_id")
                venues = cursor.fetchall()
                cursor.execute("SELECT author_id, name, institution FROM author ORDER BY author_id")
                authors = cursor.fetchall()
                cursor.execute("SELECT keyword_id, keyword_name FROM keyword ORDER BY keyword_id")
                keywords = cursor.fetchall()
        finally:
            conn.close()
        from datetime import datetime
        return render_template('add_paper.html', venues=venues,
                             authors=authors, keywords=keywords,
                             current_year=datetime.now().year)
    else:
        title = request.form.get('title')
        abstract = request.form.get('abstract', '')
        publish_year = request.form.get('publish_year')
        status = request.form.get('status', 'Draft')
        venue_id = request.form.get('venue_id') or None
        author_ids = request.form.getlist('author_ids')
        keyword_ids = request.form.getlist('keyword_ids')
        allowed_statuses = {'Draft', 'Submitted', 'Accepted', 'Rejected'}

        if not title:
            return jsonify({'success': False, 'message': '论文标题不能为空'})
        if not publish_year:
            return jsonify({'success': False, 'message': '请填写论文发表年份'})
        if status not in allowed_statuses:
            return jsonify({'success': False, 'message': '论文状态不合法'})
        if not author_ids:
            return jsonify({'success': False, 'message': '请至少选择一位作者'})

        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                # 插入论文（触发器会自动检查年份和状态）
                cursor.execute("""
                    INSERT INTO paper (title, abstract, publish_year, status, venue_id, created_at)
                    VALUES (%s, %s, %s, %s, %s, NOW())
                """, (title, abstract, publish_year, status, venue_id))

                paper_id = cursor.lastrowid

                # 插入论文作者关系
                for i, author_id in enumerate(author_ids, 1):
                    cursor.execute("""
                        INSERT INTO paper_author (paper_id, author_id, author_order, is_corresponding)
                        VALUES (%s, %s, %s, %s)
                    """, (paper_id, author_id, i, (i == 1)))

                # 插入论文关键词关系
                for keyword_id in keyword_ids:
                    cursor.execute("""
                        INSERT INTO paper_keyword (paper_id, keyword_id)
                        VALUES (%s, %s)
                    """, (paper_id, keyword_id))

            conn.commit()
            return jsonify({'success': True, 'message': f'论文添加成功，论文编号：{paper_id}'})
        except Exception as e:
            conn.rollback()
            return jsonify({'success': False, 'message': f'添加失败：{str(e)}'})
        finally:
            conn.close()


# ==================== 3. 添加投稿记录：论文投稿 ====================

@app.route('/add_submission', methods=['GET', 'POST'])
def add_submission():
    """添加投稿记录，并同步论文状态"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT
                        p.paper_id,
                        p.title,
                        p.publish_year,
                        p.status,
                        latest.result AS latest_result,
                        latest.submit_date AS latest_submit_date
                    FROM paper p
                    LEFT JOIN (
                        SELECT paper_id, result, submit_date
                        FROM (
                            SELECT
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
                    ) latest ON p.paper_id = latest.paper_id
                    WHERE p.status IN ('Draft', 'Rejected', 'Submitted')
                      AND NOT EXISTS (
                          SELECT 1
                          FROM submission s2
                          WHERE s2.paper_id = p.paper_id
                            AND s2.result = 'Under Review'
                      )
                    ORDER BY p.paper_id
                """)
                papers = cursor.fetchall()

                cursor.execute("SELECT venue_id, venue_name, venue_type FROM venue ORDER BY venue_id")
                venues = cursor.fetchall()
        finally:
            conn.close()

        return render_template('add_submission.html', papers=papers, venues=venues)

    paper_id = request.form.get('paper_id')
    venue_id = request.form.get('venue_id')
    submit_date = request.form.get('submit_date') or datetime.now().strftime('%Y-%m-%d')

    if not paper_id or not venue_id:
        return jsonify({'success': False, 'message': '请选择论文和投稿期刊/会议'})

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT status FROM paper WHERE paper_id = %s", (paper_id,))
            paper = cursor.fetchone()
            if not paper:
                raise ValueError('论文不存在')

            if paper['status'] == 'Accepted':
                raise ValueError('已接收的论文不能再新增投稿记录')

            cursor.execute("""
                SELECT COUNT(*) AS cnt
                FROM submission
                WHERE paper_id = %s
                  AND result = 'Under Review'
            """, (paper_id,))
            if cursor.fetchone()['cnt'] > 0:
                raise ValueError('该论文已有 Under Review 投稿，不能一稿多投')

            cursor.execute("""
                INSERT INTO submission (paper_id, venue_id, submit_date, result)
                VALUES (%s, %s, %s, 'Under Review')
            """, (paper_id, venue_id, submit_date))
            submission_id = cursor.lastrowid

            cursor.execute("""
                UPDATE paper
                SET status = 'Submitted',
                    venue_id = NULL
                WHERE paper_id = %s
            """, (paper_id,))

        conn.commit()
        return jsonify({
            'success': True,
            'message': f'投稿记录添加成功，投稿编号：{submission_id}，论文状态已更新为 Submitted'
        })
    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': f'添加投稿失败，事务已回滚：{str(e)}'})
    finally:
        conn.close()


# ==================== 4. 存储过程更新操作：更新投稿状态 ====================

@app.route('/update_submission', methods=['GET', 'POST'])
def update_submission():
    """更新投稿状态（存储过程控制）"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT submission_id, paper_id, title, venue_name, result, status, submit_date
                    FROM (
                        SELECT
                            s.submission_id,
                            s.paper_id,
                            p.title,
                            v.venue_name,
                            s.result,
                            p.status,
                            s.submit_date,
                            ROW_NUMBER() OVER (
                                PARTITION BY s.paper_id
                                ORDER BY s.submit_date DESC, s.submission_id DESC
                            ) AS rn
                        FROM submission s
                        JOIN paper p ON s.paper_id = p.paper_id
                        LEFT JOIN venue v ON s.venue_id = v.venue_id
                    ) latest_submission
                    WHERE rn = 1
                    ORDER BY paper_id
                """)
                submissions = cursor.fetchall()
        finally:
            conn.close()
        return render_template('update_submission.html', submissions=submissions)
    else:
        submission_id = request.form.get('submission_id')
        paper_id = request.form.get('paper_id')
        new_result = request.form.get('new_result')

        if not submission_id or not paper_id or not new_result:
            return jsonify({'success': False, 'message': '请填写所有必填字段'})

        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("CALL sp_update_submission_result(%s, %s, %s)",
                             (submission_id, paper_id, new_result))
            conn.commit()
            return jsonify({'success': True, 'message': '投稿状态更新成功'})
        except Exception as e:
            conn.rollback()
            return jsonify({'success': False, 'message': f'更新失败：{str(e)}'})
        finally:
            conn.close()


# ==================== 5. 添加引用关系：论文引用管理 ====================

@app.route('/add_citation', methods=['GET', 'POST'])
def add_citation():
    """添加论文引用关系"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT paper_id, title, publish_year, status FROM paper ORDER BY paper_id")
                papers = cursor.fetchall()
                cursor.execute("""
                    SELECT
                        c.citing_paper_id,
                        citing.title AS citing_title,
                        c.cited_paper_id,
                        cited.title AS cited_title
                    FROM citation c
                    JOIN paper citing ON c.citing_paper_id = citing.paper_id
                    JOIN paper cited ON c.cited_paper_id = cited.paper_id
                    ORDER BY c.citing_paper_id, c.cited_paper_id
                """)
                citations = cursor.fetchall()
        finally:
            conn.close()

        return render_template('add_citation.html', papers=papers, citations=citations)

    citing_paper_id = request.form.get('citing_paper_id')
    cited_paper_id = request.form.get('cited_paper_id')

    if not citing_paper_id or not cited_paper_id:
        return jsonify({'success': False, 'message': '请选择引用方论文和被引用论文'})
    if citing_paper_id == cited_paper_id:
        return jsonify({'success': False, 'message': '论文不能引用自己'})

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT COUNT(*) AS cnt
                FROM paper
                WHERE paper_id IN (%s, %s)
            """, (citing_paper_id, cited_paper_id))
            if cursor.fetchone()['cnt'] != 2:
                raise ValueError('引用方论文或被引用论文不存在')

            cursor.execute("""
                SELECT COUNT(*) AS cnt
                FROM citation
                WHERE citing_paper_id = %s
                  AND cited_paper_id = %s
            """, (citing_paper_id, cited_paper_id))
            if cursor.fetchone()['cnt'] > 0:
                raise ValueError('该引用关系已存在，不能重复添加')

            cursor.execute("""
                INSERT INTO citation (citing_paper_id, cited_paper_id)
                VALUES (%s, %s)
            """, (citing_paper_id, cited_paper_id))

        conn.commit()
        return jsonify({'success': True, 'message': '引用关系添加成功'})
    except Exception as e:
        conn.rollback()
        return jsonify({'success': False, 'message': f'添加引用失败，事务已回滚：{str(e)}'})
    finally:
        conn.close()


# ==================== 6. 视图查询操作：论文综合查询 ====================

@app.route('/query_papers', methods=['GET', 'POST'])
def query_papers():
    """论文综合查询（基于视图）"""
    if request.method == 'GET':
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM v_paper_info ORDER BY paper_id")
                results = cursor.fetchall()
        finally:
            conn.close()
        return render_template('query_papers.html', results=results, keyword='')
    else:
        keyword = request.form.get('keyword', '')
        conn = get_db_connection()
        try:
            with conn.cursor() as cursor:
                sql = """
                    SELECT *
                    FROM v_paper_info
                    WHERE title LIKE CONCAT('%%', %s, '%%')
                       OR authors LIKE CONCAT('%%', %s, '%%')
                       OR venue_name LIKE CONCAT('%%', %s, '%%')
                       OR keywords LIKE CONCAT('%%', %s, '%%')
                    ORDER BY paper_id
                """
                cursor.execute(sql, (keyword, keyword, keyword, keyword))
                results = cursor.fetchall()
        finally:
            conn.close()
        return render_template('query_papers.html', results=results, keyword=keyword)


# ==================== 数据浏览API ====================

@app.route('/api/browse/<table_name>')
def browse_table(table_name):
    """浏览数据表内容"""
    allowed_tables = ['author', 'venue', 'paper', 'keyword', 'paper_author',
                     'paper_keyword', 'submission', 'review', 'citation',
                     'v_paper_info']
    if table_name not in allowed_tables:
        return jsonify({'error': 'Invalid table name'}), 400

    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            cursor.execute(f"SELECT * FROM {table_name} LIMIT 50")
            rows = cursor.fetchall()
            if rows:
                columns = list(rows[0].keys())
            else:
                columns = []
        return jsonify({'columns': columns, 'rows': rows})
    finally:
        conn.close()


if __name__ == '__main__':
    app.run(debug=True, host='127.0.0.1', port=5000)
