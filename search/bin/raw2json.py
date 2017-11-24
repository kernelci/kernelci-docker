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
 
# Get metadata
metadata = job_data["metadata"]
if len(metadata) != 0:
  metadata = {i:j for x in job_data["metadata"] for i,j in x.items()}
else:
  metadata = yaml.load(job_data["definition"], Loader=yaml.Loader)["metadata"]

# Filter metadata that should be used to label each log entry
meta = {
         "tree"      : metadata["kernel.tree"],
         "branch"    : metadata["git.branch"],
         "kernel"    : metadata["kernel.version"],
         "arch"      : metadata["job.arch"],
         "defconfig" : metadata["kernel.defconfig"]
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

print("File {} generated".format(ntpath.basename(output)))
print("Ready to be copied to the input folder of the Elastic stack")
