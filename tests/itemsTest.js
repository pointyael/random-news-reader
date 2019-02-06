const items = require('../cronScripts/items');
const expect = require('chai').expect;

const link = "https://www.reddit.com/r/ProgrammerHumor.rss";

var test = async function(link) {
    var feed = await items.retrieveItemsFromLink(link);
    var array = await items.feedToItemArray(feed);
    return array;
}

test(link).then(console.log);

/*
describe("items Cron script", () => {
    describe('"retrieveItemsFromLink"', () => {
        before(function*() {
            itemTable = items.retrieveItemsFromLink(link);

        });
        it('should be an object not empty', function * () {
            expect(itemTable).to.be.an('object').not.empty
        });
        it('each items should have a title, link, and description attribute not empty', function * () {
            itemTable.forEach(item => {
                expect(item.title).to.be.a('string').not.empty;
                expect(item.link).to.be.a('string').not.empty;
                expect(item.description).to.be.a('string').not.empty;
            });
        });
    })
})
*/

/*items.retrieveItemsFromLink("https://www.reddit.com/r/ProgrammerHumor.rss").then(
    items.readItems).catch(function(error){
        console.log(error)
    }
);*/