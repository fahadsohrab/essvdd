
function const= generalconstraintESSVDD(consType,Cval,Q,Traindata,Alphavector)

if consType==0 %no constraint used
    const=0;
elseif consType==1  %psi1
    const= (2*Q*(Traindata*Traindata'));
elseif consType==2  %psi2
    const= (2*Q*(Traindata*(Alphavector*Alphavector')*Traindata'));
elseif consType==3 %psi3
    Alphavector_C=Alphavector;
    Alphavector_C(Alphavector_C==Cval)=0;
    const= (2*Q*(Traindata*(Alphavector_C*Alphavector_C')*Traindata'));
elseif consType==4 %upsilon1
    E= Q * Traindata;
    EE = (pinv(cov(E'))) ;
    COVT=cov(Traindata');
    const= (-2*EE*Q*(Traindata*Traindata')*Q'*EE*Q*COVT)+(2*EE*Q*(Traindata*Traindata'));
elseif consType==5 %upsilon2
    E= Q * Traindata;
    EE = (pinv(cov(E'))) ;
    COVT=cov(Traindata');
    const= (-2*EE*Q*(Traindata*(Alphavector*Alphavector')*Traindata')*Q'*EE*Q*COVT)+(2*EE*Q*(Traindata*(Alphavector*Alphavector')*Traindata'));
elseif consType==6 %upsilon3
    E= Q * Traindata;
    EE = (pinv(cov(E'))) ;
    COVT=cov(Traindata');
    Alphavector_C=Alphavector;
    Alphavector_C(Alphavector_C==Cval)=0;
    const= (-2*EE*Q*(Traindata*(Alphavector_C*Alphavector_C')*Traindata')*Q'*EE*Q*COVT)+(2*EE*Q*(Traindata*(Alphavector_C*Alphavector_C')*Traindata'));
else
    disp('Error: Use correct regularization term')
end
end


