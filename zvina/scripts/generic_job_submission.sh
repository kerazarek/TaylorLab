#BSUB -q hp12
#BSUB -n 1
#BSUB -J job_$(date "+%Y%m%d_%H%M%S")

echo "hello" > ~/test.txt 
