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
%   'npt'     :1 for Non-linear Projection Trick (NPT)-based non-linear E-SVDD (Default=0, linear)
%   's'       :Hyperparameter for the kernel inside NPT. 
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
defaultVal_npt=0;
defaultVal_upsilon=0;
defaultVal_s=0.001;

addParameter(p,'maxIter',defaultVal_maxIter)
addParameter(p,'C',defaultVal_Cval)
addParameter(p,'d',defaultVal_d)
addParameter(p,'eta',defaultVal_eta)
addParameter(p,'psi',defaultVal_psi)
addParameter(p,'B',defaultVal_b)
addParameter(p,'upsilon',defaultVal_upsilon)
addParameter(p,'npt',defaultVal_npt)
addParameter(p,'s',defaultVal_s)

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
npt=p.Results.npt;
sigma =p.Results.s;
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

if(npt~=1)&&(npt~=0)
    msg = 'Error in essvddtrain() input: npt value should be either 1 for non-linear data description, or 0 (defaullt if no argument is passed) for linear data description.';
    error(msg)
end

if npt==1
    disp('NPT bases non-linear ES-SVDD running...')
    %RBF kernel
    N = size(Traindata,2);
    Dtrain = ((sum(Traindata'.^2,2)*ones(1,N))+(sum(Traindata'.^2,2)*ones(1,N))'-(2*(Traindata'*Traindata)));
    sigma = sigma  * mean(mean(Dtrain));  A = 2.0 * sigma;
    Ktrain_exp = exp(-Dtrain/A);
    %center_kernel_matrices
    N = size(Ktrain,2);
    Ktrain = (eye(N,N)-ones(N,N)/N) * Ktrain_exp * (eye(N,N)-ones(N,N)/N);
    [U,S] = eig(Ktrain);        s = diag(S);
    s(s<10^-6) = 0.0;
    [U, s] = sortEigVecs(U,s);  s_acc = cumsum(s)/sum(s);   S = diag(s);
    II = find(s_acc>=0.999);
    LL = II(1);
    Pmat = pinv(( S(1:LL,1:LL)^(0.5) * U(:,1:LL)' )');
    %Phi
    Phi = Pmat*Ktrain;
    %Saving useful variables for non-linear testing
    npt_data={1,A,Ktrain_exp,Phi,Traindata};%1,A,Ktrain,Phi,Traindata (1 is for flag)
    Traindata=Phi;
else
    disp('Linear ES-SVDD running...')
end

Q = initialize_Q(size(Traindata,1),d);
E= (Q * Traindata)*(Traindata'*Q');
EE = sqrtm(pinv(E));
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
    St=Traindata*Traindata';
    V=pinv(Q*St*Q');
    Sum1_data =2*V*Q*Traindata*diag(Alphavector)*Traindata';
    Sum2_data= 2*V*Q*(Traindata*(Alphavector*Alphavector')*Traindata');
    Sum3_data=Sum1_data*Q'*V*Q*St;
    Sum4_data=Sum2_data*Q'*V*Q*St;
    Grad=Sum1_data-Sum2_data-Sum3_data+Sum4_data+(Bta*const);
    Q = Q - eta*Grad;
    
    %orthogonalize and normalize Q1
    Q = OandN_Q(Q);
    E= (Q * Traindata)*(Traindata'*Q');
    EE = sqrtm(pinv(E));

    reducedData=EE*Q*Traindata;
    Model = svmtrain(Trainlabel, reducedData', ['-s ',num2str(5),' -t 0 -c ',num2str(Cval)]);
    Qiter{ii}=EE*Q;
    Modeliter{ii}=Model;
end
essvdd.modelparam= Modeliter;
essvdd.Q= Qiter;

if npt==1
    essvdd.npt=npt_data;
else
    essvdd.npt{1}=0;
end

end
