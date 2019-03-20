let Parser = require('rss-parser');
let parser = new Parser();

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
