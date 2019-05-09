#!/bin/bash

# -cwd means to execute the job for the current working directory.
# -j y means to merge the standard error stream into the standard output stream instead of having two separate files
# -S /bin/bash specifies the interpreting shell for this job to be the Bash shell.
# -V imports current environment variables (path, libraries, etc.) to the new shell
# qsub -v par_name=par_value[,par_name=par_value...] script.sh

# run like: ./run_cluster.sh fusion
# workstation='fusion' #luh_login # hertz gnode70 master chassagne luh_transfer
workstation=$1

mode='push'   # 0:push     1:pull

folder="random_loading" #_$(date +"%Y%m%d_%H%M%S")"

if [[ $mode == 'push' ]]; then
  if [[ $workstation == 'luh_login' ]]; then
    echo "luh_login"
    rsync --stats -Pavi --delete --force --delete-excluded --exclude 'output/*' --exclude '.*' --exclude '*.mat' ~/src/romfem/ $workstation:/home/nhgdalma/$folder
    ssh $workstation "cd /home/nhgdalma/$folder && qsub -v folder=$folder toolboxes/run_scripts/luh_romfem.sh"
  elif [[ $workstation == 'fusion' ]]; then
    echo 'fusion'
    rsync --stats -Pavi --delete --force --delete-excluded --exclude 'output/*' --exclude '.*' --exclude '*.mat' ~/src/romfem/ $workstation:/home/alameddin/$folder
    ssh $workstation "cd /home/alameddin/$folder && qsub -v folder=$folder toolboxes/run_scripts/lmt_romfem.sh"
    # ssh -o BatchMode=no $workstation "cd /workdir/alameddin/$folder && qsub -v folder=$folder toolboxes/run_scripts/fusion_romfem.sh"
  else
    echo "not implemented"
  fi
else
    echo "careful don't delete all files here"
    # rsync --stats -Pavi --exclude '.*' --delete $workstation:~/romfem/output/ ~/Desktop/output
fi

# nohup 2>/dev/null &
# nohup matlab-r2017b -nodisplay -nodesktop -nosplash -r 'main; exit;' </dev/null >/dev/null 2>&1 &

# scp -r username@fusion.centralesupelec.fr:/home/username/my_dir .
