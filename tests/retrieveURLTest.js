const rURL = require('../retrieveFromWeb/retrieveURL');
const expect = require('chai').expect;


function isURL(str) {
    var urlRegex = '^(?!mailto:)(?:(?:http|https)://)(?:\\S+(?::\\S*)?@)?(?:(?:(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[0-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))|localhost)(?::\\d{2,5})?(?:(/|\\?|#)[^\\s]*)?$';
    var url = new RegExp(urlRegex, 'i');
    return str.length < 2083 && url.test(str);
}

describe("retrieveURL Cron script", () => {

    // Cannot be tested on travis for the moment

    /*describe('"getRandomWord"', () => {
        it('should give a object not empty, containing a word, a frequence and a language id', function (done) {
            // Test when website contains an RSS
            rURL.getRandomWord().then(word => {
                expect(word).to.be.an('Object').not.empty;
                expect(word.mot_lib).to.be.a('String').not.null;
                expect(word.mot_lang).to.be.a('number').not.null;
                expect(word.mot_freq).to.be.a('number').not.null;
                done();
            }).catch(err => {
                done(err);
            });
        });
    });*/
    
    describe('"getSearchResult and processResult"', () => {
        it('processResult should give an URL', function (done) {
            var word = {mot_lib:"test", mot_lang:"1", mot_freq:"3224"};
            rURL.getSearchResult(word).then(searchResult => {
                expect(searchResult).to.be.an('object');
                return rURL.processSearchResults(searchResult);
            }).then(URL => {
                expect(isURL(URL)).to.be.true;
                done();
            }).catch(err =>{
                done(err)
            });
        });
        
    });
});
    