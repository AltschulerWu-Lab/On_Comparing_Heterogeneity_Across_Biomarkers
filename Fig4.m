%% Script to generate Figure 4: Result - biomarker similarity based on S3 scores
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

%% Set Up (change filenames in this section here to modify plots) 

s3_filename='Data/S3.mat';
%%
addpath('Helper_Functions/');
show_nums=false;
s3_data=load(s3_filename);

number_of_datasets=length(s3_data.data_set_names);

for dataset_number=1:number_of_datasets
    
    s3_matrix_full=s3_data.data_set_S3{dataset_number}.s3_matrix;
    marker_names=s3_data.data_set_S3{dataset_number}.marker_names;
    selected_markers=find(cellfun('isempty',regexp(marker_names,'DNA')));
    selected_marker_names=marker_names(selected_markers);
    s3_matrix=s3_matrix_full(selected_markers,:);
    s3_matrix=s3_matrix(:,selected_markers);
    
    distance_matrix=s3_matrix;
   
    distance_matrix=1-distance_matrix;
    distance_matrix(distance_matrix<0)=0;
    distance_matrix=(distance_matrix+distance_matrix')/2;
    distance_matrix=distance_matrix-diag(diag(distance_matrix));
    Z=linkage(squareform(distance_matrix),'average');
    perm=optimalleaforder(Z,distance_matrix);
    
    %[~,~,perm]=dendrogram(Z,0,'orientation','left','reorder',optimal_order);
    
    similarity_matrix_reordered=s3_matrix(perm,:);
    similarity_matrix_reordered=similarity_matrix_reordered(:,perm);
    
    figure;
    numbered_heatmap(similarity_matrix_reordered,'row_labels',selected_marker_names(perm),...
        'col_labels',selected_marker_names(perm),'font_size',20,...
        'col_label_angle',30,'clims',[0.15,0.5],'make_percentage',false,...
        'show_number',show_nums);
    axis square;
    
    
    
end
