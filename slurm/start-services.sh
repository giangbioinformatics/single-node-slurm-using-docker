/etc/init.d/munge start
service mysql start
/usr/sbin/sshd
service slurmdbd restart
service slurmctld restart
service slurmd restart
sleep 5
sacctmgr -i add cluster localcluster
sleep 5
sbatch --wrap="sleep 3"
sleep 5 
lines=$(sacct --jobs 2|wc -l)
if [ $lines -eq 2 ]
    echo "Fail slurmdbd"
    exit 1
fi