function mutual_information= Mutual_Information_From_Cell_Line_Assignments(assignments1,assignments2)
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

    
    max_sample_set_size=10000;
    
    number_of_cell_lines=length(assignments1);
    if(length(assignments2)~=number_of_cell_lines)
        error('Two sets of assignments must have equal number of cell lines');
    end
    
    nr_points_per_cell_line=cellfun('length',assignments1);
    if(~isequal(nr_points_per_cell_line,cellfun('length',assignments2)))
        error('The two assignments must have equal points per cell line. Were these markers really co-stained?') ;
    end
    
    % Attempt to randomly select equal number of points per cell line so
    % the results are not skewed by individual lines. When
    % cell lines do not have enough points, we just end up using as many
    % points as they do have
       
    [~,cell_line_order]=sort(nr_points_per_cell_line); % Start from cell line with fewest points, so we can compensate with the cell lines with more points if required
    data_counter=0;
    assignment1_subsamples=cell(number_of_cell_lines,1);
    assignment2_subsamples=cell(number_of_cell_lines,1);
    for i=1:number_of_cell_lines
        cn=cell_line_order(i);
        nr_points_in_condition=nr_points_per_cell_line(cn);
        % Attempt to split the number of points required equally among 
        % cell lines remaining, but use all points in current cell line if
        % it doesn't have enough
        nr_points_to_sample=min(nr_points_in_condition,...
            ceil((max_sample_set_size-data_counter)...
            /((number_of_cell_lines+1)-i))); 
        sampled_points=randperm(nr_points_in_condition,nr_points_to_sample);
        assignment1_subsamples{cn}=assignments1{cn}(sampled_points,:);
        assignment2_subsamples{cn}=assignments2{cn}(sampled_points,:);
        
        
        data_counter=data_counter+nr_points_to_sample;
    end
    
    assignment1_subsamples=cell2mat(assignment1_subsamples);
    assignment2_subsamples=cell2mat(assignment2_subsamples);
    
    assignment1_x_assignment2=[assignment1_subsamples,assignment2_subsamples];
    
    x_counts=hist3(assignment1_x_assignment2,...
        {1:max(cell2mat(assignments1)),1:max(cell2mat(assignments2))});
    x_counts=x_counts./sum(x_counts(:));
    mutual_information=Mutual_Information(x_counts);
    
    
    
    
end
