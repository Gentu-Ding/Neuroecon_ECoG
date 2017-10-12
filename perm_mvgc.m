addpath(genpath( 'D:/MATLAB/mvgc_v1.0'));

clear;
load data_decoding
load subj_globals 



ntrials   = 188;     % number of trials
nobs      = 1001;   % number of observations per trial
bsize     =[];
nperms    = 100; 

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 51;  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 65;     % maximum model order for model order estimation
nvars     = 2;

acmaxlags = 1001;   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = 1000;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

%x=cell2mat(data1.trial);
%X1=reshape(x,size(x,1), size(data1.trial{1},2), size(data1.trial,2));
%X=X(:,:,1:120);
clear x data1;
%save X X;
egc=[];
% Calculate information criteria up to specified maximum model order.
%load X
elct=cat(2,lpfc_elecs,ofc_elecs);
comelct=nchoosek(elct,2);

gt=gamble_trials(bad_trials==0 & timeout_trials==0);
st=safebet_trials(bad_trials==0 & timeout_trials==0);

X=dd(comelct(253,:),:,126);

ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

% Plot information criteria.

figure(1); clf;
plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
title('Model order estimation');


X=X1(comelct(3,:),:,:);
ptic('*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(X,morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(A),'VAR estimation failed');

% Now calculate autocovariance according to the VAR model, to as many lags
% as it takes to decay to below the numerical tolerance level, or to acmaxlags
% lags if specified (i.e. non-empty).

ptic('*** var_to_autocov... ');
[G,res] = var_to_autocov(A,SIG,acmaxlags);
ptoc;

% Report and check for errors.

fprintf('\nVAR check:\n'); disp(res); % report results...
assert(~res.error,'bad VAR');         % ...and bail out if there are errors

ptic('*** autocov_to_pwcgc... ');
F = autocov_to_pwcgc(G);
ptoc;

pval_t = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat);
sig_t  = significance(pval_t,alpha,mhtc);

ptic('\n*** tsdata_to_mvgc_pwc_permtest\n');
FNULL = permtest_tsdata_to_pwcgc(X,morder,bsize,nperms,regmode,acmaxlags);
ptoc('*** tsdata_to_mvgc_pwc_permtest took ',[],1);

% (We should really check for permutation estimates here.)

% Permutation test significance test (adjusting for multiple hypotheses).

pval_p = empirical_pval(F,FNULL);
sig_p  = significance(pval_p,alpha,mhtc);

figure(2); clf;
subplot(1,3,1);
plot_pw(F);
title('Pairwise-conditional GC');
subplot(1,3,2);
plot_pw(pval_p);
title('p-values');
subplot(1,3,3);
plot_pw(sig_p);
title(['Significant at p = ' num2str(alpha)])

X=X1(comelct(5,:),:,:);
ptic('\n*** tsdata_to_infocrit\n');
[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
ptoc('*** tsdata_to_infocrit took ');

% Plot information criteria.

figure(1); clf;
plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
title('Model order estimation');

