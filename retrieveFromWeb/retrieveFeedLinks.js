// Use python shell
let {PythonShell} = require('python-shell');

function getFeedLinks(url, callback){
  //console.log(process.env);
    var options = {
        pythonPath: process.platform != "win32" ? process.env.PYPATHLIX : process.env.PYPATHWIN,//'/bin/python2',
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
