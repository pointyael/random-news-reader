var pgp = require("pg-promise")();
var items = require("../cronScripts/items");

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

/* Query 12 random items from data base */
const getRandomItems = (request, response) => {
    db.any("SELECT \"getRandomItems\"()")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

/* Insert items in data base */
const insertItems = (request, response) => {

    const feedInfo = JSON.stringify(items.getFeedInfosFromLink()) + "::json";
    const itemsInfo = JSON.stringify(items.getItemFromLink()) + "::json";

    db.any("CALL \"insertNewItems\"(feedInfo, itemsInfo)")
        .then(function (data) {
            console.log("DATA:", data);
            response.status(200).json(data);
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

module.exports = {
    getRandomItems,
    insertItems
}