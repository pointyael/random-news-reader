let Parser = require('rss-parser');
let parser = new Parser();

async function retrieveItemsFromLink(link) {
    let webFeed = parser.parseURL(link);
    return webFeed;
}

async function getFeedInfo(feed){
    let feedSchema = Object();
    feedSchema = {
        title: feed.title,
        description: feed.description,
        link: feed.link,
        language: feed.language,
        category: feed.category
    }
    return feedSchema;
}

async function feedToItemArray(feed){
    let itemArray = [];
    let itemSchema = Object();
    feed.items.forEach(item => {
        itemSchema = {
            title: item.title,
            description: item.description,
            type: item.type,
            datePub: item.datePub,
            link: item.link,
            language: item.language,
            category: item.category
          }
          itemArray.push(itemSchema);
    });
    return itemArray;
}
async function normalize(items) {

}

module.exports = {
    retrieveItemsFromLink,
    feedToItemArray
}


// TODO : Chopper les items de tous les feeds de la table source et les enregistrer dans la table item