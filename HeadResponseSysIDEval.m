% This script loads in processed data for a single fly and evaluates
% the optimum value of natural frequency and damping ratio that fits
% the actual response.

% The script also plots the fitted response over the actual response.

% To evaluate the objective function for optimization, the script calls
% in the function CurveFit.m.

% fminsearch is used for optimization.

clear all

global hAngles t

n_fly = 3;
n_trials = 10;
load(strcat('ProcessedDataBen_',num2str(n_fly)))
% hAngles = x';
% t = t';
% temp = [1,4,5,6,7,8,9,10];
% temp = [2,3,4,5,7,8,9,10];
% temp = [1,2,3,4,5,6,7,8];
% temp = 8;
% st = PD_2;

for j = 1:n_trials
    
    hAngles = (PD_x.th{j});
    t = (PD_x.t{j});

%  options = optimset('Display','iter','PlotFcns',@optimplotfval,'TolFun',1e-12,'TolX',1e-12);
    options = optimset('Display','iter','TolFun',1e-12,'TolX',1e-12);
    [SysID,fval,exitflag,output] = fminsearch(@CurveFit,[1.2;50],options)
% [1.2, 50] are the initial conditions used for optimization.

% The optimum values for xeta and wn are stored in the variable SysID

    SysInfoNew.xeta(j) = SysID(1)
    SysInfoNew.wn(j) = SysID(2)
    SysInfoNew.eflag(j) = exitflag;
    SysInfoNew.fval(j) = fval;
    
    C = hAngles(1);
    xe = SysID(1);
    wn = SysID(2);
    L = zeros(2,1);
% Using the optimum values, a fitted curve (y) is generated below:
    L(1) = wn*(-xe + sqrt(xe^2-1));
    L(2) = wn*(-xe - sqrt(xe^2-1));
    y = (1/(L(1)-L(2)))*C*(-L(2)*exp(L(1)*t)+L(1)*exp(L(2)*t));
    

% The plotting can be modified to suit the requirement
    subplot(5,2,j)
    hold on
%     figure(10)
    plot(t,hAngles,t,y,'LineWidth',1)
    grid on
    xlabel('Time (sec)')
    ylabel('Theta (deg)')
    % title((strcat('r = ',num2str(SysID(1)),', wn = ',num2str(SysID(2)))),'FontSize',12)
    gtext((strcat('r = ',num2str(SysID(1)),', wn = ',num2str(SysID(2)))),'FontSize',12)
    legend('Expt.','Fitted')
    
end

% save(strcat('SysInfoBen_',num2str(n_fly)), 'SysInfoNew')