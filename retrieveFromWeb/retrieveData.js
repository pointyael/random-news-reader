let Parser = require('rss-parser');
const moment = require('moment');
let parser = new Parser();

/* use an URL to return parsed object containing feed infos and items */
async function _retrieveFeedData(link) {
    let parsedFeed = await parser.parseURL(link);
    return parsedFeed;
}

async function _processFeedInfo(parsedFeed){
    let feedSchema = Object();
    parsedFeed.title = parsedFeed.title.replace(/'/g, "''");
    feedSchema = {
        //id: parsedFeed.id,
        title: parsedFeed.title,
        link: parsedFeed.link
    };
    return feedSchema;
}


async function _processItems(parsedFeed){
    let itemArray = [];
    let itemSchema = Object();
    let dateMinusTwoDays = moment().add(-2, 'days').format("YYYY-MM-DD HH:mm:ss");

    parsedFeed.items.forEach(item => {
        item.title = item.title.replace(/'/g, "''");
        // Be careful --> content =/= description
        // In RSS the description field  is required instead of content
        item.description = item.content.replace(/'/g, "''");

        itemSchema = {
            title: item.title,
            description: item.description,
            //content: item.content,
            enclosure: item.enclosure ? item.enclosure.url : "",
            pubDate: item.pubDate,
            link: item.link,
            language: item.language,
            category: item.category
          }

        if
        (
          moment(item.ite_pubdate).format("YYYY-MM-DD HH:mm:ss")
          > dateMinusTwoDays
        )
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
    processedInfo = await _processFeedInfo(parsedFeed);
    return processedInfo;
}

module.exports = {
    getItems,
    getFeedData
}
