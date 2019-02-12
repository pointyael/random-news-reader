const itemRetrieving = require('../retrieveFromWeb/retrieveData');
const expect = require('chai').expect;

require('it-each')({ testPerIteration: true });

const link = "https://www.bfmtv.com/rss/info/flux-rss/flux-toutes-les-actualites/";

describe("items Cron script", () => {
    let parsedFeed;
    let feedInfo;

    describe('"getItems"', () => {
        before(async function () {
            let items = await itemRetrieving.getItems(link);
        });
        it('should be an object not empty', function () {
            expect(items).to.be.an('object').not.empty;
        });
        it('should have at least title and a link not empty', function () {
            expect(items.title).to.be.a('String').not.empty;
            expect(items.link).to.be.a('String').not.empty;
        });
    });
/*
    describe('"Items"', () => {
        let items;
        before(async function () {
            items = await itemRetrieving.getItems(link);
        });

        it('should be an array not empty', function () {
            expect(items).to.be.an('array').not.empty;
        });

        // Marche pas 
        it.each(items, 'items should have a title and a link not empty', ['item'], function(item, next){
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

    describe('"getItems"', () => {
        before(async function () {
            items = await itemRetrieving.getItems();
        });
        it('should be an array not empty', function () {
            expect(feedInfo).to.be.an('array').not.empty;
        });
    });*/
});