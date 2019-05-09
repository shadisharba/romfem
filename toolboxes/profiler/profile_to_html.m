function profile_to_html()

p = load('output/profiler.mat');

sa_profsave(p.p, 'output/profile_results');

end