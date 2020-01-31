feature('numcores')
maxNumCompThreads
% Currently, the maximum number of computational threads is equal to the number of physical cores on your machine.

%%
% fplot(@(x) x.*sin(x),[0,50])
% fplot(@(x) x/5+x.*sin(x),[0,50])
% fplot(@(x) (50-x).*(1+sin(x)),[0,50])

%%
% a=[1 2 3];
% b=[4 3 2];
% cross(a,b)
% dot(a,b)
% kron(a',b)

%%
A = zeros(100, 'int8');

%%
a = rand(6*100000, 100);
% j2 = @(x) cell2mat(reshape(arrayfun(@(i) (x(i:i+5)-(sum(x(i:i+2))/3)*[1 1 1 0 0 0])',1:6:length(x(:))-5,'UniformOutput',false),[size(x,1)/6,size(x,2)]));
% j2 = @(x) splitapply(@(xd) (sum(xd.^2)),x,repelem(1:size(x, 1) / 6, 6)');
d = @() double_dot_product(a, a);
e = @() double_dot_product_mex(a, a);
timeit(d)
timeit(e)

%% function(array)
a = magic(18);
j2 = @(x) reshape(arrayfun(@(i) norm(x(i:i+5)), 1:6:length(x(:))-5), [size(x, 1) / 6, size(x, 2)]); % ,'UniformOutput',false
j2(a)

x = magic(6);
dev = splitapply(@(xd) sum(xd), x, repelem(1:3, 2)');

A = cellfun(func, C);

%%
for i = 1:5000
    x{i} = ones(6);
end

% time_comparison(@() blkdiag(x{:}), @() blkdiagmex(x{:}))
time_comparison(@() blkdiagmex(x{:}), @() blkdiagmex_old(x{:}))

%%
% temp =  java.util.UUID.randomUUID;
% myuuid = temp.toString;
% disp(myuuid)
%
% T=3;
% NumReal=5;
% p = sobolset(T,'Skip',1e3,'Leap',NumReal);
% p = scramble(p,'MatousekAffineOwen');
% rValues = norminv(net(p,NumReal),0,1);
% Leaping is a technique used to improve the quality of a point set. However, you must choose the Leap values with care; many Leap values create sequences that fail to touch on large sub-hyper-rectangles of the unit hypercube, and so fail to be a uniform quasi-random point set.
% RNumReal is the number of realisations.

%%
clc
load('error_using_pgd.mat')
primal_full = primal.full;
dual_full = dual.full;
time_comparison(@() sqrt(sum(temporal_integration( ...
    double_dot_product(primal, integral_elasticity_tensor_diagonal*primal)+double_dot_product(dual, integral_inv_elasticity_tensor_diagonal*dual), ...
    temporal_mesh))), ...
    @() sqrt(sum(temporal_integration( ...
    double_dot_product(primal_full, integral_elasticity_tensor_diagonal*primal_full)+double_dot_product(dual_full, integral_inv_elasticity_tensor_diagonal*dual_full), ...
    temporal_mesh))))