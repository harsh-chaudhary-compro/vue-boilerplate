# Inspired from https://stackoverflow.com/a/25515370/4556029
yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { "$@" || die "cannot $*"; }

# check if enough arguments are provided
if [ "$#" -lt 3 ]
then
   die "Atleast 3 arguments required, $# provided. 1st: Action, 2nd: Group, 3rd: Env."
else
   yell "Action: '$1', Environment Group: '$2', Environment: '$3'"
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

# Check if jq is present
if [ ! -x "$(command -v jq)" ];
then
  die "Error: jq is not installed. Check 'System Requirements' section in ReadMe"
fi

yell "------------------------------------------------"
# Read values from config file, also convert output to empty string instead of null if key doesn't exist
config_s3_bucket_name=`jq -r .s3.bucket_name//empty ${computed_file_path}`

# Ternary statement - https://stackoverflow.com/a/3953712/4556029
[ -z $config_s3_bucket_name ] && die "Required config 's3.bucket_name' Not Defined" || yell "s3.bucket_name = ${config_s3_bucket_name}"

yell "------------------------------------------------"

#Run command based on action provided
case $1 in
    'build')
        yell "Building application"

        sbuild="npm run build --prefix ./frontend/"

        try $sbuild
        ;;
    'deploy')
        yell "Deploying application"

        sdeploy="aws s3 cp ./frontend/dist/ s3://${config_s3_bucket_name} --recursive"

        try $sdeploy
        ;;
    *)
        die "Unsupported action: $1"
        ;;
esac