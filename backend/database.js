const sqlite3 = require('sqlite3').verbose();
const path    = require('path');

const DB_PATH = path.join(__dirname, 'studysphere.db');

class Database {
  constructor(db) {
    this.db = db;
  }

  // Factory — waits for DB + tables to be ready
  static create() {
    return new Promise((resolve, reject) => {
      const db = new sqlite3.Database(DB_PATH, async (err) => {
        if (err) return reject(err);
        console.log('SQLite  →  studysphere.db');
        const instance = new Database(db);
        try {
          await instance._init();
          resolve(instance);
        } catch (e) {
          reject(e);
        }
      });
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(sql, params, function (err) {
        if (err) reject(err); else resolve(this);
      });
    });
  }

  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(sql, params, (err, rows) => {
        if (err) reject(err); else resolve(rows);
      });
    });
  }

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.get(sql, params, (err, row) => {
        if (err) reject(err); else resolve(row || null);
      });
    });
  }

  // ── Create tables + seed ──────────────────────────────────────────────────

  async _init() {
    await this.run(`CREATE TABLE IF NOT EXISTS users (
      id       TEXT PRIMARY KEY,
      name     TEXT NOT NULL,
      email    TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      role     TEXT NOT NULL DEFAULT 'User',
      status   TEXT NOT NULL DEFAULT 'active'
    )`);

    await this.run(`CREATE TABLE IF NOT EXISTS resources (
      id           TEXT PRIMARY KEY,
      title        TEXT,
      description  TEXT,
      courseCode   TEXT,
      rating       REAL    DEFAULT 0.0,
      reviewCount  INTEGER DEFAULT 0,
      uses         INTEGER DEFAULT 0,
      fileType     TEXT,
      uploader     TEXT,
      isApproved   INTEGER DEFAULT 0,
      isBookmarked INTEGER DEFAULT 0,
      isDownloaded INTEGER DEFAULT 0,
      file_path    TEXT
    )`);

    await this.run(`CREATE TABLE IF NOT EXISTS requests (
      id          TEXT PRIMARY KEY,
      title       TEXT,
      description TEXT,
      courseCode  TEXT,
      requestedBy TEXT,
      time        TEXT,
      status      TEXT DEFAULT 'open'
    )`);

    await this.run(`CREATE TABLE IF NOT EXISTS bookmarks (
      user_id     TEXT NOT NULL,
      resource_id TEXT NOT NULL,
      PRIMARY KEY (user_id, resource_id)
    )`);

    await this.run(`CREATE TABLE IF NOT EXISTS reviews (
      id          TEXT PRIMARY KEY,
      resource_id TEXT NOT NULL,
      user_id     TEXT NOT NULL,
      user_name   TEXT,
      rating      REAL,
      comment     TEXT,
      time        TEXT
    )`);

    await this.run(`CREATE TABLE IF NOT EXISTS activities (
      id          TEXT PRIMARY KEY,
      userId      TEXT,
      userName    TEXT,
      type        TEXT,
      title       TEXT,
      time        TEXT,
      referenceId TEXT
    )`);

    // Seed default users if empty
    const row = await this.get('SELECT COUNT(*) as c FROM users');
    if (row.c === 0) {
      await this.run(
        'INSERT INTO users (id, name, email, password, role, status) VALUES (?,?,?,?,?,?)',
        ['admin-1', 'Admin User', 'admin@studysphere.com', 'admin123', 'Admin', 'active']
      );
      await this.run(
        'INSERT INTO users (id, name, email, password, role, status) VALUES (?,?,?,?,?,?)',
        ['student-1', 'Anatoli Chala', 'student@studysphere.com', 'student123', 'User', 'active']
      );
      console.log('🌱  Seeded default users');
    }
  }

  // ── USERS ─────────────────────────────────────────────────────────────────

  allUsers() {
    return this.all('SELECT * FROM users');
  }

  findUserByEmail(email) {
    return this.get('SELECT * FROM users WHERE LOWER(email) = LOWER(?)', [email]);
  }

  findUserByEmailAndPassword(email, password) {
    return this.get(
      'SELECT * FROM users WHERE LOWER(email) = LOWER(?) AND password = ?',
      [email, password]
    );
  }

  findUserById(id) {
    return this.get('SELECT * FROM users WHERE id = ?', [id]);
  }

  async createUser({ id, name, email, password, role, status }) {
    await this.run(
      'INSERT INTO users (id, name, email, password, role, status) VALUES (?,?,?,?,?,?)',
      [id, name, email, password, role || 'User', status || 'active']
    );
    return this.findUserById(id);
  }

  async updateUser(id, u) {
    // Use INSERT OR REPLACE so it works even if user was deleted from DB
    await this.run(
      `INSERT OR REPLACE INTO users (id, name, email, password, role, status)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [id, u.name, u.email, u.password, u.role || 'User', u.status || 'active']
    );
    return this.findUserById(id);
  }

  async toggleUserStatus(id) {
    const user = await this.findUserById(id);
    if (!user) return null;
    const next = user.status === 'active' ? 'suspended' : 'active';
    await this.run('UPDATE users SET status=? WHERE id=?', [next, id]);
    return this.findUserById(id);
  }

  async deleteUser(id) {
    await this.run('DELETE FROM bookmarks WHERE user_id=?', [id]);
    await this.run('DELETE FROM reviews   WHERE user_id=?', [id]);
    await this.run('DELETE FROM users     WHERE id=?',      [id]);
  }

  // ── RESOURCES ─────────────────────────────────────────────────────────────

  allResources() {
    return this.all('SELECT * FROM resources');
  }

  findResourceById(id) {
    return this.get('SELECT * FROM resources WHERE id=?', [id]);
  }

  async createResource(r) {
    await this.run(
      `INSERT INTO resources
        (id, title, description, courseCode, rating, reviewCount, uses,
         fileType, uploader, isApproved, isBookmarked, isDownloaded, file_path)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [
        r.id, r.title, r.description, r.courseCode,
        r.rating ?? 0, r.reviewCount ?? 0, r.uses ?? 0,
        r.fileType, r.uploader,
        r.isApproved ?? 0, r.isBookmarked ?? 0, r.isDownloaded ?? 0,
        r.file_path || null,
      ]
    );
    return this.findResourceById(r.id);
  }

  async updateResource(id, r) {
    await this.run(
      `UPDATE resources SET title=?, description=?, courseCode=?,
       fileType=?, uploader=?, file_path=? WHERE id=?`,
      [r.title, r.description, r.courseCode, r.fileType, r.uploader, r.file_path || null, id]
    );
    return this.findResourceById(id);
  }

  async approveResource(id) {
    await this.run('UPDATE resources SET isApproved=1 WHERE id=?', [id]);
    return this.findResourceById(id);
  }

  async deleteResource(id) {
    await this.run('DELETE FROM bookmarks WHERE resource_id=?', [id]);
    await this.run('DELETE FROM reviews   WHERE resource_id=?', [id]);
    await this.run('DELETE FROM resources WHERE id=?',          [id]);
  }

  // ── BOOKMARKS ─────────────────────────────────────────────────────────────

  bookmarksForUser(userId) {
    return this.all(
      `SELECT r.* FROM resources r
       INNER JOIN bookmarks b ON r.id = b.resource_id
       WHERE b.user_id = ?`,
      [userId]
    );
  }

  async addBookmark(userId, resourceId) {
    await this.run(
      'INSERT OR IGNORE INTO bookmarks (user_id, resource_id) VALUES (?,?)',
      [userId, resourceId]
    );
  }

  async removeBookmark(userId, resourceId) {
    await this.run(
      'DELETE FROM bookmarks WHERE user_id=? AND resource_id=?',
      [userId, resourceId]
    );
  }

  // ── REVIEWS ───────────────────────────────────────────────────────────────

  reviewsForResource(resourceId) {
    return this.all('SELECT * FROM reviews WHERE resource_id=?', [resourceId]);
  }

  async addReview(r) {
    await this.run(
      `INSERT INTO reviews (id, resource_id, user_id, user_name, rating, comment, time)
       VALUES (?,?,?,?,?,?,?)`,
      [r.id, r.resource_id, r.user_id, r.user_name, r.rating, r.comment || '', r.time]
    );
    const rows = await this.all(
      'SELECT rating FROM reviews WHERE resource_id=?', [r.resource_id]
    );
    const avg = rows.reduce((s, x) => s + x.rating, 0) / rows.length;
    await this.run(
      'UPDATE resources SET rating=?, reviewCount=? WHERE id=?',
      [parseFloat(avg.toFixed(2)), rows.length, r.resource_id]
    );
    return this.get('SELECT * FROM reviews WHERE id=?', [r.id]);
  }

  // ── REQUESTS ──────────────────────────────────────────────────────────────

  allRequests() {
    return this.all('SELECT * FROM requests');
  }

  async createRequest(r) {
    await this.run(
      `INSERT INTO requests (id, title, description, courseCode, requestedBy, time, status)
       VALUES (?,?,?,?,?,?,?)`,
      [r.id, r.title, r.description, r.courseCode, r.requestedBy, r.time, r.status || 'open']
    );
    return this.get('SELECT * FROM requests WHERE id=?', [r.id]);
  }

  async updateRequest(id, r) {
    await this.run(
      `UPDATE requests SET title=?, description=?, courseCode=?,
       requestedBy=?, time=?, status=? WHERE id=?`,
      [r.title, r.description, r.courseCode, r.requestedBy, r.time, r.status, id]
    );
    return this.get('SELECT * FROM requests WHERE id=?', [id]);
  }

  async fulfillRequest(id) {
    await this.run('UPDATE requests SET status=? WHERE id=?', ['fulfilled', id]);
    return this.get('SELECT * FROM requests WHERE id=?', [id]);
  }

  async deleteRequest(id) {
    await this.run('DELETE FROM requests WHERE id=?', [id]);
  }

  // ── ACTIVITIES ────────────────────────────────────────────────────────────

  getActivities(userId) {
    if (userId) {
      return this.all(
        'SELECT * FROM activities WHERE userId=? ORDER BY rowid DESC', [userId]
      );
    }
    return this.all('SELECT * FROM activities ORDER BY rowid DESC');
  }

  async logActivity(a) {
    await this.run(
      `INSERT INTO activities (id, userId, userName, type, title, time, referenceId)
       VALUES (?,?,?,?,?,?,?)`,
      [a.id, a.userId, a.userName, a.type, a.title, a.time, a.referenceId || null]
    );
    return this.get('SELECT * FROM activities WHERE id=?', [a.id]);
  }
}

module.exports = Database;
