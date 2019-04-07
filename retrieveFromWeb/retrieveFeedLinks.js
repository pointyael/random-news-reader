// Use python shell
let {PythonShell} = require('python-shell');

function getFeedLinks(url, callback){
    var pyPath = getPythonSystemPath();
    var options = {
        pythonPath: pyPath,
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

function getPythonSystemPath() {
  var pf;
  if(process.platform == "win32")
    pf =  process.env.PYPATHWIN;
  // else if another platform
  // pf = [Add your path in .env]
  else // for TRAVISCI
    pf = process.env.PYPATHTRA;

  return pf;
}

module.exports = {
    getFeedLinks
}
