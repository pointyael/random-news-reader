var db = require("../database/dbFactory").db;

function getRandomWord() {
    return new Promise(function(resolve, reject){
        db.one('SELECT * FROM  (SELECT DISTINCT 1 + trunc(random() * 31434241)::integer AS mot_id FROM generate_series(1,1) g) r JOIN   mot USING (mot_id) LIMIT  1;').then(function (word) {
            resolve(word);
        }).catch(function (error) {
            reject(error);
        });
    });

}

module.exports = {
    getRandomWord
}