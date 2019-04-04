// Use python shell
let {PythonShell} = require('python-shell');

function getFeedLinks(url, callback){
  console.log(process.platform);
    var options = {
        pythonPath: process.platform != "win32" ? "python3" : "py", //'/bin/python2',
        mode: 'text',
        scriptPath: 'retrieveFromWeb/feedvalidator',
        args: [url]
    };

    PythonShell.run('feedfinder.py', options, function (err, results) {
        if (err) { console.log(err); throw err; }
        callback(results);
    });
    console.log(PythonShell.getVersionSync());
}

module.exports = {
    getFeedLinks
}
