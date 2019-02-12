let Parser = require('rss-parser');
let parser = new Parser();

/* use an URL to return parsed object containing feed infos and items */
async function _retrieveFeedData(link) {
    let parsedFeed = await parser.parseURL(link);
    return parsedFeed;
}

async function _processFeedInfo(parsedFeed){
    let feedSchema = Object();
    feedSchema = {
        id: parsedFeed.id,
        title: parsedFeed.title,
        link: parsedFeed.link
    }
    return feedSchema;
}


async function _processItems(parsedFeed){
    let itemArray = [];
    let itemSchema = Object();
    parsedFeed.items.forEach(item => {
        var regex = 
        item.title = item.title.replace(/'/g, "''");
        // Be careful --> content =/= description 
        // In RSS the description field  is required instead of content
        item.description = item.content.replace(/'/g, "''");
        itemSchema = {
            title: item.title,
            description: item.description,
            //content: item.content,
            enclosure: item.enclosure,
            datePub: item.datePub,
            link: item.link,
            language: item.language,
            category: item.category
          }
          itemArray.push(itemSchema);
    });
    return itemArray;
}

async function getItems(link) {
    parsedFeed = await _retrieveFeedData(link);
    return await _processItems(parsedFeed);
}

async function getFeedData(link) {
    parsedFeed = await _retrieveFeedData(link);
    return await _processFeedInfo(parsedFeed);
}

module.exports = {
    getItems,
    getFeedData
}