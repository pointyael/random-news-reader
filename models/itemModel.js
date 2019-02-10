var pgp = require("pg-promise")();

const cn = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASS
};

const db = pgp(cn);

/*
ite_id integer NOT NULL,
    ite_name character varying(250),
    ite_description character varying(400),
    ite_type integer,
    ite_link character varying(250),
    ite_dateinsert date,
    ite_language integer,
    ite_theme integer,
ite_source integer
*/

let name;
let description;
let type;
let dateInsert;
let language;
let theme;

/* Query items from data base */
const getAllItems = (request, response) => {
    db.any("SELECT * FROM item")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

/* Query 12 random items from data base */
const getRandomItems = (request, response) => {
    db.any("SELECT * FROM item ORDER BY RANDOM() LIMIT 12")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

module.exports = {
    getAllItems,
    getRandomItems
}