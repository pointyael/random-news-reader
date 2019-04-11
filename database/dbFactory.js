const { Client } = require('pg');
const pgp = require("pg-promise")();
require('dotenv').config();

const connectionString = process.env.DB_USER + '://' + process.env.DB_USER + ':' +  process.env.DB_PASS + '@' + process.env.DB_HOST + ':' + process.env.DB_PORT + '/' + process.env.DB_NAME ;

const db = pgp(connectionString);

module.exports = { db };
