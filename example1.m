verify_latin_nr(@one_cycle);
post_process_verify
return

% timing and memory ...
tic;
main(0, @() one_cycle('latin'));
toc;
tic;
main(0, @() one_cycle('NR'));
toc;

% #!/bin/bash
% rm -rf output/*
% matlab -nodisplay -nodesktop -nosplash -r 'example1_compare; exit;'
% /usr/bin/time -o output/timing_nr.txt -v matlab -nodisplay -nodesktop -nosplash -r 'example1_nr; exit;'
% /usr/bin/time -o output/timing_pgd.txt -v matlab -nodisplay -nodesktop -nosplash -r 'example1_pgd; exit;'
