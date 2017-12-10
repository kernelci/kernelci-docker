import json
import yaml
import sys
import datetime
import re
import getopt
import glob
import logging
import os
import time
import ntpath

# Load job data from json file
def load_job(input_file):
  job_data = None
  try:
    fp = open(input_file, 'r')
    job_data = json.load(fp)
  except Exception as e:
    logging.error('Cannot load file %s', input_file)
    sys.exit(1)
  return job_data

# Build unique ID from "id" and "submit_time"
def build_id(job_data):
  id = job_data["id"]
  submit_time = job_data["submit_time"][0:19].replace('-','').replace(':','').replace(' ','T')
  log_id = '{}-{}'.format(id, submit_time)
  return log_id

# Get metadata used to supercharge log entries
def get_metadata(job_data):
  # Get metadata
  metadata = yaml.load(job_data["definition"], Loader=yaml.Loader)["metadata"]

  # Get lab name
  lab_name = "unknown"
  if "notify" in job_data["definition"]:
    notify = yaml.load(job_data["definition"], Loader=yaml.Loader)["notify"]
    if "callback" in notify:
      callback_url = notify["callback"]["url"]
      m = re.search("lab_name=([\w-]+)", callback_url)
      if m:
        lab_name = m.group(1)

  # Get unique id
  log_id = build_id(job_data)

  # Set metadata
  meta = {
         "id"            : log_id,
         "tree"          : metadata["kernel.tree"],
         "branch"        : metadata["git.branch"],
         "kernel"        : metadata["kernel.version"],
         "arch"          : metadata["job.arch"],
         "defconfig"     : metadata["kernel.defconfig"],
         "platform_name" : metadata["platform.name"],
         "platform_mach" : metadata["platform.mach"],
         "lab_name"      : lab_name,
  }
  return meta

# Generate output file
def parse_input_file(input_file, output):
  # Rename input file during the processing
  input_file_tmp = '{}-tmp'.format(input_file)
  os.rename(input_file, input_file_tmp)

  # Generate name of the output file
  output_file = "{}/{}-{}.log".format(output, ntpath.basename(input_file), datetime.datetime.now().strftime("%Y%m%dT%H%M%S"))

  # Load content of input file
  job_data = load_job(input_file_tmp)

  # Get logs from job data
  logs_str = job_data["log"].replace("!!python/object/apply:collections.OrderedDict","").replace("!!python/unicode","").replace('! "','"')
  logs_list = yaml.load(logs_str, Loader=yaml.Loader)

  # Get metadata
  meta = get_metadata(job_data)

  # Add medadata to each log entry
  with open(output_file, "w") as fp:
    for log in logs_list:
      if log == '':
        continue
      log.update(meta)
      json.dump(log, fp)
      fp.write('\n')

  # Flag current file as done
  input_file_done = '{}-done'.format(input_file)
  os.rename(input_file_tmp, input_file_done)

  logging.info("=> log file %s generated", output_file)

# Process files
def process_files(input, output):
    # Get json files to process
    input_files = glob.glob('{}/*.json'.format(input))
    logging.info('%s - %d files to process in %s', datetime.datetime.now().strftime("%Y%m%dT%H%M%S"), len(input_files), input)

    # Loop through the list of files
    for input_file in input_files:
      logging.info('-> processing file %s', input_file)

      # Parse input file 
      parse_input_file(input_file, output)

# How this script must be used
def usage():
  print("python raw2json.py [--in INPUT_FOLDER] [--out OUTPUT_FOLDER] [--period SEC]")

# Check params and run main process
def main():
    # input and output folders default in the current directory
    input = '.'
    output = '.'
    period = 10

    # Parse options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hi:o:p:", ["help", "input=", "output="])
    except getopt.GetoptError as err:
        logging.error(err)
        usage()
        sys.exit(2)
    for o, a in opts:
        if o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-i", "--input"):
            input = a
        elif o in ("-o", "--output"):
            output = a
        elif o in ("-p", "--period"):
            period = float(a)
        else:
            assert False, "unhandled option"

    while True:
        process_files(input, output)
        time.sleep(period)

if __name__ == "__main__":
  logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.DEBUG)
  logging.info('Started')
  main()
