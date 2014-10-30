%% Script to generate Figure 2: A 2 subpopulation demonstration of the idea behind the method
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

%% Set Up (change parameters in this section to alter plots)
data_set='cancer_cell_lines'; % can be 'cancer_cell_lines' or 'clone'
profiles_filename='Data/2subpop_profiles.mat'; % be sure to use the 2-subpopulation profiles
selected_marker_pairs={'vimentin','E-Cadherin';'pPTEN','pAkt'}; % rows contain names of marker pairs to be plotted together. Be sure to sue correct spelling
use_marker_low_subpop=[true,true;false,false]; % boolean array of same size as selected_marker_pairs indicating whether to use the low (as opposed to hig) subpopulation for each marker


%% Data loading

profiles=load(profiles_filename);
dataset_number=find(strcmp(profiles.data_set_names,data_set),1);
all_marker_names=profiles.data_set_profiles{dataset_number}.marker_names;
all_subpop_models=profiles.data_set_profiles{dataset_number}.subpop_models(:,1);
all_marker_profiles=profiles.data_set_profiles{dataset_number}.profiles;
number_of_marker_pairs=size(selected_marker_pairs,1);


%% Plotting
for plot_number=1:number_of_marker_pairs
    
    % Find marker numbers for specified markers 
    marker1_num=find(strcmpi(all_marker_names,...
        selected_marker_pairs{plot_number,1}),1);
    marker2_num=find(strcmpi(all_marker_names,...
        selected_marker_pairs{plot_number,2}),1);
    
    % Check the gmm model for each marker and select the low/high
    % subpopulation as specified in use_marker_low_subpop
    [~,marker1_subpop_number]=max((-1)^use_marker_low_subpop(plot_number,1)...
        *all_subpop_models{marker1_num}.mu); % the -1 is used to turn max into min and therefore identify low/high subpopulation as required.
    [~,marker2_subpop_number]=max((-1)^use_marker_low_subpop(plot_number,2)...
        *all_subpop_models{marker2_num}.mu);
    
    figure;
    plot(all_marker_profiles{marker1_num,1}(:,marker1_subpop_number),...
        all_marker_profiles{marker2_num,1}(:,marker2_subpop_number),'o',...
        'MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5],...
        'MarkerSize',15);
    
    ternary=@(x,y) y{2-x};% Hacky ternary operator that assumes x is boolean

    set(gca,'Xscale','log','Yscale','log');
    % Make appropriate labels including marker name and low/high subpop as
    % specified
    xlabel(['Fraction of ' ternary(use_marker_low_subpop(plot_number,1),{'Low','High'}) ...
        ' ' all_marker_names{marker1_num} ' subpopulation'],'Interpreter','none');
    ylabel(['Fraction of ' ternary(use_marker_low_subpop(plot_number,2),{'Low','High'}) ...
        ' ' all_marker_names{marker2_num} ' subpopulation'],'Interpreter','none');
    
    
end
