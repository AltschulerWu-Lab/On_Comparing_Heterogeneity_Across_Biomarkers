%% Script to generate top panels in Figure 3: Validation against Co-Staining
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

profile_data=load('Data/profiles.mat');
s3_data=load('Data/S3.mat');
%%
addpath('Helper_Functions/');
number_of_datasets=length(profile_data.data_set_names);
MI_scores=cell(number_of_datasets,1);
S3_scores=cell(number_of_datasets,1);

for dataset_number=1:number_of_datasets
    marker_names=profile_data.data_set_profiles{dataset_number}.marker_names;
    marker_set_numbers=profile_data.data_set_profiles{dataset_number}.marker_set_numbers;
    number_of_marker_sets=max(marker_set_numbers);
    
    
    s3_matrix=s3_data.data_set_S3{dataset_number}.s3_matrix;
    s3_matrix_std=s3_data.data_set_S3{dataset_number}.s3_matrix_std;
    subpop_assignments=profile_data.data_set_profiles{dataset_number}.subpop_assignments;
    
    % Identify all pairs of co-stained markers
    nr_markers_per_market_set=histc(marker_set_numbers,1:number_of_marker_sets);
    total_number_of_marker_pairs=sum(nr_markers_per_market_set.*(nr_markers_per_market_set-1)/2);
    marker_pair_list=[];
  
    for ms_num=1:number_of_marker_sets
        if(nr_markers_per_market_set(ms_num)>1)
            marker_pair_list=[marker_pair_list ;nchoosek(find(marker_set_numbers==ms_num),2)];
          
        end
    end
    
    
  
     
    
    MI_scores{dataset_number}=zeros(total_number_of_marker_pairs,2);
    S3_scores{dataset_number}=zeros(total_number_of_marker_pairs,2);
    marker_pair_names=cell(total_number_of_marker_pairs,1);
    for marker_pair_counter=1:total_number_of_marker_pairs
        marker1_number=marker_pair_list(marker_pair_counter,1);
        marker2_number=marker_pair_list(marker_pair_counter,2);
        marker_pair_names{marker_pair_counter}=[marker_names{marker1_number} ...
            '_vs_' marker_names{marker2_number}];
        
        % get S3 scores for costained marker pairs
        S3_scores{dataset_number}(marker_pair_counter,1)=...
            (s3_matrix(marker1_number,marker2_number)+...
			s3_matrix(marker2_number,marker1_number))/2;
        S3_scores{dataset_number}(marker_pair_counter,2)=...
            (s3_matrix_std(marker1_number,marker2_number)+...
			s3_matrix_std(marker2_number,marker1_number))/2;
        
        
        number_of_repeats=size(subpop_assignments,2);
        
        mutual_information=zeros(number_of_repeats);
        
        for repeat_number1=1:number_of_repeats
            for repeat_number2=1:number_of_repeats
                marker1_assignments=subpop_assignments{marker1_number,repeat_number1};
                marker2_assignments=subpop_assignments{marker2_number,repeat_number2};
                mutual_information(repeat_number1,repeat_number2)=...
                    Mutual_Information_From_Cell_Line_Assignments(marker1_assignments,...
                    marker2_assignments);
                
            end
        end
        
        MI_scores{dataset_number}(marker_pair_counter,1)=...
            mean(mutual_information(:));
        MI_scores{dataset_number}(marker_pair_counter,2)=...
            std(mutual_information(:));
        
    
        
        
    end
    figure;
    plot(MI_scores{dataset_number}(:,1),S3_scores{dataset_number}(:,1),'o',...
        'MarkerFaceColor',[0.3 0.3 0.3],'MarkerEdgeColor',...
        [0.3 0.3 0.3],'MarkerSize',15); 
    hold on;
    ploterr(MI_scores{dataset_number}(:,1),S3_scores{dataset_number}(:,1),...
        MI_scores{dataset_number}(:,2),S3_scores{dataset_number}(:,2),'ok'); 
    for marker_pair_counter=1:total_number_of_marker_pairs
        text(MI_scores{dataset_number}(marker_pair_counter,1),...
            S3_scores{dataset_number}(marker_pair_counter,1),...
            marker_pair_names{marker_pair_counter},'Interpreter','none');
    end
    hold off;
    xlabel('Mutual Information');
    ylabel('S3 Score');
    
end


