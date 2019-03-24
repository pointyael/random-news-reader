const moment = require('moment');
let ETypeMedia = {"article":1, "mp3": 2};
var parsedItem = {};

const aItem = (item) => {
  // Be careful --> content =/= description
  // In RSS the description field  is required instead of content
  parsedItem =
  {
      title: item.title.replace(/'/g, "''"),
      description: item.content ? item.content.replace(/'/g, "''") : "",
      pubDate: moment(item.pubDate).format("YYYY-MM-DD HH:mm:ss"),
      type : ETypeMedia.article,
      link: item.link,
      language: item.language,
      category: item.category
  };

  getEnclosure(item);

  if(parsedItem.enclosure && parsedItem.enclosure.endsWith(".mp3")){
      parsedItem.type = ETypeMedia.mp3;
  }
  return parsedItem;
}

const getEnclosure = (item) => {
  if(item['media:content']){
    parsedItem.enclosure = item['media:content'].$.url;
  } else if (item.image) {
    parsedItem.enclosure =
      Array.isArray(item.image.url)
        ?  item.image.url[0]
        : item.image.url;
  } else if (item.enclosure && item.enclosure.url.length > 0) {
    parsedItem.enclosure = item.enclosure.url;
  }
}

module.exports =
{
  aItem
};
