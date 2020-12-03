
const AWS = require('aws-sdk');

let options = {
  apiVersion: '2012-08-10',
  region: 'us-west-2',
}

if(process.env.AWS_SAM_LOCAL) {
 options.endpoint = 'http://192.168.1.159:8000';
}

const CODE_ENV = process.env.CODE_ENV;
const HELLO_WORLD_TABLE_NAME = process.env.HELLO_WORLD_TABLE_NAME;

const dynamoDB = new AWS.DynamoDB(options);

exports.handler = async (event, context) => {
    let env = process.env.CODE_ENV || "default";
    let name;
    let params = {};
    console.log("triggered");
    try {
      const resp = await dynamoDB.listTables(params).promise();
      console.log(resp);
      console.log("success");
    } catch (err) {
      console.log(err);
      console.log("failure");
    }

    if(event.queryStringParameters && event.queryStringParameters.name){
        name = event.queryStringParameters.name;
    }
    else{
        name = "World"
    }
    const body = `Hello ${name} from ${env} Environment`;
    return {
        'statusCode': 200,
        'body': body
    }
};
