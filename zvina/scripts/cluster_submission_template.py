import time, datetime
from constants import *

class Timestamp():
	def __init__(self):
		time_obj = time.time()
		output = datetime.datetime.fromtimestamp(time_obj)
		self.display = output.strftime('%Y-%m-%d %H:%M:%S')
		self.eightdigit = output.strftime('%Y%m%d')
		self.twelvedigit = output.strftime('%Y%m%d%H%M')

template = (
	"#BSUB -q hp12\n"
	"#BSUB -n 1\n"
	"#BSUB -N\n"
	"#BSUB -o {base}/submission_logs/{job_name}_{time.eightdigit}.txt\n"
	"#BSUB -J {job_name}\n"
	"\n"
	"# Cluster job submission for job:\n"
	"\t{JOB}\n"
	"\t(submission script created {time.display})\n"
	"\n"
	"# Parameters"
	"job_start_time=$(date \"+%Y%m%d%H%M%S\")\n"
	"printf '\\n~~~> {JOB} started %s' \"$job_start_time\"\n"
	"\n"
	"{COMMAND}\n"
	"\n"
	"job_end_time=$(date \"+%Y%m%d%H%M%S\")\n"
	"printf '\\n\\n---> {JOB} finished %s\\n' \"$job_start_time\"\n"
	"\n"
	"job_duration=$(bc <<< \"$job_end_time - $vina_start_time\")\n"
	"printf '\\n---> {JOB} took %s seconds \\n\\n' \"$job_duration\"\n"
)

template = template.format(
	base = cluster_base_dir,
	time = Timestamp(),
	job_name = '{job_name}',
	JOB = '{JOB}',
	COMMAND = '{COMMAND}'
)


# job_name = "my_awesome_job"
# JOB = "Performing a super cool job on the cluster"
# COMMAND = "echo hello\necho goodbye"
#
#
# template_filled = template.format(
# 							   job_name = job_name,
# 							   JOB = JOB,
# 							   COMMAND = COMMAND
# 						   )
# print(template_filled)