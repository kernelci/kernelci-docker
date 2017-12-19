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

# copied from lava-server/lava_scheduler_app/models.py
SUBMITTED = 0
RUNNING = 1
COMPLETE = 2
INCOMPLETE = 3
CANCELED = 4
CANCELING = 5

LAVA_JOB_RESULT = {
    COMPLETE: "PASS",
    INCOMPLETE: "FAIL",
    CANCELED: "CANCELED",
}

JOBDATA_MAP = {
    "boot_log_html": "boot_log_html",
    "lab_name"     : "lab_name",
    "json_version" : "version",
}

METADATA_MAP = {
    "arch"         : "job.arch",
    "branch"       : "git.branch",
    "defconfig"    : "kernel.defconfig",
    "kernel"       : "kernel.version",
    "platform_mach": "platform.mach",
    "platform_name": "platform.name",
    "tree"         : "kernel.tree",
}

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
    id = job_data.get("id")
    submit_time = job_data.get("submit_time")[0:19].replace('-', '').replace(':', '').replace(' ', 'T')
    log_id = '{}-{}'.format(submit_time, id)
    return log_id


# Get metadata used to supercharge log entries
def get_metadata(job_data):
    # Get metadata
    metadata = yaml.load(job_data["definition"], Loader=yaml.Loader)["metadata"]

    meta = {}

    # Set metadata from KernelCI backend json file
    for x, y in METADATA_MAP.items():
        try:
            meta.update({x: metadata[y]})
        except (KeyError) as ex:
            logging.warning("Metadata field {} missing in the job metadata result.".format(ex))

    # Look for metadata elsewhere from KernelCI backend json file
    for x, y in JOBDATA_MAP.items():
        try:
            meta.update({x: job_data[y]})
        except (KeyError) as ex:
            logging.warning("Metadata field {} missing in the job data result.".format(ex))

    # Add extra metadata logic, this should be kept to minimum
    # Get unique id
    meta["id"] = build_id(job_data)

    # Get job status from LAVA
    meta["status"] = LAVA_JOB_RESULT[job_data["status"]]

    # Create an url to the KernelCI log
    # Eventually this could be replaced by some logic in kCI backend
    if meta.get("lab_name") == "lab-baylibre-legacy":
        url_base = "http://storage.dev.baylibre.com/"
        url_base += meta.get("tree") + "/" + meta.get("branch") + "/" + meta.get("kernel") + "/"
        url_base += meta.get("arch") + "/" + meta.get("defconfig") + "/" + meta.get("lab_name") + "/"
        meta["log_url"] = url_base + str(meta.get("boot_log_html"))

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
    logs_str = job_data["log"].replace("!!python/object/apply:collections.OrderedDict", "").replace("!!python/unicode", "").replace('! "', '"')
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
