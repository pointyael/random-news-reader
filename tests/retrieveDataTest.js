const itemRetrieving = require('../retrieveFromWeb/retrieveData');
const expect = require('chai').expect;

require('it-each')({ testPerIteration: true });

const link = "http://www.linternaute.com/rss/";
const linkLibe = "http://rss.liberation.fr/rss/9/";

describe("items Cron script", () => {
    describe('"getFeedData" from one link : linternaute.com/rss/', () => {
        it(
          'should be an object containing title and a link not empty',
          async function ()
          {
            let feedData = await itemRetrieving.getFeedData(link);
            expect(feedData).to.be.an('object').not.empty;
            expect(feedData.title).to.be.a('String').not.empty;
            expect(feedData.link).to.be.a('String').not.empty;
          }
        );
    });

    describe('"getItems" from one link : linternaute.com/rss/', () => {
        var items;
        before(async function(){
            items = await itemRetrieving.getItems(link);
        });
        it('getItems return should be an array not empty', async function(){
            expect(items).to.be.an('array').not.empty;
        });

        it('items should have a title and a link not empty', async function(){
            items.forEach(item => {
                expect(item.title).to.be.a('string').not.empty;
                expect(item.link).to.be.a('string').not.empty;
            });
        });
    });

    describe('"getItems" from one link : rss.liberation.fr/rss/9/', () => {
        var items;
        before(async function(){
            items = await itemRetrieving.getItems(linkLibe);
        });
        it('getItems return should be an array not empty', async function(){
            expect(items).to.be.an('array').not.empty;
        });

        it('items should have an enclosure not empty too', async function(){
            items.forEach(item => {
                expect(item.title).to.be.a('string').not.empty;
                expect(item.link).to.be.a('string').not.empty;
                //expect(item.enclosure).to.be.a('string').not.empty;
            });
        });
    });



  describe('"parseItem" from one item :: Test on multiples items', () =>
  {
    var item1, itemB;
    // TO MOVE INTO JSON FILE
    var itemToParseA =
    {
        creator: 'La Rédaction',
        title:
         'Ramadan 2019 : tout savoir sur le mois de jeûne musulman et sa date',
        link:
         'https://www.linternaute.com/actualite/societe/1380387-ramadan-2019-tout-savoir-sur-le-mois-de-jeune-musulman-et-sa-date/',
        pubDate: 'Fri, 22 Mar 2019 12:51:00 +0100',
        enclosure:
         { url:
            'https://img-4.linternaute.com/RD9yq-zK2hdJI3wdL9hqFipzbig=/1280x/smart/edf2160bd6144eb0b666819ae4e6c15f/ccmcms-linternaute/11089280.jpg',
           type: 'image/jpeg',
           length: '90656' },
        'dc:creator': 'La Rédaction',
        content:
         '<a href="https://www.linternaute.com/actualite/societe/1380387-ramadan-2019-tout-savoir-sur-le-mois-de-jeune-musulman-et-sa-date/"><img src="https://img-4.linternaute.com/RD9yq-zK2hdJI3wdL9hqFipzbig=/1280x/smart/edf2160bd6144eb0b666819ae4e6c15f/ccmcms-linternaute/11089280.jpg" align="left" hspace="5" vspace="0"></a>DATE DE DEBUT RAMADAN - Quelle est la date du ramadan 2019 dans le calendrier musulman ? Pourquoi le début du ramadan avance chaque année dans notre calendrier grégorien ? Pour tout savoir, rendez-vous dans cette page spéciale !',
        contentSnippet:
         'DATE DE DEBUT RAMADAN - Quelle est la date du ramadan 2019 dans le calendrier musulman ? Pourquoi le début du ramadan avance chaque année dans notre calendrier grégorien ? Pour tout savoir, rendez-vous dans cette page spéciale !',
        guid:
         'https://www.linternaute.com/actualite/societe/1380387-ramadan-2019-tout-savoir-sur-le-mois-de-jeune-musulman-et-sa-date/',
        isoDate: '2019-03-22T11:51:00.000Z',
        description:
         '<a href="https://www.linternaute.com/actualite/societe/1380387-ramadan-2019-tout-savoir-sur-le-mois-de-jeune-musulman-et-sa-date/"><img src="https://img-4.linternaute.com/RD9yq-zK2hdJI3wdL9hqFipzbig=/1280x/smart/edf2160bd6144eb0b666819ae4e6c15f/ccmcms-linternaute/11089280.jpg" align="left" hspace="5" vspace="0"></a>DATE DE DEBUT RAMADAN - Quelle est la date du ramadan 2019 dans le calendrier musulman ? Pourquoi le début du ramadan avance chaque année dans notre calendrier grégorien ? Pour tout savoir, rendez-vous dans cette page spéciale !'
    },
    itemToParseB =
    {
      creator: 'Edwy Plenel',
      title:
       'Loi sur le renseignement ou Patrioct Act: qui surveillera les surveillants?',
      link:
       'https://www.mediapart.fr/studio/podcasts/chronique/loi-sur-le-renseignement-ou-patrioct-act-qui-surveillera-les-surveillants',
      pubDate: 'Thu, 11 Jun 2015 11:57:44 +0200',
      enclosure:
       { url:
          'http://static.mediapart.fr/files/audio/13194-11.06.2015-ITEMA_20765462-0.mp3',
         length: '6449280',
         type: 'audio/mpeg' },
      'dc:creator': 'Edwy Plenel',
      content:
       'Le Monde selon Edwy Plenel, tous les jeudi matin sur France Culture.',
      contentSnippet:
       'Le Monde selon Edwy Plenel, tous les jeudi matin sur France Culture.',
      guid: '540867 at https://www.mediapart.fr/',
      categories: [ { _: 'Loi renseignement', '$': [Object] } ],
      isoDate: '2015-06-11T09:57:44.000Z',
      itunes:
       { author: 'Edwy Plenel',
         subtitle:
          'Loi sur le renseignement ou Patrioct Act : qui surveillera les surveillants ?',
         summary:
          'Le Monde selon Edwy Plenel, tous les jeudi matin sur France Culture.',
         duration: '6:12',
         keywords: 'Loi renseignement,' },
      description:
       'Le Monde selon Edwy Plenel, tous les jeudi matin sur France Culture.'
    };

    before(function()
    {
      itemA = itemRetrieving.parseItem(itemToParseA);
      itemB = itemRetrieving.parseItem(itemToParseB);
    });
    it('items must be parsed and not null', function() {
      expect(itemA).to.be.a('object').not.empty;
      expect(itemB).to.be.a('object').not.empty;
    });
    it('itemA must have an enclosure with type "article"', function() {
      expect(itemA.title).to.be.a('string').not.empty;
      expect(itemA.link).to.be.a('string').not.empty;
      expect(itemA.enclosure).to.be.a('string').not.empty;
      expect(itemA.type === 1).to.be.true;
    });
    it('itemB must have an enclosure with type "mp3"', function() {
      expect(itemB.title).to.be.a('string').not.empty;
      expect(itemB.link).to.be.a('string').not.empty;
      expect(itemB.enclosure).to.be.a('string').not.empty;
      expect(itemB.type == 2).to.be.true;
    });
  });

});
