//Require the dev-dependencies
let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../app');
let should = chai.should();


chai.use(chaiHttp);
/*
  * Test the /GET route
  */
 /*
describe('/GET all-items', () => {
    it('it should GET an array of items', (done) => {
    chai.request(server)
        .get('/all-items')
        .end((err, res) => {
                res.should.have.status(200);
                res.body.should.be.a('array');
            done();
        });
    });
});*/