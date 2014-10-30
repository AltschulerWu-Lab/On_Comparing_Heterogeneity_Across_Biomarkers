function Cloud_Plot(data_by_condition,varargin)
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


    number_of_conditions=length(data_by_condition);

    p=inputParser;
    
    default_colors=ColorBrewer(number_of_conditions);
    addParamValue(p,'colors',default_colors,...
        @(x) isnumeric(x) && size(x,2)==3 && size(x,1)==number_of_conditions);
    
    default_fill_contours=false(number_of_conditions,1);
    addParamValue(p,'fill_contours',default_fill_contours,...
        @(x) islogical(x) && (length(x)==1 || length(x) ==...
        number_of_conditions));

    default_line_width=2;
    addParamValue(p,'line_width',default_line_width,...
        @(x) isnumeric(x) && x>2);
    
    parse(p,varargin{:});
    
    colors=p.Results.colors;
    fill_contours=p.Results.fill_contours;
    line_width=p.Results.line_width;
    if(length(fill_contours)==1)
        temp=fill_contours;
        fill_contours    = default_fill_contours;
        fill_contours(:) = temp;
    end

    %figure;
    %subplot(1,number_of_markers,marker);
    n_bins=200;
    combined_data=cell2mat(data_by_condition(:));
    bx=linspace(prctile(combined_data(:,1),0),...
        prctile(combined_data(:,1),99.9),n_bins);
    by=linspace(prctile(combined_data(:,2),0),...
        prctile(combined_data(:,2),99.9),n_bins);
        
    for label=1:number_of_conditions
        
        
        
        %         bx=linspace(-0.2,1.2,n_bins);
        %         by=linspace(-0.2,1.2,n_bins);
        [N,~]=hist3(data_by_condition{label}(:,1:2),{bx,by});
        
        h=fspecial('gaussian',20,5);
        N_smooth=imfilter(N',h);
%        N_smooth=flipud(N_smooth);
        N_smooth=N_smooth/sum(N_smooth(:));
        [vals,I]=sort(N_smooth(:),'descend');
        N_smooth_cumul=N_smooth;
        N_smooth_cumul(I)=cumsum(vals);
        
        [B,~]=bwboundaries(N_smooth_cumul<0.90,'noholes');
        if(label==1)
            %imagesc(N_smooth_cumul);
            %colormap('bone');
            %hold on;
        end
        for k=1:length(B)
            boundary = B{k};
            
            plot(boundary(:,2), boundary(:,1),...
                'Color',colors(label,:),'LineWidth',line_width);
            hold on;
            x=boundary(:,2);x(end)=x(1);
            y=boundary(:,1);y(end)=y(1);
            %x=x';y=y'
            if(fill_contours(label))
                  fill(x,y,colors(label,:),'FaceAlpha',0.5,...
                  'EdgeColor',colors(label,:));
            end
            
        end
        
        axis square;
    end
    
    set(gca,'XTickLabel','','YTickLabel','');
    %xlabel(xl,'Interpreter', 'none');
    %ylabel(yl,'Interpreter', 'none');
    
    hold off;
    %set(gca,'color','k');
    set(gcf,'color','w');
    
    %set(gca,'XTickLabel',{'0','25','50','75','100'});
    %set(gca,'YTickLabel',arrayfun(@num2str,get(gca,'YTick')/2,'UniformOutput',false));
    % legend(label_names,...
    %     'FontSize',14,'FontName' ,'Droid Sans','location', 'Best');

end

