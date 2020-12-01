const databaseManager = require('./databaseManager');
let ENV = process.env.ENV;
const EXCHANGE_TABLE_NAME = `dls-compro-${ENV}-sam-seed-ExchangeRateTable`;

class DatabaseSeed {
  async inflateData() {
    /*
      Create tables when in local env
    */
    if(ENV == 'local') {
      await databaseManager.createTable({
        TableName: EXCHANGE_TABLE_NAME,
        KeySchema: [
          { AttributeName: "partition_key", KeyType: "HASH" },
          { AttributeName: "sort_key", KeyType: "RANGE" }
        ],
        AttributeDefinitions: [
          { AttributeName: "partition_key", AttributeType: "S" },
          { AttributeName: "sort_key", AttributeType: "S" }
        ],
        BillingMode: "PAY_PER_REQUEST"
      }).then(response => {
          console.log(response);
          console.log(EXCHANGE_TABLE_NAME + "added successfully.")
        }, (reject) => {
          console.log(reject);
        }); 
    }

    /*
      Fill seed data into tables
    */
    await databaseManager.saveItem({
      TableName: EXCHANGE_TABLE_NAME,
      Item: {
        partition_key: "partition_key",
        sort_key: "sort_key",
        name: "exchange-item"
      }
    }).then(response => {
        console.log(response);
        console.log("partition_key added successfully.")
      }, (reject) => {
        console.log(reject);
      });
  }
}

const databaseSeed = new DatabaseSeed();
databaseSeed.inflateData();
