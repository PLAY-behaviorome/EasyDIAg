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
% plot_rater_agreement(anno)
% INPUT:
% agree_struct = agreement struct from calculate annotation agreement
% OUTPUT:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ed_plot_rater_agreement(anno)

    
    no_files = numel(anno.files);
    figHeight = max(300,min(no_files*12+100,800));    
    figWidth = 600;
    
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
        'name','Annotation agreement',...
        'menubar','none',...
        'resize','off');
    
    h_axes(1) = axes('unit','pixel','pos',[350 50 200 figHeight - 100],...
        'ygrid','on');
    setappdata(h_fig,'h_axes',h_axes);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setting up menus
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    h_file = uimenu(h_fig,'label','File');
    h_save = uimenu(h_file,'label','Save plot',...
        'callback',{@plot_rater_agreement_saveas,h_fig});    
    
    h_unit = uimenu(h_fig,'label','Unit');
    noUnits = numel(anno.units);
    h_tmp = uimenu(h_unit,'label',anno.units{1},'checked','on',...
            'callback',{@plot_rater_agreement_dispatcher,h_fig},...
            'accelerator','1');
    for unit = 2:noUnits
        uimenu(h_unit,'label',anno.units{unit},...
            'callback',{@plot_rater_agreement_dispatcher,h_fig},...
            'accelerator',num2str(unit));
    end
    uimenu(h_unit,'label','Collapsed',...
        'callback',{@plot_rater_agreement_dispatcher,h_fig},...
        'accelerator',num2str(noUnits+1));
    setappdata(h_fig,'h_unit',h_unit);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Title label
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_label = uicontrol('style','text','pos',[250 figHeight - 30 300 30],...
        'string','Unit','fontsize',12,'fontweight','bold','horizontalalignment','center');
    setappdata(h_fig,'h_label',h_label);
    
    plot_rater_agreement_calcData(anno,h_fig);
    plot_rater_agreement_dispatcher(h_tmp,[],h_fig);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Date for easy identification of print-outs
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    uicontrol('style','text','pos',[200,20,100,20],...
        'string',date());

end

function plot_rater_agreement_dispatcher(hObject,evt,h_fig)

    h_unit = getappdata(h_fig,'h_unit');
    units = get(h_unit,'children');
    
    set(units,'checked','off');
    set(hObject,'checked','on');
    iunit = find(units(end:-1:1) == hObject);
    
    h_label = getappdata(h_fig,'h_label');
    set(h_label,'string',get(hObject,'label'));

    plot_rater_agreement_plot(h_fig,iunit);

end

function plot_rater_agreement_calcData(anno,h_fig)

    no_units = numel(anno.units);
    no_tiers = numel(anno.tiers);
    no_files = numel(anno.files);
    
    threshold = 0.6;

    idx_r1 = anno.data(:,6) == 1;
    idx_r2 = anno.data(:,6) == 2;
    
    mats = NaN(no_files,2,no_units+1);
    for f = 1:no_files
        tmp_squares = zeros(2,2,no_units);
        for t = 1:no_tiers
            idx = anno.data(:,4) == t & ...
                anno.data(:,5) == f;
            r1 = anno.data(idx & idx_r1,1:3);
            r2 = anno.data(idx & idx_r2,1:3);
            tmp_squares = tmp_squares + agreement_facade(r1,r2,threshold,no_units);
        end
        mats(f,1,1:no_units) = squeeze(tmp_squares(1,1,:));
        mats(f,2,1:no_units) = squeeze(tmp_squares(1,2,:)) + squeeze(tmp_squares(2,1,:));
    end
    mats(:,1,no_units + 1) = sum(mats(:,1,1:no_units),3);
    mats(:,2,no_units + 1) = sum(mats(:,2,1:no_units),3);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % storing data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    res.fname = anno.files;
    res.mats = mats;
    setappdata(h_fig,'data',res);

end


function plot_rater_agreement_plot(h_fig,unit)

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
    plot(squeeze(data.mats(:,1,unit)),iid,'ro','markerface','red','markersize',12);
    set(h_axes,'nextplot','add');
    plot(squeeze(data.mats(:,2,unit)),iid,'bx','markerface','blue','markersize',12,'linewidth',3);
    set(h_axes,'nextplot','replace');
    set(h_axes,'ytick',1:noFiles,'yticklabel',data.fname(iid),'ylim',[0 noFiles+1],'ygrid','on')
    xlabel('Number of annotations');
    ylabel('Filename');
    legend('Agreement','Disagreement');

end

function plot_rater_agreement_saveas(hObject,evt,h_fig)

    [file,path] = uiputfile({'*.pdf';'*.png';'*.tif';'*.eps';'*.emf'},'Save figure as');
    if ( file )
        set(h_fig,'paperpositionmode','auto');
        saveas(h_fig,[path,file]);
        set(h_fig,'paperpositionmode','manual');
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function id = find_label(cellstr,pattern)

    id = cellfun(@(x) ~isempty(x),regexp(cellstr,pattern));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% agreement_facade
% Just a wrapper for the different functions
% needed to calculate agreement
% INPUT:
% r1        = Rating from first rater
% r2        = Rating from second rater
% threshold = threshold for agreement {0.6}
% no_type   = number of different units
% OUTPUT:
% squares   = 2x2xno_units tables for Cohen's kappa
% SIDEEFFECTS:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function squares = agreement_facade(r1,r2, threshold, no_types)

    map = gen_overlap_map(r1,r2);
    match = match_annotations(map);
    mapping = merge_match_type(match,r1,r2);
    squares = reduce_mapping_to_square(mapping,threshold,no_types);

end
