﻿# AWS Serverless Seed
This is a seed app using the AWS Serverless architecture for DLS Apps. It uses AWS SAM as the underlying tool for managing developer workflow and related deployments. For understanding and more information about SAM, Refer https://aws.amazon.com/serverless/sam/

## Getting Started

### 1. AWS Account and S3 Bucket for SAM
You will need an AWS account to use and work with this seed app. There are two key requirements:

* An S3 Bucket for SAM - which the SAM CLI will use to host lambda packages (code) prior to deployment to AWS. 
* An IAM user mapped to a group with appropriate permissions to S3 bucket, AWS Lambda, DynamoDB and AWS Cloudformation.

Note: Replace `<ENV>` with the deploying environment value. Possible environment values: `{dev, qa, staging, prod}`

For a quick start, create a S3 bucket called `dls-compro-<ENV>-sam-seed-<YOUR-USERNAME>` in the same AWS region in which stack is to be deployed.

Create the following deploy policy `dls-compro-<ENV>-sam-seed-deploy-policy` and add below json configuration.

```

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaFunctionManagement",
            "Effect": "Allow",
            "Action": [
                "lambda:*"
            ],
            "Resource": [
                "arn:aws:lambda:*:*:function:dls-compro-<ENV>-sam-seed-*"
            ]
        },
        {
            "Sid": "RolesForLambda",
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::*:role/dls_compro_lambda_<ENV>_role"
            ]
        },
        {
            "Sid": "lambdaS3CodeHosting",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration",
                "s3:DeleteObject",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "arn:aws:s3:::dls-compro-<ENV>-sam-seed-<YOUR-USERNAME>",
                "arn:aws:s3:::dls-compro-<ENV>-sam-seed-<YOUR-USERNAME>/*"
            ]
        },
        {
            "Sid": "CloudformationCRUDForSAMDev",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "APIGatewayAllow",
            "Effect": "Allow",
            "Action": [
                "apigateway:*"
            ],
            "Resource": "arn:aws:apigateway:<YOUR-REGION>::*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:DescribeTable",
                "dynamodb:CreateTable",
                "dynamodb:DeleteTable",
                "dynamodb:PutItem",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:UpdateTimeToLive"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/dls-compro-<ENV>-sam-seed-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        },
        {
            "Sid": "lambdaLayerAllow",
            "Effect": "Allow",
            "Action": [
                "lambda:PublishLayerVersion",
                "lambda:GetLayerVersion"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Schedular",
            "Effect": "Allow",
            "Action": [
                "events:PutRule",
                "events:DescribeRule",
                "events:PutTargets",
                "events:RemoveTargets",
                "events:DeleteRule"
            ],
            "Resource": "arn:aws:events:*:*:rule/dls-compro-<ENV>-sam-seed-*"
        }
    ]
}
```

Create group in IAM for the environment `dls-compro-<ENV>-sam-seed-deploy-group` and attach
`dls-compro-<ENV>-sam-seed-deploy-policy` policy.

Create the following `dls_compro_lambda_dynamo_access_<ENV>_policy` customer managed policy: 

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:Delete*",
                "dynamodb:Update*",
                "dynamodb:PutItem",
                "dynamodb:DescribeTimeToLive"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/dls-compro-<ENV>-sam-seed-*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
```

Create following `dls_compro_lambda_<ENV>_role` role for lambda and add the below mentioned policies.

* AWSLambdaBasicExecutionRole - AWS Managed
* AWSLambdaRole - AWS Managed
* dls_compro_lambda_dynamo_access_<ENV>_policy - Customer Managed   /*`referenced above.`*/

### 2. Setup Aws config on local machine
Download AWS CLI: https://aws.amazon.com/cli/

Create IAM user on aws and attach `dls-compro-<ENV>-sam-seed-deploy-policy` group. 

Configure CLI using `aws configure --profile <AWS_PROFILE_NAME>` and fill IAM user credentials

```
AWS Access Key ID [None]: YOUR IAM USER's ACCESS KEY ID

AWS Secret Access Key [None]: YOUR IAM USER's SECRET ACCESS KEY

Default region name [None]: us-west-2

Default output format [None]: json
```

### 3. System Requirements and Cloning the Repository

Before proceeding in this section, your local development machine would need to have the following 

- OS
    - Ubuntu Linux (preferred), OR
    - Windows 10 Pro - Requires additional programs supporting Bash scripts for e.g. Git Bash, WSL(ubuntu) etc.
- GIT CLI - To clone this repository
- AWS CLI - Pre-requisite for SAM CLI
- SAM CLI - To build, package and deploy the application on AWS
- JQ - Used to read config json, Can be installed from [here](https://stedolan.github.io/jq/download/) and should be in system PATH
- Docker - To invoke Lambda functions locally

#### CLONE the Repository
```bash
# Clone the Repo
git clone https://gitlab.com/comprodls/sam-seed.git

# Change directory
cd sam-seed
```

### 4. Configuration Files

Configurations related to SAM application are placed in `config` folder at the root directory. Config files are organised into Realms, e.g. `compro`.
For each Realm, config files are organized into different environments supported by Realm, e.g. for `compro`, different environments currently are - `dev`, `stage`, `qa`, `prod`. 

Configuration related to serverless application are present in `config.json`. Following fields are present in each config file
* app - Name of the application, e.g. 'sam-seed'. This name will be used to construct a stack name.
* stack - Name of Cloud Formation Stack, e.g. 'dls-compro-sam-seed'.
* region - AWS Region in which stack will be deployed, e.g. 'us-west-2'
* s3 - Configurations related to AWS S3
   * bucket_name - The name of the S3 bucket where this command uploads the artifacts that are referenced in your template., e.g. 'dls-compro-dev-sam-seed' 
   * bucket_prefix - A prefix name that the command adds to the artifacts name when it uploads them to the S3 bucket. The prefix name is a path name (folder name) for the S3 bucket., e.g. 'sam'
   * packaged_filename - The path to the file where the command writes the output AWS CloudFormation template., e.g. 'packaged.yaml'
* parameters - Key values map of the overridden parameters passed while deploying application
   * Environment - "dev" / "qa" / "stage" / "prod"

### 5. Build, Packaging and Deploying the Sample implementation

**Windows Users** - Following steps involve running a shell script - You need to use **Git Bash** for that if installed or other similar program (default windows CMD and Powershell will not work)

**Bash Script Arguments** - Bash script will expect 4 arguments for following listed command
   * action - Supported actions are - 'build', 'package' and 'deploy'. Details are in following sections
   * realm - Realm for which application is to be built.
   * Environment - Name of environment in the realm for which application is to be build
   * Profile - Name of aws credentials profile for which credentials need to be used.

For the given Realm and Environment, there must be a configuration file present as explained in section above

#### BUILD

NOTE:- Run `npm install` in /dependencies/nodejs to install all lamda dependencies.

```bash
./sam_dls.sh build compro dev <AWS_PROFILE_NAME>
``` 
This  build command will first validate the template and then compile dependencies for Lambda functions. It will create a folder named `.aws-sam` in the root directory containing build artifacts that you can deploy to Lambda using the package and deploy commands.

#### PACKAGE
```bash
./sam_dls.sh package compro dev <AWS_PROFILE_NAME>
```
This package command zips your code artifacts, uploads them to Amazon S3, and produces a packaged AWS SAM template file that's ready to be used. The above command generates a packaged.yaml file

#### DEPLOY
```bash 
./sam_dls.sh deploy compro dev <AWS_PROFILE_NAME>
```
This command uses the package file to deploy your application in the region mentioned in config file with stack name generated using combination of realm, environment and application name.

### 6. Invoking Resources Locally (via CLI)

##### Invoke API Gateway on AWS
To invoke deployed API Gateway endpoints, 
* Go to AWS Console -> API Gateway -> "AWS Serverless API" -> Stages
* Select the deployed stage / environment for e.g. 'dev' and navigate to "/" -> "/hello" -> "Get"
* Click the Invoke URL - to get the response from 'HelloWorldFunction' Lambda function

##### Invoke API Gateway Locally
To run the API Gateway locally, System needs to have ```Docker``` (Docker Desktop for Windows) installed and running. 
```bash
sam local start-api
```
It will start local http server at port 3000. For example Refer sample output below:
```bash
Mounting HelloWorldFunction at http://127.0.0.1:3000/hello [GET]
Mounting ExchangeRateFunction at http://127.0.0.1:3000/exchange [POST]
```

##### Invoke Lambda function on AWS
```bash
aws lambda invoke --function-name <function-name> output.txt
``` 
"function-name" can have either the name or ARN of the deployed Lambda function - Refer AWS console for the same.

##### Invoke Lambda function Locally

To run the lambda functions locally, System needs to have ```Docker``` (Docker Desktop for Windows) installed and running. 
```bash
sam local invoke HelloWorldFunction
```
Mock Event Data can also be passed to the lambda function
```bash
sam local invoke HelloWorldFunction --event functions/hello-world/tests/event.json
```

### 7. Invoking and Debugging Resources Locally (via Visual Studio Code) 

1. Install **Aws Toolkit** plugin for Visual Studio Code
2. Navigate to cmd and cxecute command `sam.cmd local generate-event apigateway aws-proxy | clip`. This will copy event object in clipboard
3. Locate the "exports.handler" for your Lambda function
4. Notice code-lenses taht appear above your Lambda `Run Locally | Debug Locally | Configure`
5. Click on `Configure`
6. Paste this object against property `event: `
7. Now click on `Debug Locally` in the Code Lense of your Lambda function

**Note**: There is limitation in AWS toolkit that lambda handler name should be different for each lambda funtion (https://github.com/aws/aws-toolkit-vscode/issues/912)

### 8. Setup dynamoDB for Local Debugging

#### a. Setup Dynamo DB using docker 

1. Pull docker image https://hub.docker.com/r/amazon/dynamodb-local/ - Execute Command - ```docker pull amazon/dynamodb-local```
2. Run docker
```
docker run -p 8000:8000 amazon/dynamodb-local
```
#### b. Infate seed data into dynamoDB

1. Install aws-sdk dependency
```
npm install
```

2. Inflate data into dynamoDB
```
AWS_PROFILE="sam-seed-p" npm run-script <ENV>
```
Possible ENV values: `{local, dev, qa, staging, prod}`

#### c. Integrate dynamoDB with lambda

1. Initialize DynamoDB

```
const AWS = require('aws-sdk');

let options = {
  apiVersion: '2012-08-10',
  region: 'us-west-2',
}

if(process.env.AWS_SAM_LOCAL) {
 options.endpoint = 'http://`<YOUR_IP_ADDRESS>`:8042';
}

const dynamoDB = new AWS.DynamoDB(options);

```
2. Call dynamoDB inside lambda function

```
let params = {};
try {
  const resp = await dynamoDB.listTables(params).promise();
  console.log(resp);
} catch (err) {
  console.log(err);
}
```


## Project Structure
```
├───template.yaml               # SAM Template
├───swagger.yaml                # Swagger File for API Gateway definition
├───config                      # Folder holding configuration files
│   └───compro                         # Folder representing DLS Realm
│       └───qa                          # Folder representing Environment
│           └───config.json                 # Config json file having sam configuration
├───functions                   # Contains source code for Lambda functions
│   └───hello-world             # Contains Sample Lambda function
│       └───index.js                # Main JS file containing Lambda Handler
│       └───package.json            # Standard NPM package.json for dependencies and other metadata
│           └───event.json          # Mock event data for Lambda function
```

### Sample Functions
#### FUNCTION: HelloWorldFunction
This function expects a name and returns a string concatenating Hello and name string. For Example, Following is a sample event
```
{
   "name":"John"
}
```
With this event, function will return output `Hello John`. In case no event is passed or name key is not present in the event object, then Function will return `Hello World` String

#### FUNCTION: ExchangeRateFunction
This function provides exchange rate of a currency with respect to another currency. It expects two currency codes. Following is a sample event
```
{
    "base": "USD",
    "target": "INR"
}
```
It will provide a conversion rate of USD to INR. Following is the output
```
{ rate: 71.281168, updated: '2020-01-30' }
```
 
### Sample API Gateway Resources
API Resources are defined in OpenAPI definition in `swagger.yaml` file present in root folder and imported in `template.yaml`
#### GET /hello
This endpoint invokes the `HelloWorldFunction` Lambda function. The end point also can accept a query string parameter `name`
```
curl -sb --request GET 'http://localhost:3000/hello?name=John'
```
With this query parameter, API will return status code 200 with output `Hello John`. In case no query string is passed `Hello World` String will be returned
 
#### POST /exchange
This endpoint invokes the `ExchangeRateFunction` Lambda function. The End point expect data passed as POST Body
```
curl -sb --request POST 'http://localhost:3000/exchange' --header 'Content-Type: application/json' --data '{"base": "USD","target": "INR"}'
```
It will return 200 status and output will be conversion rate of USD to INR. Following is the output
```
{ rate: 71.281168, updated: '2020-01-30' }
```

### Guidelines for adding New Functions
Follow the below steps to add a New Function

 - Create a New Folder under `/functions` similar to existing function
 - Update the code in `handler` function in the `hello-world.js` file in newly created folder
 - Add the resource to `template.yaml` file under `Resources` node
 - Build and Deploy the application
 
## Viewing in AWS Console
To View created application in AWS Console, Visit [https://console.aws.amazon.com/lambda/home](https://console.aws.amazon.com/lambda/home)

The created application will show up in the list. On clicking the application, we can see the created resources i.e. `SeedApiGateway` API Gateway and 2 lambda functions i.e. `HelloWorldFunction` and `ExchangeRateFunction` in our case. 

On clicking API gateway resource, you will be redirected to API gateway page where all the created resources (e.g. GET, POST) will be visible and can be tested. On clicking any function, you will land up at the lambda function page which can be tested by using the Test button by providing mock data.
