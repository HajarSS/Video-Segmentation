%........................................................................... 17 Nov 2011

function [x, z] = im2real(uB, vB)
% input: u,v-coordinates of Top and Botton points in the image
% output: X,Z-coordinate of the moving object in the reality

%{
% values for "VIRAT_050100.mp4"
f= 10000; %767; %2581;
H= 22.0716; %19.3323; %17.5965;
Vhr= 329.8812; %1040.5;
%y= 1.7;
%}

% values for "VIRAT_200_03.mp4"
f= 236.8937;
H= 11.2345;
Vhr= 51.7222;


z= ((-H*(f+vB*(Vhr/f)))/(vB-Vhr));      %centimeter 4:a kind of scaling... optional, for "VIRAT_200_03.mp4"

x= ((uB*H*sin(atan(Vhr/f))+uB*z)/f); % 15 : a kind of scaling... optional, for "VIRAT_050100.mp4"
%x= round(((uB*H*sin(atan(Vhr/f))+uB*z)/f)*2); % 2 : a kind of scaling... optional, for "VIRAT_200_03.mp4"


