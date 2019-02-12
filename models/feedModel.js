var pgp = require("pg-promise")();
const cn = {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASS
};

var db = pgp(cn);

/*
CREATE TABLE public.source (
    sou_id integer NOT NULL,
    sou_name character varying(30),
    sou_link character varying(250)
);
*/

let link;
let name;

/* Query source with id 1 to test items insert */
const getSource = () => {
    db.one("SELECT * FROM source WHERE source.sou_id = 1")
        .then(function (data) {
            console.log("DATA:", data);
            return data;
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
}

module.exports = {
    getSource
}