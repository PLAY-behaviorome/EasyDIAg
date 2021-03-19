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

function square = reduce_mapping_to_single_square(mapping,threshold,no_types)
% reduce_mapping_to_single_square
% Reduce the mappings between annotations to a 2x2 square
% using the scoring algorithm developed by Holle & Rein.
% Square can be subsequently used to calculate Cohen's kappa.
% INPUT:
% r1        = annotation from rater 1
% r2        = annotation from rater 2
% mapping   = mapping between annotations
%               one single square with no_type + 1 cols and rows
%               +1 is for not matched (either no annotation or not
%                                   sufficient overlap).
% threshold = overlap scoring
% no_types  = number of different units, if not provided is estimated
%               from data.
% OUTPUT:
% squares = 2x2 table
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3
    types = unique([mapping(:,4);mapping(:,5)]);
    types = types(~isnan(types));
    no_types = numel(types);
end

if nargin < 2
    threshold = 0.6;
end

no_mappings = size(mapping,1);
no_match = no_types + 1;
square = zeros(no_match);

try
    for m = 1:no_mappings
       m1 = mapping(m,4);
       m2 = mapping(m,5);
       % mark unmatched annotations from rater 1
       if isnan(m1)
           square(no_match,m2) = square(no_match,m2) + 1;
           continue
       end
       % mark unmatched annotations from rater 2
       if isnan(m2)
           square(m1,no_match) = square(m1,no_match) + 1;
           continue
       end
       % mark matched annotations
       if mapping(m,3) >= threshold
           % same units by both raters
           % Following the approach used in GSEQ 5.1
           % <http://www2.gsu.edu/~psyrab/gseq/index.html>
           % matched entries are scored double
           square(m1,m2) = square(m1,m2) + 2;
       else
           % different units between raters
           square(m1,no_match) = square(m1,no_match) + 1;
           square(no_match,m2) = square(no_match,m2) + 1;
       end
    end
catch ME
    display(getReport(ME));
end
