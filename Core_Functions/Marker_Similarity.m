function similarity_score=Marker_Similarity(profiles1,profiles2,varargin)
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

		default_method='KL';
		acceptable_methods={'regression','KL'};
		addParameter(p,'method',default_method,...
			@(x)any(strcmp(x,acceptable_methods)));

		
		default_number_of_randomizations=10;
		addParameter(p,'number_of_randomizations',default_number_of_randomizations,...
			@(x) validateattributes(x,{'numeric'},...
			{'scalar','>=',3}));

		parse(p,varargin{:});

		[~,~,similarity_score]=...
			Impute_Subpop_Transform(profiles1,profiles2,'method',p.Results.method);

        
		random_similarity_scores=zeros(p.Results.number_of_randomizations,1);

        for i=1:p.Results.number_of_randomizations
            perm=randperm(size(profiles1,1));
            [~,~,random_similarity_scores(i)]=...
                Impute_Subpop_Transform(profiles1,...
                profiles2(perm,:),'method',p.Results.method);
        end

		similarity_score=(similarity_score-mean(random_similarity_scores))/...
			std(random_similarity_scores);


end
