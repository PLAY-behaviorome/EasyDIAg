%**************************************************
% 	Copyright 2014 by Robert Rein
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

function anno = load_DV_file(filename)
%load_DV_file
% Load the content of an Datavyu file.
% Should be a text-file with start and finish of each annotation
% in milliseconds (tab-delimited)
% INPUT:
% filename      = name of Datavyu export file
% OUTPUT
% annotation    = annotation struct
%               .units = cellstring with unit names
%               .tiers = cellstring with tier names
%               .files = cellstring with file names
%               .data = [start end type, tier, filename, rater]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fid = fopen(filename,'r');
    if ( fid == -1 )
        error('Couldn''t open file');
    end
    
    try
    fprintf('\n\nImporting %s.\n', filename);
    % reading in first line to check whether for sanity checks.
    
    tline = fgetl(fid);    
    first_line_split = regexp(tline,'\t+','split');
    err = import_DV_sanity_check1(first_line_split);
    if ( err )
        err = MException('EasyDIAg:WrongFormat', ...
            'Import file %s has wrong format',filename);
        throw(err);
    end
    
    % Checking whether data is multifile,
    % Tested with the last column,
    % which should contain a file specifier
    if ( isempty(regexp(first_line_split{end},'opf$','ONCE')) )
        % single file
        multfiles = 0;
    else
        multfiles = 1;
    end
    frewind(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Start of algorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % adjust import fileSpecs
    if multfiles
        formatSpec = '%s %d %d %s %s';
    else
        formatSpec = '%s %d %d %s';
    end
    
    % importing data and checking again for sanity
    file_data = textscan(fid,formatSpec,'delimiter','\t','MultipleDelimsAsOne', 1);
    err = import_DV_sanity_check2(file_data);
    if ( err )
        err = MException('EasyDIAg:WrongFormat', ...
            'Import file %s has wrong format',filename);
        throw(err);
    end
    
    % Extracting file names and discarding paths
    if ( multfiles )
        rawFiles = regexp(file_data{5},'[\w]+(?=\.opf$)','match','once');
    else
        % using dummies if only single file data
        [~,file_name,~] = fileparts(filename);
        rawFiles = cellstr(repmat(file_name,numel(file_data{1}),1));
    end
    % extracting remaining annotation data [start end]
    rawTimes = double([file_data{2},file_data{3}]);
    % tier names
    rawTiers = file_data{1};
    % unit names
    rawUnits = file_data{4};
        
    catch ME
        fclose(fid);
        display(getReport(ME));
        throw(ME);
    end
    fclose(fid);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Labeling units in a specific sequence
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    no_annotations = size(rawTimes,1);
    fprintf('Found %g annotations.\n', no_annotations);
    
    % which units are present
    name_unit = sort(unique(rawUnits));
    no_units = numel(name_unit);
    
    
    name_file = sort(unique(rawFiles));
    no_files = numel(name_file);
    
    rawRaters = regexprep(rawTiers,'.*(?=R[1|2])','');
    
    id_rater = (strcmp(rawRaters,'R1')|strcmp(rawRaters,'R2'));
    if ( ~all(id_rater) )
        id_error = find(~id_rater,1);
        msg_string = sprintf('Found tiers with R1|R2 specs.\ne.g. line: %d %s\nExiting...',...           
            id_error,rawRaters{id_error});
        errordlg(msg_string,'Error parsing Datavyu file');
        err = MException('EasyDIAg:WrongFormat', ...
            'Import file %s has wrong format.\nPlease see EasyDIAg documenation.',filename);
        throw(err);
    end
    
    rawTiers = lower(regexprep(rawTiers,'R[1|2]$',''));
    name_tier = sort(unique(rawTiers));
    no_tiers = numel(name_tier);
    
    
    % index vectors for unit type, tier, filename, rater
    unit_ids = zeros(no_annotations,4);
    
    % index units
    for i = 1:no_units
        unit_ids(strcmp(name_unit{i},rawUnits),1) = i;
    end
    
    % index tiers
    for i = 1:no_tiers
        unit_ids(strcmp(name_tier{i},rawTiers),2) = i;
    end
    
    % index files
    for i = 1:no_files
        unit_ids(strcmp(name_file{i},rawFiles),3) = i;
    end
    
    % index raters
    iid = strcmp('R1',rawRaters);
    unit_ids(iid,4) = 1;
    unit_ids(~iid,4) = 2;
    
    anno.units = name_unit;
    anno.tiers = name_tier;
    anno.files = name_file;
    anno.data = cat(2,rawTimes,unit_ids);
    anno.spec = '.data = [start end type tier filename rater]';
    fprintf('\n\n');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sanity check of file based on content of first line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = import_DV_sanity_check1(first_line_split)

    err = 1;
    
    % Checking for right number of columns    
    no_columns = numel(first_line_split);
    if ( no_columns > 5 || no_columns < 4 )
        msg_string = sprintf('%s\n%s %g.\n%s\nReturning ...',...
            'The Datavyu file has not the right format!',...
            'Expected either 4 or 5 columns but found:',...
            no_columns,...
            'Please check Datavyu output. Known bug.');
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    
    % checking for right format
    % first column is string
    if ( ~ischar(first_line_split{1}) )
        msg_string = sprintf('The 1st column doesn''t contain the tiername!\nPlease see EasyDIAg manual.');
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    
    % second and third column should contain beginning and start
    tmp_begin = str2double(first_line_split{2});
    tmp_end = str2double(first_line_split{3});
    if ( ~(isfinite(tmp_begin) && isfinite(tmp_end)) )
        msg_string = sprintf('The 2nd and 3rd columns do not contain numbers!\nPlease see EasyDIAg manual.');
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    % Begin should be greater as end
    if ( tmp_begin > tmp_end )
        msg_string = sprintf('Annotation start is greater compared to annotation end\nPlease see EasyDIAg manual.');
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    
    % fourth column should contain the units
    if ( ~ischar(first_line_split{4}) )
        msg_string = sprintf('The 4th column doesn''t contain the tiername!\Please see EasyDIAg manual.');
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    
    % if present, the fifth column should contain the filename
    if ( no_columns == 5 )
        if ( ~ischar(first_line_split{5}) )
            msg_string = sprintf('The 5th column doesn''t contain the filename!\nPlease see EasyDIAg manual.');
            errordlg(msg_string,'Error loading Datavyu file');
            return
        end
    end
        
    err = 0;
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% import_DV_sanity_check2(data_cell)
% INPUT:
% data_cell = data read in with textscan
% OUTPUT:
% err = error status
% SIDEEFFECTS:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err = import_DV_sanity_check2(data_cell)

    err = 1;
    no_cols = numel(data_cell);
    
    % Checking whether any missing data
    for c = 1:no_cols
        if iscell(data_cell{c})
            tmp_test = cellfun(@isempty,data_cell{c});
        else
            tmp_test = isempty(data_cell{c});
        end
        
        if any(tmp_test)
            first_error_line = find(tmp_test,1);
            msg_string = sprintf('Error loading Datavyu file on line %d\nPlease see EasyDIAg manual.', first_error_line);
            errordlg(msg_string,'Error loading Datavyu file');
            return
        end
    end
    
    % Checking whether start is <= end    
    tmp_test = data_cell{2} <= data_cell{3};
    if ~all(tmp_test)
        first_error_line = find(~tmp_test,1);
        msg_string = sprintf('Error on line start end mixed?%d\nPlease see EasyDIAg manual.', first_error_line);
        errordlg(msg_string,'Error loading Datavyu file');
        return
    end
    
    err = 0;

end
