%**************************************************
% 	Copyright 2014 by Robert Rein & Henning Holle
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Please cite
% Holle, H., & Rein, R. (2014). Behavior Research Methods, 47(3), 837–847.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% InterraterAgreement
% Interface for annotationScoring function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_DV

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Version number
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    major_version   = 1;
    minor_version   = 0;
    fix_version     = 1;
    
    % Output on command line
    EasyDIAg_welcome(major_version,minor_version,fix_version);

    h_fig = figure('pos',[400,300,650,500],'menubar','none','tag','EasyDIAg',...
        'resize','off','numbertitle','off');    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tables
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_table = uitable('pos',[15 200 450 280],...
        'columnname',{'Type','kappa','Pos agreement','Kappa_max','Raw agreement'},...
        'columnformat',{'char','numeric','numeric','numeric','numeric'},...
        'columnwidth',{130,80,80,80,75},...
        'CellSelectionCallback',{@EasyDIAg_cellsel,h_fig},'rowname',[]);
   
    uicontrol('style','text','pos',[480 450 120 30],'string','Agreement table');
    h_mat = uitable('pos',[480 400 90 50],...
        'columnformat',{'numeric','numeric'},...
        'columnname',[],'rowname',[],'columnwidth',{40,40});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % global matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_gmatrix = uicontrol('style','pushbutton','pos',[480 350 120 30],...
        'string','Global matrix',...
        'callback',{@EasyDIAg_view_globalmat,h_fig});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    uicontrol('style','text','pos',[480 300 100 30],'string','overlap');
    h_slider = uicontrol('style','slider','pos',[520 270 100 30],'min',10,...
        'max',90,'value',60,'callback',{@EasyDIAg_slider,h_fig},...
        'sliderstep',[1/30 2/30]);
    h_overlap = uicontrol('style','text','pos',[480 270 30 30],'string',60);
    
    h_update = uicontrol('style','pushbutton','pos',[480 200 100 30],'string','Update',...
        'callback',{@EasyDIAg_calc,h_fig});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Global parameter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_edit = zeros(1,7);
    uicontrol('style','text','pos',[30 160 360 30],'string','Global parameters (see manual for details)',...
        'fontsize',10,'fontweight','bold');
    labels = {{'%linked:',''},...
        {'RA','(incl. no match):'},...
        {'kappa_ipf','(incl. no match)'},...
        {'kappa max','(incl. no match)'},...
        {'RA','(excl. no match):'},...
        {'kappa','(excl. no match):'},...
        {'kappa max','(excl. no match):'}};
    label_height = [120 70 70 70 20 20 20];
    label_x_pos = [25 25 200 375 25 200 375];
    for i = 1:numel(h_edit)
        uicontrol('style','text','pos',[label_x_pos(i) label_height(i) 100 35],...
            'string',sprintf('%s\n%s',labels{i}{1},labels{i}{2}),'horizontalalignment','center');
        h_edit(i) = uicontrol('style','edit','pos',[label_x_pos(i)+105 label_height(i)+5 50 25],...
            'string','NaN','enable','off');
    end    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Menus
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    h_file = uimenu(h_fig,'label','File');
    uimenu(h_file,'label','Import Datavyu file','callback',{@EasyDIAg_open,h_fig},...
        'accelerator','o');
    h_save = uimenu(h_file,'label','Save agreement','callback',{@EasyDIAg_save,h_fig},...
        'enable','off','accelerator','s');
    
    h_diag = uimenu(h_fig,'label','Diagnostics');
    uimenu(h_diag,'label','Agreement plot','callback',{@EasyDIAg_diagDispatch,h_fig},...
        'accelerator','1');
    uimenu(h_diag,'label','Rater disparity','callback',{@EasyDIAg_diagDispatch,h_fig},...
        'accelerator','2');
    uimenu(h_diag,'label','Annotation lengths','callback',{@EasyDIAg_diagDispatch,h_fig},...
        'accelerator','3');
    
    h_help = uimenu(h_fig,'label','Help');
    uimenu(h_help,'label','About','callback',{@EasyDIAg_about,h_fig});
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Store data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    setappdata(h_fig,'h_table',h_table);
    setappdata(h_fig,'h_mat',h_mat);
    setappdata(h_fig,'h_save',h_save);
    setappdata(h_fig,'h_overlap',h_overlap);
    setappdata(h_fig,'h_slider',h_slider);
    setappdata(h_fig,'h_update',h_update);
    setappdata(h_fig,'h_gmatrix',h_gmatrix);
    setappdata(h_fig,'h_edit',h_edit);
    setappdata(h_fig,'majorversion',major_version);
    setappdata(h_fig,'minorversion',minor_version);
    setappdata(h_fig,'fixversion',fix_version);    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set figure name
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EasyDIAg_set_name(h_fig);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% EasyDIAg_set_name(h_fig,str)
% Sets the figure name
% INPUT:
% h_fig = handle to figure
% str   = additional string for figure name {optional}
% OUTPUT:
% None.
% SIDEEFFECTS:
% New name for GUI.
function EasyDIAg_set_name(h_fig,str)
    
    major_version   = get_save_handle(h_fig,'majorversion');
    minor_version   = get_save_handle(h_fig,'minorversion');
    fix_version     = get_save_handle(h_fig,'fixversion');
    if nargin < 2
        st = sprintf('EasyDIAg %g.%g.%g',major_version,minor_version,fix_version);
    else
        st = sprintf('EasyDIAg %g.%g.%g - %s',major_version,minor_version,fix_version,str);
    end
    set(h_fig,'name',st);

end

function EasyDIAg_welcome(major_version,minor_version,fix_version)

    clc
    disp('___________                     ________  .___   _____           ');
    disp('\_   _____/____    _________.__.\______ \ |   | /  _  \    ____  ');
    disp(' |    __)_\__  \  /  ___<   |  | |    |  \|   |/  /_\  \  / ___\ ');
    disp(' |        \/ __ \_\___ \ \___  | |    `   \   /    |    \/ /_/  >');
    disp('/_______  (____  /____  >/ ____|/_______  /___\____|__  /\___  / ');
    disp('        \/     \/     \/ \/             \/            \//_____/  ');
    fprintf('\n\nVersion %g.%g.%g\n\n',major_version,minor_version,fix_version);
    fprintf('Copyright (C) 2014 Robert Rein and Henning Holle\n');
    fprintf('GNU GPL V.3\n');
    fprintf('Modified 2020-08-26 by Kasey Soska fo Datavyu ingest\n');
    fprintf('Please cite: Holle, H., & Rein, R. (2014). Behavior Research Methods, 47(3), 837–847\n');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Callback for slider
% INPUT:
% hObject = calling object
% eventdata = {unused}
% h_fig = handle to gui window
% OUTPUT:
% None.
% SIDEEFFECTS:
% updates text label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_slider(hObject,eventdata,h_fig)

    value = round(get(hObject,'value'));
    set(getappdata(h_fig,'h_overlap'),'string',num2str(value));
    h_update = get_save_handle(h_fig,'h_update');
    set(h_update,'backgroundcolor','red');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% callback function for open button
% Load the Datavyu export file.
% INPUT:
% hObject = calling object (unused)
% eventdata = event data (unused)
% h_fig = handle to GUI
% OUTPUT:
% None.
% SIDEEFFECTS:
% data is stored in appdata struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_open(hObject,eventdata,h_fig)

    EasyDIAg_reset_gui(h_fig)    
    
    [file,path] = uigetfile('*.txt');
    if ( file == 0 )
        return;
    end
    
    filename = fullfile(path,file);
    
    anno = load_DV_file(filename);
    if ( isempty(anno) )
        return
    end
    
    setappdata(h_fig,'annotations',anno);
    setappdata(h_fig,'filename',filename);
    EasyDIAg_set_name(h_fig,file);
    
    EasyDIAg_calc(h_fig,[],h_fig);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculating rater agreement
% Main function which calculates the different
% measures
% INPUT:
% hObject = calling object {unused}
% eventdata = event data {unused}
% OUTPUT:
% None.
% SIDEEFFECTS:
% table values are updated
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_calc(hObject,eventdata,h_fig)

    anno        = get_save_handle(h_fig,'annotations');
    
    value       = get(getappdata(h_fig,'h_slider'),'value');
    
    noAnnotations = numel(anno.units);
    data = cell(noAnnotations,3);
    mats = cell(noAnnotations,1);
    
    [agStr,agMatGl] = process_DV_file(anno,value/100);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate scores for each individual annotation
    % type
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for a = 1:noAnnotations
        
        tmpTable = squeeze(agStr(:,:,a));        
        
        data{a,1} = anno.units{a};        
        data{a,2} = round2(Cohenskappa(tmpTable));
        data{a,3} = round2(positive_agreement(tmpTable));
        data{a,4} = maximum_kappa(tmpTable);
        data{a,5} = round2(raw_agreement(tmpTable));
        mats{a} = tmpTable;
        
    end    
    h_table = get_save_handle(h_fig,'h_table');
    set(h_table,'data',data);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate global scores
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % kappa including no match
    [ck,ck_max,p0] = ckappa(agMatGl);
    % kappa excluding no match
    agMatGl_no_match = agMatGl(1:(end-1),1:(end-1));
    ck_ex       = Cohenskappa(agMatGl_no_match);
    ck_max_ex   = maximum_kappa(agMatGl_no_match);
    p0_ex       = raw_agreement(agMatGl_no_match);
    % percent overlap
    lp = round2(sum(sum(agMatGl(1:end-1,1:end-1)))/sum(sum(agMatGl)));
        
    h_edit = get_save_handle(h_fig,'h_edit');
    set(h_edit(1),'string',round2(lp));
    set(h_edit(2),'string',round2(p0));
    set(h_edit(3),'string',round2(ck));
    set(h_edit(4),'string',round2(ck_max));
    set(h_edit(5),'string',round2(p0_ex));
    set(h_edit(6),'string',round2(ck_ex));
    set(h_edit(7),'string',round2(ck_max_ex));
    
    % activate appropriate GUI controls
    h_save = get_save_handle(h_fig,'h_save');
    set(h_save,'enable','on');
    h_update = get_save_handle(h_fig,'h_update');
    set(h_update,'enable','on','backgroundcolor','green');
    h_gmatrix = get_save_handle(h_fig,'h_gmatrix');
    set(h_gmatrix,'enable','on');
    
    setappdata(h_fig,'mats',mats); 
    setappdata(h_fig,'agStr',agStr);
    setappdata(h_fig,'agMatGl',agMatGl);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% callback function for save button
% INPUT:
% jObject = calling object {unused}
% eventdata = event data {unused}
% h_fig = handle to gui window
% OUTPUT:
% None.
% SIDEFFECTS:
% If successful, a text file is generated containing
% the data form the table.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_save(hObject,eventdata,h_fig)

    [file,path] = uiputfile('*.txt','Choose an export file');
    if ( file == 0 )
        return
    end
    
    fid = fopen([path,file],'wt');
    if ( fid == -1 )
        msgbox('Couldn''t write file!');
        return
    end
    try
        
        square  = get_save_handle(h_fig,'agMatGl');
        anno    = get_save_handle(h_fig,'annotations');
        no_annotations = sum(sum(square));
        
        %%%% Write the export filename
        fprintf(fid,'EasyDIAg version: %g.%g.%g\n',...
            getappdata(h_fig,'majorversion'),...
            getappdata(h_fig,'minorversion'),...
            getappdata(h_fig,'fixversion'));
        fprintf(fid,'File created: %s\n\n',date());
        
        filename = get_save_handle(h_fig,'filename');
        fprintf(fid,'Datavyu data export filename:\n%s\n',filename);
        fprintf(fid,'Contained %g annotations.\n', no_annotations);
        
        %%%% Determine overlap
        fprintf(fid,'Overlap value used = ');
        h_slider = get_save_handle(h_fig,'h_slider');
        value = round(get(h_slider,'value'));
        fprintf(fid,'%g %%\n\n',value);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Write global kappa
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        h_edit = get_save_handle(h_fig,'h_edit');
        
        fprintf(fid,'1) Percentage of linked units:\n');
        fprintf(fid,'linked         = %s %%\n\n', get(h_edit(1),'string'));
        
        fprintf(fid,'2) Overall agreement indicies (including no match):\n');
        fprintf(fid,'Raw agreement  = %s\n', get(h_edit(2),'string'));
        fprintf(fid,'kappa          = %s\n', get(h_edit(3),'string'));
        fprintf(fid,'kappa_max      = %s\n\n', get(h_edit(4),'string'));
        
        fprintf(fid,'3) Overall agreement indicies (excluding no match):\n');
        fprintf(fid,'Raw agreement  = %s\n', get(h_edit(5),'string'));
        fprintf(fid,'kappa          = %s\n', get(h_edit(6),'string'));
        fprintf(fid,'kappa_max      = %s\n\n', get(h_edit(7),'string'));
        
        fprintf(fid,'4) Global agreement matrix:\n');
        % write matrix        
        [no_rows,no_cols] = size(square);
        tick_labels = [anno.units;{'no match'}];
        % header
        fprintf(fid,'%25s\t','');
        for i = 1:no_cols
           fprintf(fid,'%5s\t',tick_labels{i}(1));
        end
        fprintf(fid,'\n');
        % tallies
        for r = 1:no_rows
           fprintf(fid,'%25s\t',tick_labels{r});
           for i = 1:no_cols
               fprintf(fid,'%5g\t', square(i,r));
           end
           fprintf(fid,'\n');
        end
        fprintf(fid,'\n');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Write kappas for individual units
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(fid,'5) Individual agreement scores:\n');
        h_table = get_save_handle(h_fig,'h_table');
        
        table_header = get(h_table,'columnname');
        no_labels = numel(table_header);
        data = get(h_table,'data');
        no_types = size(data,1);
        % write header
        fprintf(fid,'%25s\t',table_header{1});
        for h = 2:no_labels
            fprintf(fid,'%12s\t',table_header{h});
        end
        
        fprintf(fid,'\n');
        % write data
        for row = 1:no_types
            fprintf(fid,'%25s\t',data{row,1});
            for entry = 2:no_labels-1
                fprintf(fid,'%12.2f\t',data{row,entry});
            end
            fprintf(fid,'%13.2f\n',data{row,end});
        end
        
    catch ME
        display(getReport(ME));
    end
    fclose(fid);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell selection button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_cellsel(hObject,eventdata,h_fig)

    mats = getappdata(h_fig,'mats');
    h_mat = getappdata(h_fig,'h_mat');
    if ( isempty(eventdata.Indices) )
        set(h_mat,'data',zeros(2));
    else
        set(h_mat,'data',mats{eventdata.Indices(1)});       
    end    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global agreement matrix view
% Display the global agreement matrix
% along with kappa calculated using iterative
% proportional fitting.
% INPUT:
% ho = calling object {unused}
% ev = event data {unused}
% OUTPUT:
% None.
% SIDEEFFECTS:
% Generates a graph of the global matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_view_globalmat(ho,ev,h_fig)

    square  = get_save_handle(h_fig,'agMatGl');
    anno    = get_save_handle(h_fig,'annotations');
    
    [no_rows,no_cols] = size(square);
    figure('menubar','none','numbertitle','off');
    tick_labels = [anno.units;{'no match'}];
    no_labels = numel(tick_labels);
    x_lim = [0.5 no_cols+0.5];
    y_lim = [0.5 no_rows+0.5];
    h_axes = axes('xlim',x_lim,'ylim',y_lim,...
        'ydir','reverse',...
        'xtick',1:no_cols,'ytick',1:no_rows,...
        'yticklabel',tick_labels,'xticklabel','',...
        'XAxisLocation','top');
    text(mean(x_lim),y_lim(end)+.5,'Rater 1',...
        'horizontalalignment','center',...
        'fontsize',12,...
        'fontweight','bold');
    text(x_lim(end)+0.5,mean(y_lim),'Rater 2',...
        'horizontalalignment','center',...
        'fontsize',12,...
        'fontweight','bold',...
        'rotation',90);
    
    % plot matches
    for c = 1:no_cols
        for r = 1:no_rows
            if r == no_rows && c == no_cols
                text(r,c,'-','fontsize',20,...
                'fontweight','bold',...
                'color','black',...
                'horizontalalignment','center',...
                'verticalalignment','middle');
            else
                text(r,c,num2str(square(r,c)),'fontsize',20,...
                    'fontweight','bold',...
                    'color','black',...
                    'horizontalalignment','center',...
                    'verticalalignment','middle');
            end
        end
    end
    
    % add top labels
    text(1:no_labels,0.4+zeros(1,no_labels),tick_labels',...
        'rotation',90,'horizontalalignment','left')
    
    % add grid
    grid_ticks      = 1.5:(no_cols-0.5);
    no_grid_lines   = numel(grid_ticks);
    line(repmat(x_lim',1,no_grid_lines),repmat(grid_ticks,2,1),...
        'color','black');
    line(repmat(grid_ticks,2,1),repmat(y_lim',1,no_grid_lines),...
        'color','black');
    
    % set margins
    pos = get(h_axes,'pos');
    set(h_axes,'pos',pos .* [1.2 1.2 0.8 0.8]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diagnostics dispatcher
% Dispatch function which calls the different diagnostic views
% INPUT:
% hObject = calling object
% eventdata = event data {unused}
% h_fig = handle to gui window
% OUTPUT:
% None.
% SIDEEFFECTS:
% Calls relevant diagnostic function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_diagDispatch(hObject,eventdata,h_fig)

    switch ( get(hObject,'label') )
        
        case 'Agreement plot'
            agStr = getappdata(h_fig,'annotations');
            if ( ~isempty(agStr) )
                ed_plot_rater_agreement(agStr);
            else
                fprintf('Coulnd''t fetch data');
            end
            
        case 'Rater disparity'
            
            anno = getappdata(h_fig,'annotations');
            if ( ~isempty(anno) )
               ed_plot_rater_disparity_DV(anno); 
            end
            
        case 'Annotation lengths'
            anno = getappdata(h_fig,'annotations');
            if ( ~isempty(anno) )
                ed_plot_annotation_duration_DV(anno);
            end
            
        otherwise
            fprintf('Dispatch erroneous\n');
    end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% About message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_about(hObject,eventdata,h_fig)
    h_dialog = dialog('windowstyle','modal');
    tmp_string = sprintf('%s %g.%g.%g\n%s\n%s\n%s',...
        'EasyDIAg Toolbox Version ',...
        getappdata(h_fig,'majorversion'),...
        getappdata(h_fig,'minorversion'),...
        getappdata(h_fig,'fixversion'),...
        'Released under GPL3 license',...
        'Please cite the following reference:',...
        'Holle & Rein (in press),',...
        'Behavior Research Methods');
    uicontrol(h_dialog,'style','text',...
        'string',tmp_string,...
        'pos',[50 10 520 450],...
        'fontsize',14,'fontweight','bold');
    
    uicontrol(h_dialog,'style','text',...
        'string','kappa is calculated according to:',...
        'pos',[20 250 520 30],'fontweight','bold',...
        'fontsize',12,'horizontalalignment','left');
    tmp_string = sprintf('%s',...
        'Cohen, J. (1960). A coefficient for nominal scales, ',...
        'Educational and Psychological Measurement, 20(1):37-46');
    uicontrol(h_dialog,'style','text',...
        'string',tmp_string,...
        'pos',[40 200 600 50],...
        'fontsize',12,'horizontalalignment','left');
    
    uicontrol(h_dialog,'style','text',...
        'string','Positive agreement is calculated according to:',...
        'pos',[20 140 520 40],...
        'fontsize',12,'fontweight','bold',...
        'horizontalalignment','left');
    tmp_string = sprintf('%s',...
        'Cicchetti, D. V., Feinstein, A. R. (1990). High agreement but ',...
        'low kappa: II. Resolving the paradoxes. J. Clin. Epidemiol., 43(6), 551-558.');
    uicontrol(h_dialog,'style','text',...
        'string',tmp_string,...
        'pos',[40 100 600 50],...
        'fontsize',12,'horizontalalignment','left');
    
    uicontrol(h_dialog,'style','text',...
        'string','kappa_max is calculated according to:',...
        'pos',[20 50 520 40],'fontweight','bold',...
        'fontsize',12,'horizontalalignment','left');
    tmp_string = sprintf('%s',...
        'Cohen, J. (1960). A coefficient for nominal scales, ',...
        'Educational and Psychological Measurement, 20(1):37-46');
    uicontrol(h_dialog,'style','text',...
        'string',tmp_string,...
        'pos',[40 10 600 50],...
        'fontsize',12,'horizontalalignment','left');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EasyDIAg_reset_gui(h_fig)
% INPUT:
% h_fig = handle to GUI
% OUTPUT:
% None
% SIDEEFFECTS:
% GUI is resetted to initial state.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function EasyDIAg_reset_gui(h_fig)

    h_table = get_save_handle(h_fig,'h_table');
    set(h_table,'data',[]);
    h_save = get_save_handle(h_fig,'h_save');
    set(h_save,'enable','off');
    h_edit = get_save_handle(h_fig,'h_edit');
    set(h_edit,'string','NaN');
    h_update = get_save_handle(h_fig,'h_update');
    set(h_update,'enable','off');
    h_gmatrix = get_save_handle(h_fig,'h_gmatrix');
    set(h_gmatrix,'enable','off');
    
    setappdata(h_fig,'annotations',[]);
    setappdata(h_fig,'filename',[]);
    setappdata(h_fig,'agStr',[]);
    setappdata(h_fig,'agMatGl',[]);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% helper functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% round2
% Rounds to two decimal places
% INPUT:
% num = number
% OUTPUT:
% rndnum = rounded number
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rndnum = round2(num)

    rndnum = round(num*100)/100;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% raw_agreement
% Calculates the raw agreement
% from a contigency table
% INPUT:
% table = contingency table
% OUTPUT:
% ra = raw agreement
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ra = raw_agreement(table)

    [no_rows,no_cols] = size(table);
    assert(no_rows == no_cols,'Table is not square');
    
    ra = sum(diag(table))/sum(sum(table));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maximum_kappa
% Calculates the maximum obtainable kappa
% values given the marginal distributions.
% Cohen (1960) equ. (6)
% INPUT:
% table = agreement table
% OUTPUT:
% kappa_max = maximum kappa value
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kappa_max = maximum_kappa(table)

    N = sum(sum(table));
    table = table / N;
    row_sum = sum(table);
    col_sum = sum(table,2)';
    min_sum = min([row_sum;col_sum]);
    pe = sum(col_sum.*row_sum);
    po = sum(min_sum);
    kappa_max = (po-pe)/(1-pe);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% positive_agreement
% Calculates the positive agreement
% Cichetti & Feinstein (1990) p. 554
% INPUT:
% table = contingency table
% OUTPUT:
% pa = positive agreement
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pa = positive_agreement(table)

    [no_rows,no_cols] = size(table);
    assert(no_rows == 2 & no_cols == 2,'Table is not square 2x2');
    
    pa = 2 * table(1)/(2*table(1) + table(1,2) + table(2,1));

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% strjoin
% Joins together the strings in cellstring labels
% together with delimiter. Local version for older
% Matlab version as newer versions contain this function.
% INPUT:
% labels = cellstring
% delimiter = should be between strings
% OUTPUT:
% s = joint string
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = strjoin(labels,delimiter)

    assert(iscellstr(labels),'strjoin only works with cellstrings.');
    no_labels = numel(labels);
    s = '';
    for i = 1:no_labels-1
        s = cat(2,s,labels{i},delimiter);
    end
    s = cat(2,s,labels{end});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_save_handle
% Wrapper function to retrieve only valid
% getappdata handles.
% INPUT:
% OUTPUT:
% SIDEEFFECTS:
% Exception can be thrown
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = get_save_handle(h_fig,handle_name)

    h = getappdata(h_fig,handle_name);
    assert(~isempty(h),'Couldn''t retrieve valid handle: %s\n', ...
        handle_name);

end
