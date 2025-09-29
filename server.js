const express = require("express");
const mysql = require("mysql2/promise");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

// Charger dotenv uniquement en développement
if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

// === DB ===
const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// === AUTH MIDDLEWARE ===
function authenticateToken(req, res, next) {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];
  if (!token) return res.status(401).json({ message: "Token manquant" });

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: "Token invalide" });
    req.user = user;
    next();
  });
}

// === ROUTES DE TEST ===
app.get("/", (req, res) => {
  res.send("✅ Backend Railway OK");
});

app.get("/healthz", (req, res) => {
  res.json({ ok: true, uptime: process.uptime() });
});

// === REGISTER ===
app.post("/register", authenticateToken, requirePermission("manage_users"), async (req, res) => {
  const { username, password, role } = req.body;
  if (!username || !password || !role) return res.status(400).json({ message: "Champs manquants" });

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    await db.query(
      "INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)", 
      [username, hashedPassword, role]
    );
    res.json({ message: "Utilisateur créé avec succès" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// === LOGIN ===
app.post("/login", async (req, res) => {
  const { username, password } = req.body;
  try {
    const [rows] = await db.query("SELECT * FROM users WHERE username = ?", [username]);
    if (rows.length === 0) return res.status(400).json({ message: "Utilisateur non trouvé" });

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(400).json({ message: "Mot de passe incorrect" });

    // Chercher ve_id si role = VE
    let ve_id = null;
    if (user.role === "VE") {
      const [veRows] = await db.query("SELECT id FROM ve WHERE user_id = ?", [user.id]);
      if (veRows.length > 0) ve_id = veRows[0].id;
    }

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: "2h" });

    res.json({
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        ve_id
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// === ME ===
app.get("/me", authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.query("SELECT id, username, role FROM users WHERE id = ?", [req.user.id]);
    if (rows.length === 0) return res.status(404).json({ message: "Utilisateur introuvable" });

    const user = rows[0];

    let ve_id = null;
    if (user.role === "VE") {
      const [veRows] = await db.query("SELECT id FROM ve WHERE user_id = ?", [user.id]);
      if (veRows.length > 0) ve_id = veRows[0].id;
    }

    res.json({ user: { ...user, ve_id } });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// === VE ===
app.get("/ve", authenticateToken, async (req, res) => {
  try {
    let rows;

    if (req.user.role === "ADMIN") {
      [rows] = await db.query(`
        SELECT ve.id, ve.ve_code, ve.nom, ve.prenom, 
               vil.nom_village,
               u.username AS user_account,
               COUNT(DISTINCT c.id) AS nb_inscrits,
               IFNULL(SUM(p.montant), 0) AS total_paiements
        FROM ve ve
        LEFT JOIN villages vil ON ve.village_id = vil.id
        LEFT JOIN users u ON ve.user_id = u.id
        LEFT JOIN clients c ON c.ve_id = ve.id
        LEFT JOIN paiements p ON c.id = p.client_id
        GROUP BY ve.id, ve.ve_code, ve.nom, ve.prenom, vil.nom_village, u.username
      `);
    } else if (req.user.role === "USER" || req.user.role === "VE") {
      [rows] = await db.query(`
        SELECT ve.id, ve.ve_code, ve.nom, ve.prenom,
               vil.nom_village,
               u.username AS user_account,
               COUNT(DISTINCT c.id) AS nb_inscrits,
               IFNULL(SUM(p.montant), 0) AS total_paiements,
               CASE WHEN ve.id = ? THEN 1 ELSE 0 END AS is_active
        FROM ve ve
        LEFT JOIN villages vil ON ve.village_id = vil.id
        LEFT JOIN users u ON ve.user_id = u.id
        LEFT JOIN clients c ON c.ve_id = ve.id
        LEFT JOIN paiements p ON c.id = p.client_id
        GROUP BY ve.id, ve.ve_code, ve.nom, ve.prenom, vil.nom_village, u.username
      `, [req.user.ve_id]);
    } else {
      return res.status(403).json({ message: "Accès interdit" });
    }

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});
// === VE DETAILS ===
app.get("/ve/:id", authenticateToken, async (req, res) => {
  const requestedId = parseInt(req.params.id);
   const user = req.user;
  try {
    const [rows] = await db.query(
      `SELECT v.id, v.ve_code, v.nom, v.prenom, v.village_id,
              vil.nom_village
       FROM ve v
       LEFT JOIN villages vil ON vil.id = v.village_id
       WHERE v.id = ?`,
      [id]
    );
    if (rows.length === 0) return res.status(404).json({ message: "VE introuvable" });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
     if (user.role === "VE" && user.ve_id !== requestedId) {
    return res.status(403).send("Accès interdit");
  }
  }
});

// === CLIENTS ===
app.get("/clients/ve/:ve_id", authenticateToken, async (req, res) => {
  const { ve_id } = req.params;
  try {
    if (req.user.role === "USER" || req.user.role === "VE") {
      const [veCheck] = await db.query(
        "SELECT id FROM ve WHERE id = ? AND user_id = ?",
        [ve_id, req.user.id]
      );
      if (veCheck.length === 0)
        return res.status(403).json({ message: "Accès interdit" });
    }

    // 👉 ADMIN voit tout sans restriction
    const [rows] = await db.query(`
      SELECT 
  c.id, 
  c.client_code, 
  c.nom, 
  c.prenom, 
  c.telephone,
  v.nom_village, 
  DATE(c.date_inscription) AS date_inscription,  -- 👈 pareil ici
  SUM(p.montant) AS total_paiements
FROM clients c
LEFT JOIN villages v ON c.village_id = v.id
LEFT JOIN paiements p ON c.id = p.client_id
WHERE c.ve_id = ?
GROUP BY c.id, c.client_code, c.nom, c.prenom, c.telephone, v.nom_village, c.date_inscription
ORDER BY c.date_inscription DESC;
    `, [ve_id]);

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});
// === AJOUTER UN CLIENT ===
// === CREER CLIENT ===
app.post("/clients", authenticateToken, async (req, res) => {
  try {
    const { ve_id, nom, prenom, telephone, montant } = req.body;

    if (!ve_id || !nom || !prenom || !telephone) {
      return res.status(400).json({ message: "Champs manquants" });
    }

    // Si l'utilisateur est VE/USER: il ne peut créer que pour son VE
    if (req.user.role !== "ADMIN") {
      const [myVe] = await db.query(
        "SELECT id FROM ve WHERE user_id = ?",
        [req.user.id]
      );
      if (myVe.length === 0 || myVe[0].id !== Number(ve_id)) {
        return res.status(403).json({ message: "Accès interdit" });
      }
    }

    // Récupérer le village du VE (source de vérité)
    const [veRows] = await db.query(
      "SELECT id, village_id FROM ve WHERE id = ?",
      [ve_id]
    );
    if (veRows.length === 0) {
      return res.status(400).json({ message: "VE introuvable" });
    }
    const village_id = veRows[0].village_id;

    // Créer le client
    const client_code = `CL-${ve_id}-${Date.now()}`;
    const [insert] = await db.query(
      `INSERT INTO clients (client_code, nom, prenom, ve_id, village_id, date_inscription, telephone)
       VALUES (?, ?, ?, ?, ?, CURDATE(), ?)`,
      [client_code, nom, prenom, ve_id, village_id, telephone]
    );

    // Paiement initial optionnel
    if (montant && Number(montant) > 0) {
      await db.query(
        "INSERT INTO paiements (client_id, montant, date_paiement, user_id) VALUES (?, ?, NOW(), ?)",
        [insert.insertId, montant, req.user.id]
      );
    }

    res.json({ message: "Client créé", client_id: insert.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// === CLIENT DETAILS ===
app.get("/clients/:id", authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const [rows] = await db.query(`
      SELECT 
        c.id, 
        c.client_code, 
        c.nom, 
        c.prenom, 
        DATE(c.date_inscription) AS date_inscription,  -- 👈 formaté uniquement en date
        c.telephone,
        v.nom_village, 
        ve.ve_code, 
        ve.nom AS ve_nom, 
        ve.prenom AS ve_prenom
      FROM clients c
      LEFT JOIN villages v ON c.village_id = v.id
      LEFT JOIN ve ON c.ve_id = ve.id
      WHERE c.id = ?
      GROUP BY 
        c.id, c.client_code, c.nom, c.prenom, c.telephone, 
        v.nom_village, c.date_inscription, ve.ve_code, ve.nom, ve.prenom
      ORDER BY c.date_inscription DESC
    `, [id]);

    if (rows.length === 0) 
      return res.status(404).json({ message: "Client introuvable" });

    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

// === PAIEMENTS ===
app.post("/paiements", authenticateToken, requirePermission("manage_paiements"), async (req, res) => {
  const { client_id, montant, password } = req.body;
  try {
    const [rows] = await db.query("SELECT * FROM users WHERE id = ?", [req.user.id]);
    if (rows.length === 0) return res.status(400).json({ message: "Utilisateur introuvable" });

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match) return res.status(400).json({ message: "Mot de passe incorrect" });

    await db.query(
      "INSERT INTO paiements (client_id, montant, date_paiement, user_id) VALUES (?, ?, NOW(), ?)",
      [client_id, montant, req.user.id]
    );
    res.json({ message: "Paiement enregistré avec succès" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});

app.get("/paiements/client/:client_id", authenticateToken, async (req, res) => {
  const { client_id } = req.params;
  try {
    // Vérification pour VE ou USER : ils ne peuvent voir que leurs propres clients
    if (req.user.role !== "ADMIN") {
      const [check] = await db.query(
        `SELECT c.id
         FROM clients c
         JOIN ve ON c.ve_id = ve.id
         WHERE c.id = ? AND ve.user_id = ?`,
        [client_id, req.user.id]
      );

      if (check.length === 0) {
        return res.status(403).json({ message: "Accès interdit" });
      }
    }

    // ADMIN voit tout, VE/USER passent la vérification et accèdent à leurs clients
    const [rows] = await db.query(`
      SELECT c.client_code, c.nom AS client_nom, c.prenom AS client_prenom,
             v.nom_village, ve.ve_code,
             p.id AS paiement_id, p.montant, p.date_paiement,
             u.username AS payeur_username
      FROM clients c
      LEFT JOIN paiements p ON c.id = p.client_id
      LEFT JOIN villages v ON c.village_id = v.id
      LEFT JOIN ve ON c.ve_id = ve.id
      LEFT JOIN users u ON p.user_id = u.id
      WHERE c.id = ?
      ORDER BY p.date_paiement DESC
    `, [client_id]);

    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Erreur serveur" });
  }
});


// === START ===
const PORT = process.env.PORT || 5000;
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Serveur lancé sur port ${PORT}`);
});
