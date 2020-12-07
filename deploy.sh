# Inspired from https://stackoverflow.com/a/25515370/4556029
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# check if enough arguments are provided
if [ "$#" -lt 3 ]
then
   die "Atleast 3 arguments required, $# provided. 1st: Action, 2nd: Group, 3rd: Env, 4th: Profile"
else
   yell "Action: '$1', Environment Group: '$2', Environment: '$3', profile: '$4'"
fi

# Construct file path
computed_file_path="config/$2/$3/sam.config.json"

# Check if config file exists
if [ -e $computed_file_path ]
then
    yell "Using config file: '$computed_file_path'"
else
    die "config file: '$computed_file_path' Not found"
fi

yell "Reading Parameters config file values"

# Check if jq is present
if [ ! -x "$(command -v jq)" ];
then
  die "Error: jq is not installed. Check 'System Requirements' section in ReadMe"
fi

yell "------------------------------------------------"
# Read values from config file, also convert output to empty string instead of null if key doesn't exist
config_app=`jq -r .app//empty ${computed_file_path}`
config_region=`jq -r .region//empty ${computed_file_path}`
config_s3_bucket_name=`jq -r .sam_s3.bucket_name//empty ${computed_file_path}`
config_s3_bucket_prefix=`jq -r .sam_s3.bucket_prefix//empty ${computed_file_path}`

# Ternary statement - https://stackoverflow.com/a/3953712/4556029
[ -z $config_app ] && die "Required config 'app' Not Defined" || yell "app = ${config_app}"
[ -z $config_region ] && die "Required config 'region' Not Defined" || yell "region = ${config_region}" 
[ -z $config_s3_bucket_name ] && die "Required config 'sam_s3.bucket_name' Not Defined" || yell "sam_s3.bucket_name = ${config_s3_bucket_name}"
[ -z $config_s3_bucket_prefix ] && die "Required config 'sam_s3.bucket_prefix' Not Defined" || yell "sam_s3.bucket_prefix = ${config_s3_bucket_prefix}"

yell "------------------------------------------------"

# Set up variables to be used in commands
var_capabilties="CAPABILITY_IAM"

# Check if on linux or using bash from windows
# Reference: https://stackoverflow.com/a/8597411/4556029
if [ "$OSTYPE" = "msys" ] 
then
    yell "using bash on windows"
    scmd="sam.cmd"
else
    scmd="sam"
fi

# AWS profile
if [ -z "$4" ]
then
  var_common_params=""
else
  yell "Using AWS profile: $4"
  var_common_params="--profile $4"
fi

#Run command based on action provided
case $1 in
    'build')
        yell "SAM: Validate template"
        svalidate="${scmd} validate ${var_common_params}"
        try $svalidate
        
        yell "SAM: Building application"
        sbuild="${scmd} build ${var_common_params}"
        try $sbuild
        ;;
    'package')
        yell "SAM Package is not required. Execute SAM Deploy, it implicitly performs the functionality of sam package also."
        ;;
    'deploy')
        yell "SAM: Deploying application"
        
        # Construct Stack name appending env at the end
        computed_stack_name="cup-$2-$3-${config_app}"
        yell "Creating Stack: ${computed_stack_name}"
        
        sdeploy="${scmd} deploy --s3-bucket ${config_s3_bucket_name} --s3-prefix ${config_s3_bucket_prefix} --region ${config_region} --capabilities ${var_capabilties} --stack-name ${computed_stack_name} ${var_common_params}"

        #generate parameter string excluding the ones having value "SSM"
        config_parameters=`jq -r -j '.parameters | to_entries | map(select(.value != "SSM")) | map("\(.key)=\(.value|tostring) ") | join("")' ${computed_file_path}`

        #additional params from script 
        script_parameters="Environment=${3}"

        #combined params to be passed to template 
        deploy_parameters="${config_parameters}${script_parameters}"

        sdeploy="${sdeploy} --parameter-overrides ${deploy_parameters}"

        try $sdeploy
        ;;
    *)
        die "Unsupported action: $1"
        ;;
esac