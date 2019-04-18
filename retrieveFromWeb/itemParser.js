const moment = require('moment');
var franc = require('franc');
let ETypeMedia = {"article":1, "mp3": 2};
var parsedItem = {};

const aItem = (item) => {
  // Be careful --> content =/= description
  // In RSS the description field  is required instead of content

  parsedItem =
  {
      title: item.title.replace(/'/g, "''"),
      type : ETypeMedia.article,
      link: item.link,
      //category: item.category
      // unused field
  };

  getDate(item);
  getEnclosure(item);
  getDescription(item);
  getLanguage(item);

  if(parsedItem.enclosure && parsedItem.enclosure.endsWith(".mp3")){
      parsedItem.type = ETypeMedia.mp3;
  }
  return parsedItem;
}

const getDate = (item) => {

  if (item.isoDate)
    parsedItem.pubDate =  moment(item.isoDate).format("YYYY-MM-DD HH:mm:ss");
  else
    parsedItem.pubDate =  moment(item.pubDate).format("YYYY-MM-DD HH:mm:ss");
}

const getLanguage = (item) => {
  var resultTitle = franc.all(parsedItem.title)[0],
      resultDescription = franc.all(parsedItem.description)[0];

  if(resultTitle[0] == resultDescription[0] || resultTitle[1] >= resultDescription[1])
    parsedItem.language = resultTitle[0].substring(0, 2);
  else
    parsedItem.language = resultDescription[0].substring(0, 2);

}

const getEnclosure = (item) => {
  if(item['media:content']){
    parsedItem.enclosure = item['media:content'].$.url;
  } else if (item.image) {
    parsedItem.enclosure =
      Array.isArray(item.image.url)
        ?  item.image.url[0]
        : item.image.url;
  } else if (item.enclosure && item.enclosure.url) {
    parsedItem.enclosure = item.enclosure.url;
  } else {
    analyseContent(item);
  }
}

const analyseContent = (item) => {

  var enclosureHead =
    item.description && item.description.split(/img src="/)[1]
    || item.content &&  item.content.split(/img src="/)[1];

  if( enclosureHead ) {
    parsedItem.enclosure = enclosureHead.split(/"/)[0];
  }
}

const getDescription = (item) => {
  var descriptionSplitted =
  item.description && item.description.split(/(<a href.*">|<\/a>|<\/?p>|<img .*"\/?>)/g)
  || item.content &&  item.content.split(/(<a href.*">|<\/a>|<\/?p>|<img .*"\/?>)/g);


  if(descriptionSplitted) {
    descriptionSplitted.forEach(ds => {
      if(!(ds.match(/(<a href=".*">|<\/a>|\/?p>|img)/g) ) ) {
        if(ds.length >=5)
          parsedItem.description = ds.replace(/'/g, "''");
      }
    });
  }
}

module.exports =
{
  aItem
};
