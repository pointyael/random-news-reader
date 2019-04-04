// Use python shell
let {PythonShell} = require('python-shell');
var url=require('url');

function getFeedLinks(rawUrl, callback){

    return new Promise (function(resolve, reject){

        console.log('-------- RECHERCHE FLUX ---------');

        host = url.parse(rawUrl).hostname;

        console.log("Hôte : " + host);
        var options = {
            pythonPath: '/bin/python2',
            mode: 'text',
            scriptPath: 'retrieveFromWeb/feedvalidator',
            args: [host]
        };

        PythonShell.run('feedfinder.py', options, function (err, results) {
            if (err) reject(err);
            resolve(results);
        });
    });
}

module.exports = {
    getFeedLinks
}
