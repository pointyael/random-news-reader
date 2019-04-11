const rURL = require('../models/wordModel');
const expect = require('chai').expect;

describe("word model", () => {
    
    describe('"getRandomWord"', () => {
        it('should give a object not empty, containing a word, a frequence and a language id', function (done) {
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
    });
});