// Use python shell
let {PythonShell} = require('python-shell');

function getFeedLinks(url, callback){

    var options = {
        pythonPath: '/bin/python2',
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
