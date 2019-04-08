// Use python shell
let {PythonShell} = require('python-shell');
var url=require('url');

function getFeedLinks(rawUrl){
  return new Promise (function(resolve, reject){
    console.log('-------- RECHERCHE FLUX ---------');

    host = url.parse(rawUrl).hostname;

    console.log("Hôte : " + host);

    var options = {
        pythonPath: getPythonSystemPath(),
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

function getPythonSystemPath() {
    var pf;
    if(process.platform == "win32")
      pf =  'C:\\Python27\\python.exe';//process.env.PYPATHWIN;
    // else if another platform
    // pf = [Add your path in .env]
    else // for TRAVISCI
      pf = "python";//process.env.PYPATHTRA;

    return pf;
  }

module.exports = {
    getFeedLinks
}
