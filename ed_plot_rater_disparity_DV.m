%**************************************************
% 	Copyright 2013 by Robert Rein
%   gerrobrein@yahoo.com.au
%**************************************************
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%**************************************************

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rater_disparity(anno)
% INPUT:
% anno = hierarchical annotation struct
% OUTPUT:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ed_plot_rater_disparity(anno)

    
    noFiles = numel(anno.files);
    figHeight = max(300,min(noFiles*12+100,800));    
    figWidth = 800;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determining size of screen for position of figure
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    screen_size = get(0,'screensize');
    h_root_figure = findobj('tag','EasyDIAg');
    if ( isempty(h_root_figure) )
        lower_left_x = 300;
        lower_left_y = screen_size(4) - figHeight - 100;
    else
        root_pos = get(h_root_figure(end),'pos');
        lower_left_x = root_pos(1) + root_pos(3);
        if ( lower_left_x + figWidth > screen_size(3) )
            lower_left_x = 300;
        end
        lower_left_y = root_pos(2);
        if ( lower_left_y + figHeight > screen_size(4) )
            lower_left_y = screen_size(4) - figHeight - 100;
        end
    end

    h_fig = figure('pos',[lower_left_x lower_left_y figWidth figHeight],...
        'numbertitle','off',...
        'name','Rater disparity',...
        'menubar','none',...
        'resize','off');
    
    h_axes(1) = axes('unit','pixel','pos',[350 50 300 figHeight - 100],...
        'ygrid','on');
    setappdata(h_fig,'h_axes',h_axes);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting up menu
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_file = uimenu(h_fig,'label','File');
    h_save = uimenu(h_file,'label','Save plot',...
        'callback',{@rater_disparity_saveas,h_fig});    
    
    
    h_unit = uimenu(h_fig,'label','Unit');
    noUnits = numel(anno.units);
    h_tmp = uimenu(h_unit,'label',anno.units{1},'checked','on',...
            'callback',{@raterDisparity_dispatcher,h_fig},...
            'accelerator','1');
    for unit = 2:noUnits
        uimenu(h_unit,'label',anno.units{unit},...
            'callback',{@raterDisparity_dispatcher,h_fig},...
            'accelerator',num2str(unit));
    end
    uimenu(h_unit,'label','Collapsed',...
        'callback',{@raterDisparity_dispatcher,h_fig},...
        'accelerator',num2str(noUnits+1));
    setappdata(h_fig,'h_unit',h_unit);
    
    h_label = uicontrol('style','text','pos',[250 figHeight - 30 300 30],...
        'string','Unit','fontsize',12,'fontweight','bold','horizontalalignment','center');
    setappdata(h_fig,'h_label',h_label);
    
    raterDisparity_calcData(anno,h_fig);
    raterDisparity_dispatcher(h_tmp,[],h_fig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Date for easy identification of print-outs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uicontrol('style','text','pos',[200,20,100,20],...
        'string',date());

end

function raterDisparity_dispatcher(hObject,evt,h_fig)

    h_unit = getappdata(h_fig,'h_unit');
    units = get(h_unit,'children');
    
    set(units,'checked','off');
    set(hObject,'checked','on');
    iunit = find(units(end:-1:1) == hObject);
    
    h_label = getappdata(h_fig,'h_label');
    set(h_label,'string',get(hObject,'label'));

    raterDisparity_plot(h_fig,iunit);

end

function raterDisparity_calcData(anno,h_fig)

% [start end type, tier, filename, rater]

    noUnits = numel(anno.units);
    noFiles = numel(anno.files);
    
    res.fname = anno.files;
    res.mats = NaN(noFiles,2,noUnits+1);
    res.units = anno.units;
    
    try
    for file = 1:noFiles
        
       tMats = zeros(2,noUnits);
       for u = 1:noUnits   

           % rater 1
           idx = anno.data(:,3) == u & ...
               anno.data(:,5) == file & ...
               anno.data(:,6) == 1;
           tMats(1,u) = sum(idx);
           % rater 2
           idx = anno.data(:,3) == u & ...
               anno.data(:,5) == file & ...
               anno.data(:,6) == 2;
           tMats(2,u) = sum(idx);
           
       end
       res.mats(file,:,:) = [tMats,sum(tMats,2)];
       
    end
    catch ME
        throw(ME);
    end
    
    setappdata(h_fig,'data',res);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcOccurences(R1,R2,units)
% INPUT:
% R1,R2 = matrix
% units = number of units
% OUTPUT:
% mat = 2xnoUNits matrix, columns give occurences of annotation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = calcOccurences(R1,R2,units)
    mat = NaN(2,units);
    
    for u = 1:units
       mat(1,u) = sum(R1(:,1)==u);
       mat(2,u) = sum(R2(:,1)==u);
    end
    
end

function raterDisparity_plot(h_fig,unit)

    data = getappdata(h_fig,'data');
    if ( isempty(data) )
        fprintf('Error couldn''t find data\n');
        return
    end
    h_axes = getappdata(h_fig,'h_axes');
    
    noFiles = numel(data.fname);
    iid = (noFiles:-1:1)';
    
    cla(h_axes);
    set(h_fig,'currentaxes',h_axes);
    plot(squeeze(data.mats(:,1,unit)),iid,'d','markerface','red','markersize',12);
    set(h_axes,'nextplot','add');
    plot(squeeze(data.mats(:,2,unit)),iid,'x','markerface','blue','markersize',12,'linewidth',3);
    set(h_axes,'nextplot','replace');
    set(h_axes,'ytick',1:noFiles,'yticklabel',data.fname(noFiles:-1:1),'ylim',[0 noFiles+1],'ygrid','on')
    xlabel('Number of annotations');
    ylabel('Filename');
    legend('Pri','Rel');

end


function rater_disparity_saveas(hObject,evt,h_fig)

    [file,path] = uiputfile({'*.pdf';'*.png';'*.tif';'*.eps';'*.emf'},'Save figure as');
    if ( file )
        set(h_fig,'paperpositionmode','auto');
        saveas(h_fig,[path,file]);
        set(h_fig,'paperpositionmode','manual');
    end

end
