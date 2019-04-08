var db = require("../database/dbFactory").db;

/*
CREATE TABLE public.source (
    sou_id integer NOT NULL,
    sou_name character varying(30),
    sou_link character varying(250)
);
*/

let link;
let name;

/* Insert feed in data base */
const insertFeed = (feedsToSave) => {
    for (let i = 0; i < feedsToSave.length; i++) {
        db.none('INSERT INTO source (sou_link) VALUES(${link})', {
            link: feedsToSave[i]
        })
        .catch(function (error) {
            console.log("ERROR:", error);
        });
    }
}

module.exports = {
    insertFeed
}
