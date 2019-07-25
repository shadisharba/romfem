clc
clear
close all
rng(0) % affects the initialisation

names = dir(fullfile('output_nn_datat', 'neural_network_training_*.mat'));

id = 148;
id6 = id * 6 - 5 : id * 6;
train_on_one_gp_only = false;

input = [];
output = [];
for file = names'
    load([file.folder, filesep, file.name]);
    
    gp = nn.gp;
    tensor_components = nn.ncomp;
    n_t = nn.n_t;
    
    if train_on_one_gp_only
        input = [input, vertcat(full(nn.stress(id6,:)), ...
            full(nn.back_stress(id6,:)), ...
            full(nn.isotropic_hardening(id,:)), ...
            full(nn.internal_damage(id,:)))];
        
        output = [output, vertcat(full(nn.internal_plastic_strain_rate(id6,:)), ...
            full(nn.internal_kinematic_rate(id6,:)), ...
            full(nn.internal_isotropic_rate(id,:)), ...
            full(nn.internal_damage_rate(id,:)))];
    else
        input = [input, vertcat(reshape(full(nn.stress), [tensor_components, gp * n_t]), ...
            reshape(full(nn.back_stress), [tensor_components, gp * n_t]), ...
            reshape(full(nn.isotropic_hardening), [1, gp * n_t]), ...
            reshape(full(nn.internal_damage), [1, gp * n_t]))];
        
        output = [output, vertcat(reshape(full(nn.internal_plastic_strain_rate), [tensor_components, gp * n_t]), ...
            reshape(full(nn.internal_kinematic_rate), [tensor_components, gp * n_t]), ...
            reshape(full(nn.internal_isotropic_rate), [1, gp * n_t]), ...
            reshape(full(nn.internal_damage_rate), [1, gp * n_t]))];
    end
    
end

clear nn

% scatter3(strainn(1,:),strainn(2,:),strainn(3,:));
% figure
% scatter3(strainn(1,:),strainn(2,:),stressn(1,:));

%% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
trainFcn = 'trainbr'; % Levenberg-Marquardt backpropagation.

%% Create a Fitting Network
net_hidden_layers = [28, 14]; % more layers : smoother and no over fitting % more neurons: fit very well no smoothness ...
net = fitnet(net_hidden_layers, trainFcn); % calls FEEDFORWARDNET

%% Choose Input and Output Pre/Post-Processing Functions
% For a list of all processing functions type: help nnprocess
% net.input.processFcns = {'removeconstantrows','mapminmax'};
% net.output.processFcns = {'removeconstantrows','mapminmax'};

%% Setup Division of Data for Training, Validation, Testing
% For a list of all data division functions type: help nndivision
net.divideFcn = 'dividerand'; % Divide data randomly
net.divideMode = 'sample'; % Divide up every sample
net.divideParam.trainRatio = 70 / 100;
net.divideParam.valRatio = 15 / 100;
net.divideParam.testRatio = 15 / 100;

%% Choose a Performance Function
% For a list of all performance functions type: help nnperformance
net.performFcn = 'mse'; % Mean Squared Error

%% Choose Plot Functions
% For a list of all plot functions type: help nnplot
net.plotFcns = {'plotperform', 'plottrainstate', 'ploterrhist', ...
    'plotregression', 'plotfit'};
%% Setup network parameters
% net = init(net);
net.layers{2}.transferFcn = 'poslin'; %'logsig'; %  purelin  tansig satlin radbas
net.trainParam.epochs = 40;
net.performParam.normalization = 'percent'; % normalizes errors between -1 and 1 [[this affects the results and the stoping criterion]]
% net.performParam.regularization = 0.001; % orces the network response to be smoother and less likely to overfit
net.trainParam.showWindow = false;

%% Train the Network
[net, tr] = train(net, input, output);

model_number = 1;
file_name = sprintf('output_nn_datat/neural_net_model_%02d.mat', model_number);
% while exist(file_name, 'file')
%     model_number = model_number + 1;
%     file_name = sprintf('output_nn_datat/neural_net_model_%02d.mat', model_number);
% end
save(file_name,'-v7.3')
% Generate a matrix-only MATLAB function for neural network code
% generation with MATLAB Coder tools.
% genFunction(net,'neural_constitutive_model','MatrixOnly','yes');
genFunction(net, sprintf('toolboxes/neural_network_model/neural_constitutive_model_%02d', model_number));