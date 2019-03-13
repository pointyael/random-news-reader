let Parser = require('rss-parser');
let parser = new Parser();

<<<<<<< HEAD
// TODO : Utiliser un API pour chopper un maximum de feeds pour remplir la table source de la BDD
=======
function getFeedLinks(url, callback){

    var options = {
        mode: 'text',
        scriptPath: 'retrieveFromWeb/feedvalidator',
        args: [url]
    };

    PythonShell.run('feedfinder.py', options, function (err, results) {
        if (err) throw err;
        callback(results);
    });
}

module.exports = {
    getFeedLinks
}
>>>>>>> 98a9bd6... fonctionnel
