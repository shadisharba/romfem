close all
period = 10;
new_load = loading(1, 10, 25, 2, 0);
old_load = loading(1, 10, 25, 1, 0);
n = 5;
old_load.magnitude(end+1:end+n) = old_load.magnitude(2:1+n);
new_load.magnitude(end+1:end+n) = new_load.magnitude(2:1+n);


figure
plot(linspace(0, 4.5, length(old_load.magnitude)), old_load.magnitude, linspace(4.5, 7.5, length(old_load.magnitude)), old_load.magnitude)

hold on
plot(linspace(0, 4.5, length(old_load.magnitude)), old_load.magnitude, linspace(4.5, 7.5, length(old_load.magnitude)), 2*old_load.magnitude)

saveastex('output/temporal_scheme_simtech_1.tex', true)

figure
plot(linspace(0, 4.5, length(old_load.magnitude)), old_load.magnitude, linspace(4.5, 7.5, length(old_load.magnitude)), old_load.magnitude)

hold on
plot(linspace(0, 4.5, length(old_load.magnitude)), old_load.magnitude, linspace(4.5, 7.5, length(old_load.magnitude)), 2*old_load.magnitude)

[scaling_factor, shift] = new_load.scaling_factor(old_load);
out = copy_cyclic(old_load.magnitude, scaling_factor, shift);
plot(linspace(4.5, 7.5, length(out)), out)

saveastex('output/temporal_scheme_simtech_2.tex', true)
