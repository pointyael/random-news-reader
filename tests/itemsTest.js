const itemRetrieving = require('../cronScripts/items');
const expect = require('chai').expect;

require('it-each')({ testPerIteration: true });

const link = "https://www.reddit.com/r/ProgrammerHumor.rss";

describe("items Cron script", () => {
    let parsedFeed;
    let feedInfo;

    describe('"getFeedInfo"', () => {
        before(async function () {
            parsedFeed = await itemRetrieving.retrieveItemsFromLink(link);
            feedInfo = await itemRetrieving.getFeedInfo(parsedFeed);
        });
        it('should be an object not empty', function () {
            expect(feedInfo).to.be.an('object').not.empty;
        });
        it('should have at least title and a link not empty', function () {
            expect(feedInfo.title).to.be.a('String').not.empty;
            expect(feedInfo.link).to.be.a('String').not.empty;
        });
    });

    describe('"Items"', () => {
        let items;
        before(async function () {
            parsedFeed = await itemRetrieving.retrieveItemsFromLink(link);
            items = await itemRetrieving.feedToArray(parsedFeed);
        });    

        it('should be an object not empty', function () {
            expect(items).to.be.an('array').not.empty;
        });

        // Marche pas
        it.each(items,'items should have a title and a link not empty', function(item, next){
            console.log(item);
            expect(item.title).to.be.a('string').not.empty;
            expect(item.link).to.be.a('string').not.empty;
        });
    });

    describe('"retrieveItemsFromLink"', () => {
        before(async function () {
            parsedFeed = await itemRetrieving.retrieveItemsFromLink(link);
        });
        it('should be an object not empty', function () {
            expect(parsedFeed).to.be.an('object').not.empty;
        });
    });
});