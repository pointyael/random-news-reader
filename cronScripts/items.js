let Parser = require('rss-parser');
let parser = new Parser();

var retrieveItemsFromLink = function(link) {
    let webFeed = await parser.parseURL(link);
}

var readItems = function(link) {
    webfeed.items.forEach(item => {
        console.log(item);
    });
}

module.exports = {
    retrieveItemsFromLink,
    readItems
}


// TODO : Chopper les items de tous les feeds de la table source et les enregistrer dans la table item