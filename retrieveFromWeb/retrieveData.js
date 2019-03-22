let Parser = require('rss-parser');
let parser = new Parser({
  customFields: {
    item: [
      ['image', 'image'],
      ['media:content', 'media:content']
    ]
  }
});
const moment = require('moment');

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

        itemSchema = parseItem(item);

        if
        (
          moment(itemSchema.pubDate).format("YYYY-MM-DD HH:mm:ss")
          > dateMinusTwoDays
        )
          itemArray.push(itemSchema);
    });

    return itemArray;
}

function parseItem(item) {

  // Be careful --> content =/= description
  // In RSS the description field  is required instead of content
  var parsedItem =
  {
      title: item.title.replace(/'/g, "''"),
      description: item.content ? item.content.replace(/'/g, "''") : "",
      pubDate: moment(item.pubDate).format("YYYY-MM-DD HH:mm:ss"),
      link: item.link,
      language: item.language,
      category: item.category
  };

  if(item['media:content']){
    parsedItem.enclosure = item['media:content'].$.url;
  } else if (item.image) {
    parsedItem.enclosure = item.image.url;
  } else if (item.enclosure) {
    parsedItem.enclosure = item.enclosure.url;
  }
  
  return parsedItem;
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
    getFeedData,
    parseItem
}
