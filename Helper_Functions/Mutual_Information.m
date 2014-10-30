function [mi,enrichment_matrix]=Mutual_Information(prob_matrix)
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

   
    prob_matrix=prob_matrix./sum(prob_matrix(:));
    row_sums=sum(prob_matrix,2);
    p1=bsxfun(@times,prob_matrix,1./row_sums);
    col_sums=sum(prob_matrix,1);
    p2=bsxfun(@times,p1,1./col_sums);
    
    enrichment_matrix=prob_matrix.*log2(p2);
    mi=nansum(enrichment_matrix(:));
    enrichment_matrix(isnan(enrichment_matrix))=0;
end
