function sa_profile(function_handle)
profile off
profile clear;
% profile on -history -timer 'cpu'
profile on -history -timer 'performance' %-memory

function_handle();

p = profile('info');
profile off

save('output/profiler.mat', 'p', '-v6');

end

% p.FunctionTable.IsRecursive
% rec = zeros(length(p.FunctionTable),1);
% for i=1:length(p.FunctionTable)
%     rec(i) = p.FunctionTable(:).IsRecursive;
% end

% % get profile results
% p = profile('info');
% % compute coverage
% Coverage = zeros(length(p.FunctionTable), 1);
% for n = 1:length(p.FunctionTable)
%     % executed lines in functions
%     ExecutedLines = p.FunctionTable(n).ExecutedLines;
%     % runnable lines (undocumented matlab feature!)
%     RunnableLines = callstats('file_lines', p.FunctionTable(n).CompleteName);
%     % coverage in percent
%     Coverage(n) = 100 * length(unique(ExecutedLines(:, 1))) / ...
%     length(unique(RunnableLines));
% end
