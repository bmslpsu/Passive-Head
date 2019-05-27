function ObjFunction = CurveFit(SysId)

% This scripts evaluates the objective function that is minimized to
% find the optimum natural frequency and damping ratio

% The input SysID is a 2X1 vector containing damping ratio and natural
% frequency.

global hAngles t

xe = SysId(1);
wn = SysId(2);
C = hAngles(1);


L = zeros(2,1);
L(1) = wn*(-xe + sqrt(xe^2-1));
L(2) = wn*(-xe - sqrt(xe^2-1));

% We fit the system to the response of a second order system with the
% governing ODE: m x_ddot + c x_dot + k x = 0


y = (1/(L(1)-L(2)))*C*(-L(2)*exp(L(1)*t)+L(1)*exp(L(2)*t));

ObjFunction = (y-hAngles)'*(y-hAngles);
% The objective function is the sum of squares of differences in the actual
% response and the predicted response.

end