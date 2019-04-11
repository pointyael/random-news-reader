var db = require("../database/dbFactory").db;

/* Insert feed in data base */
const insertFeed = (feedToSave) => {
    return new Promise(function(resolve, reject) {
        db.none('INSERT INTO source (sou_link) VALUES(\'' + feedToSave + '\')')
        .then(function() { resolve(); })
        .catch(function (error) { reject(error); });
    });
}

module.exports = {
    insertFeed
}
