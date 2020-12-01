'use strict';

const lambda = require('../index.js');
const chai = require('chai');
const expect = chai.expect;

describe('Exchange Rate Function', function () {
    it('response is returned', async () => {
        let event = {
            "base": "USD",
            "target": "EUR"
        }
        const result = await lambda.handler(event, context)

        expect(result).to.be.an('object');
        expect(result.error).to.be.undefined;
    });

    it('return error if parameter not passed', async () => {
        let event = {
        }
        const result = await lambda.handler(event, context)

        expect(result).to.be.an('object');
        expect(result.error).to.exist;
        expect(result.rate).to.be.undefined;
    });

    it('verify correct data is returned', async () => {
        let event = require('./event.json');
        const result = await lambda.handler(event, context)

        expect(result).to.be.an('object');
        expect(result.rate).to.be.greaterThan(1);
    });
});
