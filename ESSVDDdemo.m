% This is a sample demo code for Subspace Support Vector Data Description
% The demo code is provided for Linear case S-SVDD
% For non-linear cases, first apply NPT.m over the data and then use the output Phi and Phi_t as train and test data in ssvddtrain() and ssvddtest() 
% Please contact fahad.sohrab@tuni.fi for any errors/bugs
clc
close all
clear

%%Generate Random Data
noOfTrainData = 500; noOfTestData = 100;
D= 5; %Original dimentionality of data
Traindata = rand(D,noOfTrainData); %Generate training data
%Training labels (all +1s) are not needed.

testlabels = -ones(noOfTestData,1);
perm = randperm(noOfTestData);
positiveSamples = floor(noOfTestData/2);
testlabels(perm(1:positiveSamples))=1; % test labels, +1 for target, -1 for outliers
Testdata= rand(D,noOfTestData); %Generate testing data

%Possible inputs to essvddtrain
% The first input argument is the Training (target) data
%other options are
%   'maxIter' :Maximim iteraions, Default=100
%   'C'       :Value of hyperparameter C, Default=0.1
%   'd'       :data in lower dimension, make sure that input d<D, Default=1,
%   'eta'     :Used as step size for gradient, Default=0.1
%   'psi'     :regularization term, Default=0 i.e., No regularization term
%             :Other options for psi are 1,2,3 (Please refer to paper for more details)
%   'upsilon' :regularization term, Default=0 i.e., No regularization term
%             :Other options for upsilon are 1,2,3 (Please refer to paper for more details)
%   'B'       :Controling the importance of regularization term, Default=0.1


essvddmodel=essvddtrain(Traindata,'C',0.1,'d',4,'eta',0.02,'B',0.001,'psi',2);
[predicted_labels,accuracy,sensitivity,specificity]=essvddtest(Testdata,testlabels,essvddmodel);
