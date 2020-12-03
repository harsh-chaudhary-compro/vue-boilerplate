const axios = require('axios');
const apiURL = 'https://api.exchangerate-api.com/v4/latest';


async function getConversionRate(base, target){
    const fetchURL = `${apiURL}/${base}`;
    try{
        const apiResult = await axios.get(fetchURL);

        const conversionResult = apiResult.data; 
        // console.log(conversionResult)
        const rate = conversionResult.rates[target];
        const updated = conversionResult.date;
        return {
            rate,
            updated
        }
    }
    catch(e){
        // console.log(e)
        return {
            "error": "API Error"
        }
    }
}


exports.handler = async (event, context) => {
    if(!event.body){
        return {
            'statusCode': 400,
            'body': 'Request Body Empty'
        }
    }

    let {base, target} = JSON.parse(event.body);
    if(!base || !target){
        return {
            'statusCode': 400,
            'body': 'Check parameters paased in Request Body'
        }
    }
    
    const conversionRate = await getConversionRate(base, target);
    return {
        'statusCode': 200,
        'body': JSON.stringify(conversionRate)
    }
};


