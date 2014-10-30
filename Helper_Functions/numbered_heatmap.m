function numbered_heatmap(data,varargin)
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
    
    default_errorbars=[];
    addParamValue(p,'errorbars',default_errorbars,...
        @isnumeric);
    
    default_row_labels={};
    addParamValue(p,'row_labels',default_row_labels,...
        @iscell);
    
    
    default_highlight_row_labels=false(size(data,1),1);
    addParamValue(p,'highlight_row_labels',default_highlight_row_labels,...
        @(x) validateattributes(x,{'logical'},{'vector','numel',size(data,1)}));
    
    
    default_col_labels={};
    addParamValue(p,'col_labels',default_col_labels,...
        @iscell);
    
    
    default_clims=[0,1];
    addParamValue(p,'clims',default_clims,...
        @(x) ismatrix(x) && size(x,2)==2 && x(2)>=x(1));
    
    default_cmap=gray(128);
    addParamValue(p,'cmap',default_cmap,...
        @(x) ismatrix(x) && size(x,2)==3);
    
    default_font_size=30;
    addParamValue(p,'font_size',default_font_size,...
        @(x) isscalar(x) && isnumeric(x) && x>0);
    
    default_col_label_angle=0;
    addParamValue(p,'col_label_angle',default_col_label_angle,...
        @(x) isscalar(x) && isnumeric(x));
    
    default_col_label_pos='top';
    addParamValue(p,'col_label_pos',default_col_label_pos,...
        @(x) any(validatestring(x,{'top','bottom'})));
    
    
    default_make_percentage=true;
    addParamValue(p,'make_percentage',default_make_percentage,...
        @islogical);
    
    default_show_numbers=true;
    addParamValue(p,'show_numbers',default_show_numbers,...
        @islogical);
    
    default_ignore_sign=false;
    addParamValue(p,'ignore_sign',default_ignore_sign,...
        @islogical);
    
    parse(p,varargin{:});
    row_labels=p.Results.row_labels;
    highlight_row_labels=p.Results.highlight_row_labels;
    col_labels=p.Results.col_labels;
    clims=p.Results.clims;
    cmap=p.Results.cmap;
    font_size=p.Results.font_size;
    make_percentage=p.Results.make_percentage;
    errorbars=p.Results.errorbars;
    col_label_angle=p.Results.col_label_angle;
    col_label_pos=p.Results.col_label_pos;
    ignore_sign=p.Results.ignore_sign;
    show_numbers=p.Results.show_numbers;
    
    if(ignore_sign)
        signs=sign(data);
        data=abs(data);
        
    end
    
    data1=(data-clims(1))/(clims(2)-clims(1));
    data1(data1<0)=0;
    data1(data1>1)=1;
    imagesc(data1,[0,1]);
    colormap(cmap);
    if(ignore_sign)
        data=signs.*data;
        
    end
    if(show_numbers)
        for i=1:size(data,2)
            
            for j=1:size(data,1)
                colors=cmap;
                if(~isnan(data(j,i)))
                    num=round(128*data1(j,i));
                    if(~isnan(num))
                        num=max(num,1);
                        
                        if(make_percentage)
                            if(isempty(errorbars))
                                text(i,j,[num2str(round(100*data(j,i))) ''],'HorizontalAlignment'...
                                    ,'center','FontSize',font_size,'Color',1-colors(num,:),'FontName','Arial');
                            else
                                text(i,j,[num2str(round(100*data(j,i))) '\pm' ...
                                    num2str(round(100*errorbars(j,i)))],'HorizontalAlignment'...
                                    ,'center','FontSize',font_size,'Color',1-colors(num,:),'FontName','Arial');
                            end
                        else
                            if(isempty(errorbars))
                                text(i,j,sprintf('%0.2f',data(j,i)),'HorizontalAlignment'...
                                    ,'center','FontSize',font_size,'Color',1-colors(num,:),'FontName','Arial');
                            else
                                text(i,j,[sprintf('%0.2f',data(j,i))'\pm' ...
                                    sprintf('%0.2f',errorbars(j,i))],'HorizontalAlignment'...
                                    ,'center','FontSize',font_size,'Color',1-colors(num,:),'FontName','Arial');
                            end
                        end
                    end
                end
            end
        end
    end
    
    if(~isempty(row_labels))
        for j=1:size(data,1)
            if(~highlight_row_labels(j))
                text(0.5,j,row_labels{j},'HorizontalAlignment','right','FontSize',font_size,...
                    'FontName','Droid Sans','Interpreter','none');
            else
                text(0.5,j,row_labels{j},'HorizontalAlignment','right','FontSize',font_size,...
                    'FontName','Droid Sans','Interpreter','none','Color',[1 1 1],...
                    'BackgroundColor',[0 0 0]);
            end
        end
    end
    if(~isempty(col_labels))
        for j=1:size(data,2)
            if(strcmp(col_label_pos,'top'))
               ypos= 0.5;%-0.5*sind(col_label_angle);
               valign='bottom';
            else
               ypos= size(data,1)+0.5-0.5*sind(col_label_angle);
               valign='top';
            end
            text(j+1-cosd(col_label_angle),ypos,col_labels{j},...
                'VerticalAlignment',valign,'FontSize',font_size,...
                'FontName','Droid Sans','HorizontalAlignment','left',...
                'Rotation',col_label_angle,'Interpreter','none');
        end
    end
    grid on;
    set(gca,'XTick',0.5:1:(size(data,2)+0.5),'XTickLabel',{},'XColor',[0.8 0.4 0.2],'GridLineStyle','-');
    set(gca,'YTick',0.5:1:(size(data,1)+0.5),'YTickLabel',{},'YColor',[0.8 0.4 0.2]);
    %set(gcf,'Color','w');colorbar;
    
end
