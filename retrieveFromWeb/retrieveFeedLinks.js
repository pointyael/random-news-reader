// Use python shell
let {PythonShell} = require('python-shell');

function getFeedLinks(url, callback){
  //console.log(process.env);
    var options = {
        pythonPath: process.platform != "win32" ? "python" : 'C:\\Python27\\python.exe',
                                               // "python3" : "py", if python 3 compatibility ok
        mode: 'text',
        scriptPath: 'retrieveFromWeb/feedvalidator',
        args: [url]
    };

    PythonShell.run('feedfinder.py', options, function (err, results) {
        if (err) throw err;
        if (results[0].length == 0 ) results = new Array();
        callback(results);
    });

}

module.exports = {
    getFeedLinks
}
