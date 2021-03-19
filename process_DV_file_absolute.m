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

function [squares,global_square] = process_DV_file(anno_file, threshold )
% process_Datavyu_file
% Just a glorified wrapper for the different processing files used
% with the Datavyu structure.
% anno_file.data = [start end type, tier, filename, rater]
% INPUT:
% anno_file     = annotation structure from load_DV_file
% threshold     = overlap threshold {default = 0.6}
% OUTPUT:
% squares       = [2 x 2 x number of units] array with results
% global_square = global matching square
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin == 1
        threshold = 0.6;
    end

    % extract specs from Datavyu struct
    no_units = numel(anno_file.units);
    no_tiers = numel(anno_file.tiers);
    no_files = numel(anno_file.files);

    % result arrays
    squares = zeros(2,2,no_units);
    global_square = zeros(no_units+1);
    
    % indecies for rater 1 and rater 2
    % pre-calculated as needed multiple times
    idx_r1 = anno_file.data(:,6) == 1;
    idx_r2 = anno_file.data(:,6) == 2;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculating global agreement summed over all
    % files and all tiers
    for t = 1:no_tiers 
        for f = 1:no_files
            idx = anno_file.data(:,4) == t & ...
               anno_file.data(:,5) == f;
            r1 = anno_file.data(idx & idx_r1,1:3);
            r2 = anno_file.data(idx & idx_r2,1:3);
            global_square = global_square + agreement_facade(r1,r2,threshold,no_units );
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculating sub agreement tables for
    % kappa for each unit using the global
    % agreement matrix
    for unit = 1:no_units
        
        tmp_total   = sum(sum(global_square));
        tmp_ag      = global_square(unit,unit);
        tmp_row_dis = sum(global_square(unit,:)) - tmp_ag;
        tmp_col_dis = sum(global_square(:,unit)) - tmp_ag;
        
        squares(1,1,unit) = tmp_ag;
        squares(1,2,unit) = tmp_row_dis;
        squares(2,1,unit) = tmp_col_dis;
        squares(2,2,unit) = tmp_total - tmp_row_dis - tmp_col_dis - tmp_ag;
        
    end

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
% square   = no_units + 1 x no_units + 1 agreement table
% SIDEEFFECTS:
% None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function square = agreement_facade(r1,r2, threshold, no_types )

    % MODIFICATION
    %map = gen_overlap_map(r1,r2);    
    map = gen_overlap_map_absolute(r1,r2);
    match = match_annotations(map);
    mapping = merge_match_type(match,r1,r2);
    square = reduce_mapping_to_single_square(mapping,threshold,no_types );

end
