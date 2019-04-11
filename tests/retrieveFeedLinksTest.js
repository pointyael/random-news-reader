const feedLinksRetrieving = require('../retrieveFromWeb/retrieveFeedLinks');
const expect = require('chai').expect;

require('it-each')({ testPerIteration: true });

const linkWithRss = "http://www.linternaute.com/";

const linkWithoutRss = "http://www.9gag.com/";

const linkMultipleRss = "https://www.lepoint.fr/";

describe("retrieveFeedLinks Cron script", () => {
    describe('"getFeedLinks"', () => {
        it('linternaute.com should give an array not empty', function (done) {
            // Test when website contains an RSS
            feedLinksRetrieving.getFeedLinks(linkWithRss)
            .then( function(feedLinks){
                expect(feedLinks).to.be.an('array').not.empty;
                done();
            })
            .catch((err) => done(err));
        });

        it('9gag.com should give an empty array', function (done) {
            // Test when website don't contains RSS
            feedLinksRetrieving.getFeedLinks(linkWithoutRss)
            .then( function(feedLinks){
                expect(feedLinks).to.be.an('array').empty;
                done();
            })
            .catch( (err) => done(err));
        });

        it('lepoint.fr should give an array of 15 RSS feeds', function (done) {
            // Test when website contains multiple RSS feeds
            feedLinksRetrieving.getFeedLinks(linkMultipleRss)
            .then(function(feedLinks){
                expect(feedLinks).to.have.lengthOf(15);
                done();
            })
            .catch((err) => done(err));
        });
    });
});
