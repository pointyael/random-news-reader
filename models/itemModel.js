var pgp = require("pg-promise")();
var Items = require("../retrieveFromWeb/retrieveData.js");
var FeedModel = require("./feedModel");

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
    db.any("SELECT * FROM item ORDER BY RANDOM() LIMIT 12")
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

    db
    .any("SELECT * FROM source WHERE source.sou_id=2")
    .then(function (data) {
        data = data[0];
        feedInfo = {
            id: data.sou_id,
            title: data.sou_title,
            link: data.sou_link
        }
        feedInfoStringified = "'" + JSON.stringify(feedInfo).replace( /'/, "''") + "'::json";
        Items
        .getItems(data.sou_link)
        .then
        (
            function(res){
                itemsJsonString = (JSON.stringify(res));
                //console.log(res);
                db
                .any("CALL \"insertNewItems\"("+feedInfoStringified+", '"+itemsJsonString+"')")
                .then( () => response.status(200) )
                .catch(function (error2) {
                    console.log("ERROR3", error2);
                });
            }
        )
        .catch( function(err) { console.log("ERROR4 : ", err); })

        })
        .catch(function(err){ console.log("ERROR2:", err); });

}

module.exports = {
    getRandomItems,
    insertItems
}
