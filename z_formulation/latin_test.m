close all
clear

syms xx
val = -10:0.001:10;

% note that here we don't have boundary conditions
% linear problem (equilibrium equation)
y1 = @(x) - x; %15*x+3;

% nonlinear problem (constitutive numerical_model)
% ff = sign(xx) .*sqrt(abs(xx)); % works but not very good
ff = xx.^2; % works
ff = xx.^3; % test
x1 = @(xx) xx.^3;

plot(val, y1(val));
hold on
plot(x1(val), val);

x = -10;
y = y1(x);
scatter(x, y)

for i = 1:200
    % local
    yh = y;
    xh = x1(yh);
    scatter(xh, yh, 'filled')
    
    % the tangent to nonlinear problem
    h = 1 / double(subs(diff(ff), xx, yh));
    % arbitrary search direction
    %     h=0.0033; % 0.0033 works because it's the initial tangent but 2 doesn't because it's not related to the problem in hand
    
    %     % plot the search directions
    %     xx=[-10:0.1:10];
    %     yy=h*(xx-xh)+yh;
    %     plot(xx,yy);
    
    % in terms of corrections
    f = (yh - y) - h * (xh - x);
    deltax = fzero(@(dx) h*dx+f+dx, 0);
    x = x + deltax;
    y = h * (x - xh) + yh;
    scatter(x, y);
    
    err = abs(x-xh) + abs(y-yh);
    fprintf('%e\n', err)
    
    if err <= 1e-5
        return;
    end
    
end

%     % in terms of final values
%     x=fzero(@(x) (y1(x)-yh) - h * (x-xh),0 );
%     y=y1(x);
%     scatter(x,y)
