addpath(genpath( 'D:/MATLAB/mvgc_v1.0'));

%clear;
load data_choice
load subj_globals 

ntrials   = 188;     % number of trials
nobs      = 1001;   % number of observations per trial

regmode   = 'OLS';  % VAR model estimation regression mode ('OLS', 'LWR' or empty for default)
icregmode = 'LWR';  % information criteria regression mode ('OLS', 'LWR' or empty for default)

morder    = 'AIC';  % model order to use ('actual', 'AIC', 'BIC' or supplied numerical value)
momax     = 65;     % maximum model order for model order estimation
nvars     = 2;

acmaxlags = 1001;   % maximum autocovariance lags (empty for automatic calculation)

tstat     = '';     % statistical test for MVGC:  'F' for Granger's F-test (default) or 'chi2' for Geweke's chi2 test
alpha     = 0.05;   % significance level for significance test
mhtc      = 'FDR';  % multiple hypothesis test correction (see routine 'significance')

fs        = 1000;    % sample rate (Hz)
fres      = [];     % frequency resolution (empty for automatic calculation)

x=cell2mat(data1.trial);
X1=reshape(x,size(x,1), size(data1.trial{1},2), size(data1.trial,2));
%X=X(:,:,1:120);
clear x data1;
%save X X;
egc=[];
% Calculate information criteria up to specified maximum model order.
%load X
elct=cat(2,lpfc_elecs,ofc_elecs);
comelct=nchoosek(elct,2);
FS=zeros(200,2);
for i=1:1
    try    
        
        X=X1(comelct(i,:),:,:);
        
        for j=1:200
            try
                XS=X(:,randperm(1001),:);
                [F,morder,pval,sig]=gca(XS,momax,regmode,acmaxlags,nobs,ntrials,nvars,tstat,alpha,mhtc);
                FS(j,1)=F(2,1);
                FS(j,2)=F(1,2);
                fd=das;
            catch
            end
        end
        
%         ptic('\n*** tsdata_to_infocrit\n');
%         [AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
%         ptoc('*** tsdata_to_infocrit took ');
%         
%         % Plot information criteria.
%         
% %         figure(1); clf;
% %         plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
% %         title('Model order estimation');
%         
%         amo = size(X,3); % actual model order
%         
%         fprintf('\nbest model order (AIC) = %d\n',moAIC);
%         fprintf('best model order (BIC) = %d\n',moBIC);
%         fprintf('actual model order     = %d\n',amo);
%         
%         % Select model order.
%         
%         if  strcmpi(morder,'actual')
%             morder = amo;
%             fprintf('\nusing actual model order = %d\n',morder);
%         elseif strcmpi(morder,'AIC')
%             morder = moAIC;
%             fprintf('\nusing AIC best model order = %d\n',morder);
%         elseif strcmpi(morder,'BIC')
%             morder = moBIC;
%             fprintf('\nusing BIC best model order = %d\n',morder);
%         else
%             fprintf('\nusing specified model order = %d\n',morder);
%         end
%         
%         egc.morder(i,:)= morder;
%         % Estimate VAR model of selected order from data.
%         
%         ptic('\n*** tsdata_to_var... ');
%         [A,SIG] = tsdata_to_var(X,morder,regmode);
%         ptoc;
%         
%         % Check for failed regression
%         
%         assert(~isbad(A),'VAR estimation failed');
%         
%         % NOTE: at this point we have a model and are finished with the data! - all
%         % subsequent calculations work from the estimated VAR parameters A and SIG.
%         
%         
%         % The autocovariance sequence drives many Granger causality calculations (see
%         % next section). Now we calculate the autocovariance sequence G according to the
%         % VAR model, to as many lags as it takes to decay to below the numerical
%         % tolerance level, or to acmaxlags lags if specified (i.e. non-empty).
%         
%         ptic('*** var_to_autocov... ');
%         [G,info] = var_to_autocov(A,SIG,acmaxlags);
%         ptoc;
%         
%         % The above routine does a LOT of error checking and issues useful diagnostics.
%         % If there are problems with your data (e.g. non-stationarity, colinearity,
%         % etc.) there's a good chance it'll show up at this point - and the diagnostics
%         % may supply useful information as to what went wrong. It is thus essential to
%         % report and check for errors here.
%         
%         var_info(info,true); % report results (and bail out on error)
%         
%         % Calculate time-domain pairwise-conditional causalities - this just requires
%         % the autocovariance sequence.
%         
%         ptic('*** autocov_to_pwcgc... ');
%         F = autocov_to_pwcgc(G);
%         ptoc;
%         
%         % Check for failed GC calculation
%         
%         assert(~isbad(F,false),'GC calculation failed');
%         
%         % Significance test using theoretical null distribution, adjusting for multiple
%         % hypotheses.
%         
%         pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
%         sig  = significance(pval,alpha,mhtc);
%         
%         [F,morder,pval,sig]=gca(X);
%         egc.F(i,1)=F(2,1);
%         egc.F(i,2)=F(1,2);
%         egc.pval(i,1)=pval(2,1);
%         egc.pval(i,2)=pval(1,2);
%         egc.sig(i,1)=sig(2,1);
%         egc.sig(i,2)=sig(1,2);
%         
%         % Plot time-domain causal graph, p-values and significance.
%         
%         %     figure(2); clf;
%         %     subplot(1,3,1);
%         %     plot_pw(F);
%         %     title('Pairwise-conditional GC');
%         %     subplot(1,3,2);
%         %     plot_pw(pval);
%         %     title('p-values');
%         %     subplot(1,3,3);
%         %     plot_pw(sig);
%         %     title(['Significant at p = ' num2str(alpha)])
%         %savefig('demo');
%         
%         % For good measure we calculate Seth's causal density (cd) measure - the mean
%         % pairwise-conditional causality. We don't have a theoretical sampling
%         % distribution for this.
%         
% %         cd = mean(F(~isnan(F)));
% %         egc.cd(i,:)=cd;
% %         fprintf('\ncausal density = %f\n',cd);


        [F,morder,pval,sig]=gca(X,momax,regmode,acmaxlags,nobs,ntrials,nvars,tstat,alpha,mhtc);
        egc.index(i,:)=comelct(i,:);
        egc.morder(i,:)=morder;
        egc.F(i,1)=F(2,1);
        egc.F(i,2)=F(1,2);
        egc.pval(i,1)=pval(2,1);
        egc.pval(i,2)=pval(1,2);
        egc.sig(i,1)=sig(2,1);
        egc.sig(i,2)=sig(1,2);

        if egc.F(i,1)>=quantile(FS(:,1),0.95)
            egc.sig(i,3)=0.05;
        else
            egc.sig(i,3)=0.95;
        end
        
        if egc.F(i,2)>=quantile(FS(:,2),0.95)
            egc.sig(i,4)=0.05;
        else
            egc.sig(i,4)=0.95;
        end
        
    catch
        disp('pair index');
        disp(i);
        disp('mistake in error'); 
        disp(info.error);
        egc.error(i,:)=1;
    end
end

%save egc egc

function[F,morder,pval,sig]=gca(X,momax,regmode,acmaxlags,nobs,ntrials,nvars,tstat,alpha,mhtc)
%ptic('\n*** tsdata_to_infocrit\n');
%[AIC,BIC,moAIC,moBIC] = tsdata_to_infocrit(X,momax,icregmode);
%ptoc('*** tsdata_to_infocrit took ');

% Plot information criteria.

%         figure(1); clf;
%         plot_tsdata([AIC BIC]',{'AIC','BIC'},1/fs);
%         title('Model order estimation');

% amo = size(X,3); % actual model order
% 
% fprintf('\nbest model order (AIC) = %d\n',moAIC);
% fprintf('best model order (BIC) = %d\n',moBIC);
% fprintf('actual model order     = %d\n',amo);

% Select model order.

morder = momax;
fprintf('\nusing AIC best model order = %d\n',morder);
% Estimate VAR model of selected order from data.

ptic('\n*** tsdata_to_var... ');
[A,SIG] = tsdata_to_var(X,morder,regmode);
ptoc;

% Check for failed regression

assert(~isbad(A),'VAR estimation failed');

% NOTE: at this point we have a model and are finished with the data! - all
% subsequent calculations work from the estimated VAR parameters A and SIG.


% The autocovariance sequence drives many Granger causality calculations (see
% next section). Now we calculate the autocovariance sequence G according to the
% VAR model, to as many lags as it takes to decay to below the numerical
% tolerance level, or to acmaxlags lags if specified (i.e. non-empty).

ptic('*** var_to_autocov... ');
[G,info] = var_to_autocov(A,SIG,acmaxlags);
ptoc;

% The above routine does a LOT of error checking and issues useful diagnostics.
% If there are problems with your data (e.g. non-stationarity, colinearity,
% etc.) there's a good chance it'll show up at this point - and the diagnostics
% may supply useful information as to what went wrong. It is thus essential to
% report and check for errors here.

var_info(info,true); % report results (and bail out on error)

% Calculate time-domain pairwise-conditional causalities - this just requires
% the autocovariance sequence.

ptic('*** autocov_to_pwcgc... ');
F = autocov_to_pwcgc(G);
ptoc;

% Check for failed GC calculation

assert(~isbad(F,false),'GC calculation failed');

% Significance test using theoretical null distribution, adjusting for multiple
% hypotheses.

pval = mvgc_pval(F,morder,nobs,ntrials,1,1,nvars-2,tstat); % take careful note of arguments!
sig  = significance(pval,alpha,mhtc);

end

