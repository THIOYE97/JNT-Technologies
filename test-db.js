import pkg from 'pg';
import dotenv from 'dotenv';
dotenv.config();

const { Client } = pkg;

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function test() {
  try {
    await client.connect();
    console.log("✅ Connexion réussie à Supabase !");
    const res = await client.query('SELECT NOW()');
    console.log("🕒 Heure du serveur :", res.rows[0].now);
  } catch (err) {
    console.error("❌ Erreur de connexion :", err);
  } finally {
    await client.end();
  }
}

test();
