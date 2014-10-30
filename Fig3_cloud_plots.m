%% Script to generate bottom panels in Figure 3: Validation against Co-Staining
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

%% Set Up (change parameters in this section here to modify plots) 
feature_data=load('Data/features.mat');

% Specify the marker pairs to be displayed as a cell array
% Each row corresponds to a different marker pair, the first column is the
% data set name, the second a cell array containing the names of the two
% markers to be displayed (note they must be co-stained for this to work)
% and the third column is an array specifying the cell line numbers to be
% used.
clone_selected_cell_line_numbers=[3,6,8,9,24,37];
cancer_cell_lines_selected_cell_line_numbers=[4,6,9,12,28,33];
data_to_display={'cancer_cell_lines',{'DNA','E-Cadherin'},cancer_cell_lines_selected_cell_line_numbers;...
    'cancer_cell_lines',{'betacatenin','vimentin'},cancer_cell_lines_selected_cell_line_numbers;...
    'cancer_cell_lines',{'pSTAT3','pPTEN'},cancer_cell_lines_selected_cell_line_numbers;...
    'clone',{'Actin','Tubulin'},clone_selected_cell_line_numbers;...
    'clone',{'E-cadherin','pGSK3beta'},clone_selected_cell_line_numbers;...
    'clone',{'pERK','pP38'},clone_selected_cell_line_numbers};

%% Make Plots
addpath('Helper_Functions/');
number_of_plots=length(data_to_display); % one plot per marker pair
for plot_number=1:number_of_plots 
    
    % Parse input info
    data_set_name=data_to_display{plot_number,1};
    data_set_number=find(strcmpi(feature_data.data_set_names,data_set_name));
    if(isempty(data_set_number))
        error([data_set_name ' is not a valid data set']);
    end
    all_marker_names=feature_data.data_set_features{data_set_number}.marker_names;
    marker_set_numbers=feature_data.data_set_features{data_set_number}.marker_set_numbers;
    marker1_name=data_to_display{plot_number,2}{1};
    marker2_name=data_to_display{plot_number,2}{2};
    selected_cell_lines=data_to_display{plot_number,3};
    
    % Find all markers matching given names (some markers (DNA) are present
    % multiple times , on different marker sets)
    marker1_possible_numbers=find(strcmpi(all_marker_names,marker1_name));
    if(isempty(marker1_possible_numbers))
        error([marker1_name ' is not a valid marker name for data set ' ...
            data_set_name '. Valid names are ' strjoin(all_marker_names',',')]) ;
    end
    marker2_possible_numbers=find(strcmpi(all_marker_names,marker2_name));
    if(isempty(marker2_possible_numbers))
        error([marker2_name ' is not a valid marker name for data set ' ...
            data_set_name '. Valid names are ' strjoin(all_marker_names',',')]) ;
    end
    
    % Get the marker set numbers corresponding to the marker names and pick
    % the marker set which has both the markers selected
    marker1_possible_marker_sets=marker_set_numbers(marker1_possible_numbers);
    marker2_possible_marker_sets=marker_set_numbers(marker2_possible_numbers);
    marker_set_number=intersect(marker1_possible_marker_sets,marker2_possible_marker_sets);
    if(isempty(marker_set_number))
        error(['Markers' marker1_name ' and ' marker2_name ' were not co-stained']) ;
    end
    if(length(marker_set_number)>1)%should never happen given that no pair of markers is present on multiple marker sets in our data
        marker_set_number=marker_set_number(1);
    end
    marker1_number=marker1_possible_numbers(marker1_possible_marker_sets==marker_set_number);
    marker2_number=marker2_possible_numbers(marker2_possible_marker_sets==marker_set_number);
    
    % Get the feature data for the selected markers and cell lines and
    % format appropriately for the cloud plot function
    cloud_plot_data=cell(length(selected_cell_lines),1);
    for cell_line_counter=1:length(selected_cell_lines)
        cloud_plot_data{cell_line_counter}=...
            [feature_data.data_set_features{data_set_number}.feature_data{...
            marker1_number}{selected_cell_lines(cell_line_counter)}, ...
            feature_data.data_set_features{data_set_number}.feature_data{...
            marker2_number}{selected_cell_lines(cell_line_counter)}];
    end

    % Make Plot
    figure;
    colors=0.5*ones(length(selected_cell_lines),3);
    Cloud_Plot(cloud_plot_data,'colors',colors,'line_width',3);
    xlabel(marker1_name);
    ylabel(marker2_name);
    
end
