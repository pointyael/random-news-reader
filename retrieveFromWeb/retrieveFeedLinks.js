// Use python shell
let {PythonShell} = require('python-shell');

function getWebsiteUrl(word) {

}

function getFeedLinks(url, callback){

    var options = {
        mode: 'text',
        scriptPath: 'retrieveFromWeb/feedvalidator',
        args: [url]
    };

    PythonShell.run('feedfinder.py', options, function (err, results) {
        if (err) throw err;
        // results is an array consisting of messages collected during execution
        callback(results);
    });
}

module.exports = {
    getFeedLinks
}
