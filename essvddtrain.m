function [essvdd]=essvddtrain(Traindata,varargin)
%ssvddtrain() is a function for training a model based on "Subspace Support
%Vector Data Description"
% Input
%    Traindata = Contains training data from a single (target) class for training a model.
%   'maxIter' :Maximim iteraions, Default=100
%   'C'       :Value of hyperparameter C, Default=0.1
%   'd'       :data in lower dimension, make sure that input d<D, Default=1,
%   'eta'     :Used as step size for gradient, Default=0.1
%   'psi'     :regularization term, Default=0 i.e., No regularization term
%             :Other options for psi are 1,2,3 (Please refer to paper for more details)
%   'upsilon' :regularization term, Default=0 i.e., No regularization term
%             :Other options for psi are 1,2,3 (Please refer to paper for more details)
%   'B'       :Controling the importance of regularization term, Default=0.1
%
% Output      :ssvdd.modelparam = Trained model (for every iteration)
%             :ssvdd.Q= Projection matrix (after every iteration)
%Example
%essvddmodel=essvddtrain(Traindata,'C',0.12,'d',2,'eta',0.02,'psi',3);

p = inputParser;
defaultVal_maxIter = 100;
defaultVal_Cval = 0.1;
defaultVal_d = 1;
defaultVal_eta = 0.001;
defaultVal_psi=0;
defaultVal_b=0.01;
defaultVal_upsilon=0;

addParameter(p,'maxIter',defaultVal_maxIter)
addParameter(p,'C',defaultVal_Cval)
addParameter(p,'d',defaultVal_d)
addParameter(p,'eta',defaultVal_eta)
addParameter(p,'psi',defaultVal_psi)
addParameter(p,'B',defaultVal_b)
addParameter(p,'upsilon',defaultVal_upsilon)

valid_argnames = {'psi','upsilon'};
argwasspecified = ismember(valid_argnames, lower(varargin(1:2:end)));

if(sum(argwasspecified)>1)
    msg = 'Error: Use only 1 regularization term, either psi or upsilon in the essvddtrain()';
    error(msg)
end

parse(p,varargin{:});
maxIter=p.Results.maxIter;
Cval=p.Results.C;
d=p.Results.d;
eta=p.Results.eta;
consTypepsi=p.Results.psi;
Bta=p.Results.B;
consTypepsiupsilon=p.Results.upsilon;

if(consTypepsi>3)||(consTypepsi<0)
    msg = 'Error: psi should be either 0,1,2 or 3';
    error(msg)
end

if(consTypepsiupsilon>3)||(consTypepsiupsilon<0)
    msg = 'Error: Upsilon should be either 0,1,2 or 3';
    error(msg)
end

if consTypepsiupsilon~=0
    consType=consTypepsiupsilon+3;
else
    consType=consTypepsi;
end

Trainlabel= ones(size(Traindata,2),1); %Training labels (all +1s)

Q = initialize_Q(size(Traindata,1),d);
E= Q * Traindata;
EE = sqrtm(pinv(cov(E')));
reducedData=EE*Q*Traindata;
Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
for ii=1:maxIter
    
    %Get the alphas
    Alphaindex=Model.sv_indices; %Indices where alpha is non-zero
    AlphaValue=Model.sv_coef; %values of Alpha
    Alphavector=zeros(size(reducedData,2),1);
    for i=1:size(Alphaindex,1)
        Alphavector(Alphaindex(i))=AlphaValue(i);
    end
    const= generalconstraintESSVDD(consType,Cval,Q,Traindata,Alphavector);
    %Compute the gradient and update the matrix Q
    CovX=cov(Traindata'); 
    V=pinv(Q*CovX*Q');
    Sum1_data =2*V*Q*Traindata*diag(Alphavector)*Traindata';
    Sum2_data= 2*V*Q*(Traindata*(Alphavector*Alphavector')*Traindata');
    Sum3_data=Sum1_data*Q'*V*Q*CovX;
    Sum4_data=Sum2_data*Q'*V*Q*CovX;
    Grad=Sum1_data-Sum2_data-Sum3_data+Sum4_data+(Bta*const);
    Q = Q - eta*Grad;
    
    %orthogonalize and normalize Q1
    Q = OandN_Q(Q);
    E= Q * Traindata;
    EE = sqrtm(pinv(cov(E')));
    reducedData=EE*Q*Traindata;
    
    Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
    
    Qiter{ii}=EE*Q;
    Modeliter{ii}=Model;
end
essvdd.modelparam= Modeliter;
essvdd.Q= Qiter;
end
