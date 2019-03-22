const itemRetrieving = require('../retrieveFromWeb/retrieveData');
const expect = require('chai').expect;

require('it-each')({ testPerIteration: true });

const link = "http://www.linternaute.com/rss/";

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

    describe('"Items" from one link : linternaute.com/rss/', () => {
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


});
