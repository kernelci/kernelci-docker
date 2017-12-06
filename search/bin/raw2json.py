import json
import yaml
import sys
import datetime
import ntpath

# Load JSON file
input  = None
output = None

# Load json input file
try:
  input = sys.argv[1]
  fp = open(input, 'r')
  job_data = json.load(fp)
except Exception as e:
  print("Error loading input file. Make sure file exists and is in json.")
  sys.exit(1)

# Check if output file is provided
try:
  output = sys.argv[2]
except Exception:
  output = "/log/log-{}.log".format(datetime.datetime.now().strftime("%Y%m%dT%H%M%S"))
 
# Build unique ID form "id" and "submit_time"
# submit_time:
# -> original format: "2017-11-20 14:02:54.528630+00:00"
# -> parsed format: "20171120T140254"
id = job_data["id"]
submit_time = job_data["submit_time"][0:19].replace('-','').replace(':','').replace(' ','T')
log_id = '{}-{}'.format(id, submit_time)

# Get metadata
metadata = yaml.load(job_data["definition"], Loader=yaml.Loader)["metadata"]

# Filter metadata that should be used to label each log entry
# and add id field
meta = {
         "id"            : log_id,
         "tree"          : metadata["kernel.tree"],
         "branch"        : metadata["git.branch"],
         "kernel"        : metadata["kernel.version"],
         "arch"          : metadata["job.arch"],
         "defconfig"     : metadata["kernel.defconfig"],
         "platform_name" : metadata["platform.name"],
         "platform_mach" : metadata["platform.mach"]
       }

# Get logs
logs_str = job_data["log"].replace("!!python/object/apply:collections.OrderedDict","").replace("!!python/unicode","").replace('! "','"')
logs_list = yaml.load(logs_str, Loader=yaml.Loader)

# Add medadata to each log entry
with open(output, "w") as fp:
  for log in logs_list:
    if log == '':
      continue
    log.update(meta)
    json.dump(log, fp)
    fp.write('\n')

print("File {} generated and ready to be copied to the Elastic stack".format(ntpath.basename(output)))
