const moment = require('moment');
const LanguageDetect = require('languagedetect');
const lngDetector = new LanguageDetect();
let ETypeMedia = {"article":1, "mp3": 2};
var parsedItem = {};

const aItem = (item) => {
  // Be careful --> content =/= description
  // In RSS the description field  is required instead of content

  parsedItem =
  {
      title: item.title.replace(/'/g, "''"),
      pubDate: moment(item.pubDate).format("YYYY-MM-DD HH:mm:ss"),
      type : ETypeMedia.article,
      link: item.link,
      category: item.category
  };

  getEnclosure(item);
  getDescription(item);
  getLanguage(item);

  if(parsedItem.enclosure && parsedItem.enclosure.endsWith(".mp3")){
      parsedItem.type = ETypeMedia.mp3;
  }
  return parsedItem;
}

const getLanguage = (item) => {
  var resultTitle = lngDetector.detect(parsedItem.title);

  if (resultTitle && resultTitle[0][1] >= 0.275) {
    parsedItem.language = resultTitle[0][0];
  } else if (parsedItem.description) {
    var resultDescription =  lngDetector.detect(parsedItem.description);

      if(resultDescription && resultDescription[0][1] >= 0.25) {
        parsedItem.language = resultDescription[0][0];
      } else if (resultTitle[0][0] == resultDescription[0][0]) {
        parsedItem.languge = resultTitle[0][0];
      } else {
        parsedItem.language = parsedItem.link.split(/www\W\w*\W/)[1].split(/\//)[0];
      }
  }
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
  item.description && item.description.split(/<(a href|\/a>|img .* \/>)/)
  || item.content &&  item.content.split(/<(a href|\/a>|img .* \/>)/);


  if(descriptionSplitted) {
    descriptionSplitted.forEach(ds => {
      if(!(ds.match(/<(a href|\/a>|img .* \/>)/g) ) ) {
        parsedItem.description = ds.replace(/'/g, "''");
      }
    });
  }
}

module.exports =
{
  aItem
};
