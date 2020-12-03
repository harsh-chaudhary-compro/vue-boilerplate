'use strict';

const lambda = require('../index.js');
const chai = require('chai');
const expect = chai.expect;
var event = {}, context;

describe('Test Hello World Lambda', function () {
    it('verifies hello world is default output', async () => {
        const result = await lambda.handler(event, context)

        expect(result).to.be.an('string');
        expect(result).to.be.equal("Hello World");
    });

    describe('verifies passed name is present in output', function () {
        it('Pass event as inline object', async () => {
            const event = {"name":"Lambda"};
            const result = await lambda.handler(event, context)
    
            expect(result).to.be.an('string');
            expect(result).to.be.equal("Hello Lambda");
        });
    
        it('Pass event from external json file', async () => {
            const event = require('./event.json')
            const result = await lambda.handler(event, context)
    
            expect(result).to.be.an('string');
            expect(result).to.be.equal("Hello Event");
        });
    });
});
