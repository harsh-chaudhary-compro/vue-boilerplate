var AWS = require("aws-sdk");
let ENV = process.env.ENV;
let REGION = process.env.REGION;
let AWS_PROFILE = process.env.AWS_PROFILE;
let END_POINT = `https://dynamodb.${REGION}.amazonaws.com`;

if(ENV == "local") {
    let PORT = process.env.PORT;
    END_POINT = `http://localhost:${PORT}/`
}

var credentials = new AWS.SharedIniFileCredentials({profile: AWS_PROFILE});
AWS.config.credentials = credentials;

AWS.config.update({
    region: REGION,
    endpoint: END_POINT
});


let dynamoDB = new AWS.DynamoDB();
let dynamoDBClient = new AWS.DynamoDB.DocumentClient()

class databaseManager {
    
    async createTable(params) {
        return await dynamoDB
            .createTable(params)
            .promise()
            .then((result) => {
                return result;
            }, (error) => {
                throw error;
            });
    };
    
    async saveItem(params) {
        return await dynamoDBClient
            .put(params)
            .promise()
            .then((result) => {
                return result;
            }, (error) => {
                throw error;
            });
    }
}

module.exports = new databaseManager();