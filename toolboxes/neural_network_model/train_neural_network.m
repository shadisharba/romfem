%%
clc
clear
close all
rng(0) % affects the initialisation

load('matlab.mat')

%
gp = numerical_model.mesh.number_of_quadrature;
ncomp = numerical_model.mesh.quadrature_dof;
n_t = numerical_model.temporal.dof;

stress = local_fields.stress;
back_stress = local_fields.back_stress;
isotropic_hardening = local_fields.isotropic_hardening;
internal_damage = local_fields.internal_damage;

input = vertcat(reshape(full(stress),[ncomp,gp*n_t])...
    );
%     reshape(full(back_stress),[ncomp,gp*n_t]),...
%     reshape(full(isotropic_hardening),[1,gp*n_t]),...
%     reshape(full(internal_damage),[1,gp*n_t]));


strain = local_fields.strain;

output = vertcat(reshape(full(internal_plastic_strain),[ncomp,gp*n_t])...
    );
%     reshape(full(internal_kinematic),[ncomp,gp*n_t]),...
%     reshape(full(internal_isotropic),[1,gp*n_t]),...
%     reshape(full(internal_damage),[1,gp*n_t]));

% scatter3(strainn(1,:),strainn(2,:),strainn(3,:));
% figure
% scatter3(strainn(1,:),strainn(2,:),stressn(1,:));

%%
knn = fitcknn(input,output);

%% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainbr';  % Levenberg-Marquardt backpropagation.

%% Create a Fitting Network
net_hidden_layers = [28 14]; % more layers : smoother and no over fitting % more neurons: fit very well no smoothness ...
net = fitnet(net_hidden_layers,trainFcn); % calls FEEDFORWARDNET

%% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
% net.input.processFcns = {'removeconstantrows','mapminmax'};
% net.output.processFcns = {'removeconstantrows','mapminmax'};

%% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivision
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;

%% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse';  % Mean Squared Error

%% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform','plottrainstate','ploterrhist', ...
    'plotregression', 'plotfit'};

%% Setup network parameters
% net = init(net);
net.layers{2}.transferFcn = 'poslin'; %'logsig'; %  purelin  tansig satlin radbas
net.trainParam.epochs = 100;
net.performParam.normalization = 'percent'; % normalizes errors between -1 and 1 [[this affects the results and the stoping criterion]]
% net.performParam.regularization = 0.001; % orces the network response to be smoother and less likely to overfit
   net.trainParam.showWindow=false;

%% Train the Network
[net,tr] = train(net,input,output);

% Generate a matrix-only MATLAB function for neural network code
% generation with MATLAB Coder tools.
% genFunction(net,'neural_constitutive_model','MatrixOnly','yes');
genFunction(net,'neural_constitutive_model');
y = neural_constitutive_model(input);


%% Test the Network
% y = net(x);
% e = gsubtract(t,y);
% performance = perform(net,t,y)
% min(tr.perf(:))
% perf = crossentropy(net,yy,y2,{1},'regularization',0.1)
% [r,m,b] = regression(yy,y2)
% view(net);
%% Recalculate Training, Validation and Test Performance
% trainTargets = t .* tr.trainMask{1};
% valTargets = t .* tr.valMask{1};
% testTargets = t .* tr.testMask{1};
% trainPerformance = perform(net,trainTargets,y)
% valPerformance = perform(net,valTargets,y)
% testPerformance = perform(net,testTargets,y)

%% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)

%% https://de.mathworks.com/help/deeplearning/ug/improve-neural-network-generalization-and-avoid-overfitting.html

% convolution network

% try to train with random input instead of stress or strain????

% I have been designing NNs since ~1980 . However, it is only recently that I discovered that the minimum number
% of necessary hidden nodes is approximately the same as the number of local maxima in the target vs input plot.

% d. standardize inputs to zero mean and unit variance using zscore or mapstd.

%  8. You only have to vary 2 things
%   a. Number of hidden nodes (want as small as feasible)
%   b. Initial random weights
% 1 hidden layer is sufficient for minimizing MSE. Using more hidden layers does not guarantee a better result.
% You just need to increase the number of hidden nodes, H, AND try multiple (e.g., 10) cases of initial weights for each value of H.
