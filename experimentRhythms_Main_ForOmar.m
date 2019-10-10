%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Modeling Infants' Perceptual Narrowing to Musical Rhhythm
%
% Dynamical systems model of Hannon & Trehub (2005a,b)
% Implemented using the Gradient Frequency Neural Network (GrFNN) Library
% https://github.com/MusicDynamicsLab/GrFNNToolbox
%
% Paper: https://nyaspubs.onlinelibrary.wiley.com/doi/10.1111/nyas.14050
% DOI: https://doi.org/10.1111/nyas.14050 
%
% Training Procedure
% 
% Model is a single-layer auditory net with internal plastic conns.
% Auditory layer is trained on a representative Western or Balkan rhythm
% 
% Parker Tichko, 2019, parker.tichko@uconn.edu
%
% SIMPLIFIED AND MODIFIED FOR OMAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% Model Parameters

%%%%%% Auditory Network Parameters %%%%%%
alpha1 = .01; beta11 = -1; beta12 = -2;                    % Auditory Layer Oscillator Regime: Supercritical Hopf Regime 
delta11 = 0; delta12 = 0; neps1 = 1;                       % See Kim & Large (2015) for more info

%%%%%% Learning Parameters %%%%%%
lambda =  -.45; mu1 = 3; mu2 = -0.9; ceps = 2; kappa = 3; % Parameters of Hebbian Learning Rule
m1 = 0.05;                                                % Learning rate
w =  0.75;                                                % connection strength (mult to connections)
C2 = [];                                                  % Initialize connection matrix
lambda = m1*lambda; mu1 =  m1*mu1; mu2 = m1*mu2; kappa = m1*kappa; % Mult learning parameters by learning rate

%%%%%% Misc Parameters %%%%%%
ampMult = 0.15;                                           % Scales amplitudes of rhythmic stimuli
numTrain = 1;                                             % Number of training trials per rhythm

%% Make Model

%%%%%% Make stimulus %%%%%%  
s = stimulusMake(1, 'mid', 'Iso_2_1_Original_120BBPM_32cycles.mid', 'display', 1);   % Western training rhythm
%s = stimulusMake(1, 'mid', 'NonIso_3_2_Original_120BPM_32cycles.mid', 'display', 1); % Balkan training rhythm
s.x = ampMult*s.x/rms(s.x);                                                          % Scale rhythm
s.x = hilbert(s.x);

%%%%%% Auditory Network %%%%%%
% Supercritical auditory network with 121 logarithmically tuned oscs, .3125 - 5 Hz
n1 = networkMake(1, 'hopf', alpha1, beta11, beta12, delta11, delta12, neps1, ... 
                    'log', .3125, 5, 121, 'tick', 2.^(-1:3), ...
                    'display', 1, 'save', 1, 'zna', 0); 
                
n1 = connectAdd(s, n1, 1, 'active');                     % Connections to stimulus                  
n1.con{1}.w = 3.0;                                       % Connections weights

%%%%%% Internal, Plastic Connections %%%%%%              
n1 = connectAdd(n1, n1, C2, 'weight', w, 'type', '2freq', 0.0125, ... 
    'learn', lambda, mu1, mu2, ceps, kappa,... %'noscale', ...
    'display', 1,'save', 0); %'phasedisp', 'save', 500

%%%%%% Define Model %%%%%%                     
M = modelMake(@zdot, @cdot, s, n1);

%% Run Model

filename = sprintf(s.fileName); 
disp(filename)

%%%%%% Training Loops %%%%%%  
for ii = 1:numTrain
    
    ii
    M = odeRK4fs(M);                    
 
end


