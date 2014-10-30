function Calculate_S3_Scores(profiles_filename,output_filename,varargin)

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

	
	
	profile_data=load(profiles_filename);
    
    p=inputParser;
    default_number_of_randomizations=10;
    addParameter(p,'number_of_randomizations',default_number_of_randomizations,...
        @(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',3}));
    
    default_number_of_repeats_per_marker=5;
    addParameter(p,'number_of_repeats_per_marker',default_number_of_repeats_per_marker,...
        @(x) validateattributes(x,{'numeric'},{'scalar','integer','>=',1,...
        '<=',10}));
    
    
    parse(p,varargin{:});
    number_of_randomizations=p.Results.number_of_randomizations;
    number_of_repeats_per_marker=p.Results.number_of_repeats_per_marker;
    
    number_of_datasets=length(profile_data.data_set_names);
    data_set_S3=cell(number_of_datasets,1);
    for dataset_number=1:number_of_datasets
        
        data_set_S3{dataset_number}.marker_names=profile_data.data_set_profiles{dataset_number}.marker_names;
        data_set_S3{dataset_number}.feature_names=profile_data.data_set_profiles{dataset_number}.feature_names;
        profiles=profile_data.data_set_profiles{dataset_number}.profiles;
        
        [number_of_markers,~]=size(profiles);
              
        marker_similarities_mean=zeros(number_of_markers);
        marker_similarities_std=zeros(number_of_markers);
        
        parfor marker1=1:number_of_markers
            for marker2=1:number_of_markers
                similarities_for_marker_pair=zeros(number_of_repeats_per_marker^2,1);
                tic;
                for rep1=1:number_of_repeats_per_marker
                    for rep2=1:number_of_repeats_per_marker
                        similarities_for_marker_pair(rep2+...
                            (rep1-1)*number_of_repeats_per_marker)=...
                            Marker_Similarity(profiles{marker1,rep1},...
                            profiles{marker2,rep2},'number_of_randomizations',...
                            number_of_randomizations);
                        
                    end
                end
                marker_similarities_mean(marker1,marker2)=...
                    mean(similarities_for_marker_pair);
                marker_similarities_std(marker1,marker2)=...
                    std(similarities_for_marker_pair);
                disp(['M1:' num2str(marker1) ' M2:' num2str(marker2)]);
                toc;
            end
        end
        
        
        scale_factor=repmat(diag(marker_similarities_mean),1,...
            size(marker_similarities_mean,1));
        scale_factor=(scale_factor+scale_factor')/2;
        
        data_set_S3{dataset_number}.s3_matrix=marker_similarities_mean./scale_factor;
        data_set_S3{dataset_number}.s3_matrix_std=-marker_similarities_std./scale_factor;
        
    end
    data_set_names=profile_data.data_set_names;
    save(output_filename,'data_set_names','data_set_S3');
end
