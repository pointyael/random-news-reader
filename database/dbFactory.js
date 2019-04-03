const { Client } = require('pg');
const pgp = require("pg-promise")();

const db = pgp({
  user: "postgres",
  password: "md5244af1e2823d5eaeeffc42c5096d8260",
  database: "randomizer",
  port: 5432,
  host:"localhost",
  connectionString: "postgres://postgres:md5244af1e2823d5eaeeffc42c5096d8260@localhost:5432/randomizer"
});

// const client = new Client({
//   user: process.env.DB_USER,
//   password: process.env.DB_PASS,
//   database: process.env.DB_NAME,
//   port: process.env.DB_PORT,
//   host: process.env.DB_HOST,
// });

//const db = pgp(client);

module.exports = { db };
