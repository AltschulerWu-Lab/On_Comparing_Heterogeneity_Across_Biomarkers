function [transformation_matrix,imputed_profiles,variance_captured]=...
        Impute_Subpop_Transform(input_profiles,target_profiles,varargin)
% ------------------------------------------------------------------------------
% Copyright 2014, The University of California at San Francisco
% Authors:
% Satwik Rajaram for the Altschuler and Wu Lab
%
% All rights reserved.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3 of the License.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details:
% < http://www.gnu.org/licenses/ >.
%
% ------------------------------------------------------------------------------

    
    p=inputParser;
    
    default_display='notify-detailed';
    acceptable_display_vals={'iter','off','none','iter-detailed','notify',...
        'notify-detailed','final','final-detailed'};
    addParamValue(p,'display',default_display,...
        @(x) any(validatestring(x,acceptable_display_vals)));
    
    default_idx=1:size(input_profiles,1);
    addParamValue(p,'idx',default_idx,...
        @(x) validateattributes(x,{'numeric'},{'integer','positive',...
        '<=',size(input_profiles,1)}));
    
    default_method='KL';
    acceptable_methods={'regression','KL'};
    addParamValue(p,'method',default_method,...
        @(x) any(validatestring(x,acceptable_methods)));
    
    
    parse(p,varargin{:});
    display_results=p.Results.display;
    idx=p.Results.idx;
    method=p.Results.method;
    
    
    
    if(nargin<3)
        idx=1:size(input_profiles,1);
    end
    if(nargin<4)
        display_results='iter';
    end
     
    number_of_subpopulations_input=size(input_profiles,2);
    number_of_subpopulations_target=size(target_profiles,2);
    %number_of_subpopulations=number_of_subpopulations_input;
    %T0=target_profiles(idx,:)\input_profiles(idx,:);
    T0=input_profiles(idx,:)\target_profiles(idx,:);
    T0(T0<0)=0;
    T0(T0>1)=1;
    
    
    %minfun=@(x) norm(input_profiles(idx,:)*x-target_profiles(idx,:));
    
    switch method
        case 'regression'
            minfun=@(x) sqrt(sum(sum((input_profiles(idx,:)*x-target_profiles(idx,:)).^2)));
            options = optimoptions('fmincon','Algorithm','active-set','Display',...
                display_results);
        case 'KL'
            minfun=@(x) nansum(nansum(log(target_profiles(idx,:)./...
                (input_profiles(idx,:)*x)).*target_profiles(idx,:),2))/size(input_profiles(idx,:),1);
            options = optimoptions('fmincon','Algorithm','interior-point','Display',...
                display_results);
        otherwise
            error('Invalid Method to Calculate Transform');
    end
    
    Aeq=[];
    for i=1:number_of_subpopulations_input %nr or rows of Aeq
        %Aeq=[Aeq; circshift(repmat(eye(1,number_of_subpopulations),1,number_of_subpopulations)',i-1)'];
        Aeq=[Aeq; circshift(repmat(eye(1,number_of_subpopulations_input),1,number_of_subpopulations_target)',i-1)'];
    end
    
    
    beq=ones(number_of_subpopulations_input,1);
    
    %         transformation_matrix=fmincon(minfun,T0,Aeq,beq,[],[],...
    %             zeros(number_of_subpopulations),ones(number_of_subpopulations),...
    %             [],options);
    transformation_matrix=fmincon(minfun,T0,[],[],Aeq,beq,...
        zeros(number_of_subpopulations_input,number_of_subpopulations_target)...
        ,ones(number_of_subpopulations_input,number_of_subpopulations_target),...
        [],options);
    
    imputed_profiles=input_profiles*transformation_matrix;
    switch method
        case 'regression'
            variance_captured=1-sum(var(target_profiles-imputed_profiles))/...
                sum(var(target_profiles));
        case 'KL'
            variance_captured=minfun(transformation_matrix);
        otherwise
            error('Invalid Method to Calculate Transform');
    end
    
    
end
