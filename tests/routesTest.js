//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../app');
let should = chai.should();


chai.use(chaiHttp);
/*
  * Test the /GET route
  */

describe('/GET random-items', () => {
    it('it should GET an array of items', (done) => {
    chai.request(server)
        .get('/random-items')
        .end((err, res) => {
                res.should.have.status(200);
                res.body.should.be.a('array');
                items = res.body[0].getRandomItems;
                items.forEach(item => {
                    console.log(item);
                    item.ite_title.should.be.a('string').not.empty;
                });
            done();
        });
    });
});