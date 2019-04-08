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
    return new Promise(function(resolve, reject) {
        db.none('INSERT INTO source (sou_link) VALUES(${link})', {
            link: feedsToSave[i]
        })
        .then(function() {
            resolve();
        })
        .catch(function (error) {
            console.log("ERROR:", error);
            reject(error);
        });

    });  
}

module.exports = {
    insertFeed
}
