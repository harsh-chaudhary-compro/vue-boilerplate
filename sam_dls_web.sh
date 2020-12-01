# Inspired from https://stackoverflow.com/a/25515370/4556029
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# check if enough arguments are provided
if [ "$#" -ne 4 ]
then
   die "4 arguments required, $# provided"
else
   yell "Action: '$1', Realm: '$2', Env: '$3', Profile: '$4'"
fi

# Construct file path
computed_file_path="config/$2/$3/config.json"

# Check if config file exists
if [ -e $computed_file_path ]
then
    yell "Using config file: '$computed_file_path'"
else
    die "config file: '$computed_file_path' Not found"
fi

yell "Reading Parameters config file values"
yell "------------------------------------------------"
# Read values from config file, also convert output to empty string instead of null if key doesn't exist
config_app=`jq -r .app//empty ${computed_file_path}`
config_stack=`jq -r .webstack//empty ${computed_file_path}`
config_region=`jq -r .region//empty ${computed_file_path}`
config_s3_bucket_name=`jq -r .s3.bucket_name//empty ${computed_file_path}`
config_s3_bucket_prefix=`jq -r .s3.bucket_prefix//empty ${computed_file_path}`
config_s3_packaged_filename=`jq -r .s3.web_packaged_filename//empty ${computed_file_path}`
config_web_template_filename=`jq -r .s3.web_template//empty ${computed_file_path}`

# Ternary statement - https://stackoverflow.com/a/3953712/4556029
[ -z $config_app ] && die "Required config 'app' Not Defined" || yell "app = ${config_app}"
[ -z $config_stack ] && die "Required config 'webstack' Not Defined" || yell "stack = ${config_stack}"
[ -z $config_region ] && die "Required config 'region' Not Defined" || yell "region = ${config_region}" 
[ -z $config_s3_bucket_name ] && die "Required config 's3.bucket_name' Not Defined" || yell "s3.bucket_name = ${config_s3_bucket_name}"
[ -z $config_s3_bucket_prefix ] && die "Required config 's3.bucket_prefix' Not Defined" || yell "s3.bucket_prefix = ${config_s3_bucket_prefix}"
[ -z $config_s3_packaged_filename ] && die "Required config 's3.web_packaged_filename' Not Defined" || yell "s3.web_packaged_filename = ${config_s3_packaged_filename}"
[ -z $config_web_template_filename ] && die "Required config 's3.config_web_template_filename' Not Defined" || yell "s3.web_template = ${config_web_template_filename}"

yell "------------------------------------------------"
# Check if on linux or using bash from windows
# Reference: https://stackoverflow.com/a/8597411/4556029
if [ "$OSTYPE" == "msys" ] 
then
    yell "using bash on windows"
    scmd="sam.cmd"
else
    scmd="sam"
fi

#Run command based on action provided
case $1 in
    'build')
        yell "SAM: Validate template"
        svalidate="${scmd} validate --template ${config_web_template_filename}  --profile $4"
        try $svalidate
        
        yell "SAM: Building application"
        sbuild="${scmd} build --template ${config_web_template_filename}  --profile $4"
        try $sbuild
        ;;
    'package')
        yell "SAM: Packaging application"
        spackage="${scmd} package --template-file ${config_web_template_filename} --output-template-file ${config_s3_packaged_filename} --s3-bucket ${config_s3_bucket_name} --s3-prefix ${config_s3_bucket_prefix} --profile $4"
        try $spackage
        ;;
    'deploy')
        yell "SAM: Deploying application"
    
        sdeploy="${scmd} deploy --template-file ${config_s3_packaged_filename} --region ${config_region} --capabilities CAPABILITY_IAM --stack-name ${config_stack} --profile $4"

        #generate parameter string excluding the ones having value "SSM"
        config_parameters=`jq -r -j '.parameters | to_entries | map(select(.value != "SSM")) | map("\(.key)=\(.value|tostring) ") | join("")' ${computed_file_path}`

        # Check if parameter-overrides flag needs to be included or not
        if [ ! -z $config_parameters ]
        then
            sdeploy="${sdeploy} --parameter-overrides ${config_parameters}"
        fi

        try $sdeploy
        ;;
    *)
        die "Unsupported action: $1"
        ;;
esac