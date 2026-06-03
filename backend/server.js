const express = require("express");
const cors = require("cors");
const Database = require("./database");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Wait for DB to be ready before starting server
Database.create()
  .then((db) => {
    app.get("/", (req, res) => {
      res.send("StudySphere API is running");
    });

    // AUTH

    app.post("/auth/login", async (req, res) => {
      try {
        const { email, password } = req.body;
        if (!email || !password)
          return res.status(400).json({ error: "Email and password required" });
        const user = await db.findUserByEmailAndPassword(email, password);
        if (!user)
          return res.status(401).json({ error: "Invalid email or password" });
        res.json(user);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/auth/register", async (req, res) => {
      try {
        const { id, name, email, password, role, status } = req.body;
        if (!name || !email || !password)
          return res
            .status(400)
            .json({ error: "Name, email and password required" });
        const existing = await db.findUserByEmail(email);
        if (existing)
          return res
            .status(409)
            .json({ error: "An account with this email already exists" });
        const user = await db.createUser({
          id: id || `user-${Date.now()}`,
          name,
          email,
          password,
          role: role || "User",
          status: status || "active",
        });
        res.status(201).json(user);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── USERS ─────────────────────────────────────────────────────────────────

    app.get("/users", async (req, res) => {
      try {
        res.json(await db.allUsers());
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.put("/users/:id", async (req, res) => {
      try {
        const user = await db.updateUser(req.params.id, req.body);
        if (!user) return res.status(404).json({ error: "User not found" });
        res.json(user);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.patch("/users/:id/toggle-status", async (req, res) => {
      try {
        const user = await db.toggleUserStatus(req.params.id);
        if (!user) return res.status(404).json({ error: "User not found" });
        res.json(user);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.delete("/users/:id", async (req, res) => {
      try {
        await db.deleteUser(req.params.id);
        res.status(204).send();
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── RESOURCES ─────────────────────────────────────────────────────────────

    app.get("/resources", async (req, res) => {
      try {
        res.json(await db.allResources());
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.get("/resources/:id", async (req, res) => {
      try {
        const r = await db.findResourceById(req.params.id);
        if (!r) return res.status(404).json({ error: "Resource not found" });
        res.json(r);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/resources", async (req, res) => {
      try {
        res.status(201).json(await db.createResource(req.body));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.put("/resources/:id", async (req, res) => {
      try {
        const r = await db.updateResource(req.params.id, req.body);
        if (!r) return res.status(404).json({ error: "Resource not found" });
        res.json(r);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.patch("/resources/:id/approve", async (req, res) => {
      try {
        const r = await db.approveResource(req.params.id);
        if (!r) return res.status(404).json({ error: "Resource not found" });
        res.json(r);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.delete("/resources/:id", async (req, res) => {
      try {
        await db.deleteResource(req.params.id);
        res.status(204).send();
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── BOOKMARKS ─────────────────────────────────────────────────────────────

    app.get("/bookmarks/:userId", async (req, res) => {
      try {
        res.json(await db.bookmarksForUser(req.params.userId));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/bookmarks", async (req, res) => {
      try {
        const { user_id, resource_id } = req.body;
        if (!user_id || !resource_id)
          return res
            .status(400)
            .json({ error: "user_id and resource_id required" });
        await db.addBookmark(user_id, resource_id);
        res.status(201).json({ user_id, resource_id });
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.delete("/bookmarks/:userId/:resourceId", async (req, res) => {
      try {
        await db.removeBookmark(req.params.userId, req.params.resourceId);
        res.status(204).send();
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── REVIEWS ───────────────────────────────────────────────────────────────

    app.get("/reviews/:resourceId", async (req, res) => {
      try {
        res.json(await db.reviewsForResource(req.params.resourceId));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/reviews", async (req, res) => {
      try {
        res.status(201).json(await db.addReview(req.body));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── REQUESTS ──────────────────────────────────────────────────────────────

    app.get("/requests", async (req, res) => {
      try {
        res.json(await db.allRequests());
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/requests", async (req, res) => {
      try {
        res.status(201).json(await db.createRequest(req.body));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.put("/requests/:id", async (req, res) => {
      try {
        const r = await db.updateRequest(req.params.id, req.body);
        if (!r) return res.status(404).json({ error: "Request not found" });
        res.json(r);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.patch("/requests/:id/fulfill", async (req, res) => {
      try {
        const r = await db.fulfillRequest(req.params.id);
        if (!r) return res.status(404).json({ error: "Request not found" });
        res.json(r);
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.delete("/requests/:id", async (req, res) => {
      try {
        await db.deleteRequest(req.params.id);
        res.status(204).send();
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── ACTIVITIES ────────────────────────────────────────────────────────────

    app.get("/activities", async (req, res) => {
      try {
        res.json(await db.getActivities(req.query.userId));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    app.post("/activities", async (req, res) => {
      try {
        res.status(201).json(await db.logActivity(req.body));
      } catch (e) {
        res.status(500).json({ error: e.message });
      }
    });

    // ── START ─────────────────────────────────────────────────────────────────

    app.listen(PORT, () => {
      console.log(`\n✅  StudySphere API  →  http://localhost:${PORT}\n`);
    });
  })
  .catch((err) => {
    console.error("❌  Failed to initialize database:", err);
    process.exit(1);
  });
