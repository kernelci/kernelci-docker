# Get admin token
ADMIN_TOKEN=${1:-$(cat .kernelci_token)}
echo $ADMIN_TOKEN

# Tet pickel file
FILEPATH=$PWD/test/raw_json.pkl

# Define additional variables
SERVER="http://127.0.0.1:8081"
LAB_NAME="lab-baylibre-$(date "+%Y%m%dT%H%M%S")"

# Create lab
result=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: $ADMIN_TOKEN" -d '{"version": "1.0", "name": "'${LAB_NAME}'", "contact": {"name": "Hilman", "surname": "Kevin", "email": "khilman@baylibre.com"}}' $SERVER/lab)

# Get token
TOKEN=$(echo $result | docker run -i --rm lucj/jq:1.0 -r '.result[0].token')

# Send a dummy job
python $PWD/test/send_job.py $TOKEN $LAB_NAME $SERVER $FILEPATH
