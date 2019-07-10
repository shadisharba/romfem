verify_latin_nr(@input_verify);
post_process_verify
return

% /usr/bin/time -o output/timing_nr.txt -v matlab -nodisplay -nodesktop -nosplash -r 'main(0, @() input_verify('latin')); exit;'
% /usr/bin/time -o output/timing_pgd.txt -v matlab -nodisplay -nodesktop -nosplash -r 'main(0, @() input_verify('nr')); exit;'
