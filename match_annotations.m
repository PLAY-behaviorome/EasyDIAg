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

function mapping = match_annotations(map)
% match_annotations
% INPUT:
% map = sparse overlap matrix
% OUTPUT:
% mapping = mapping beteen annotations
%        [idx_rater1 idx_rater2 overlap]
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

assert(issparse(map),'Map should be a sparse matrix');
[r1i,r2i,overlap] = find(map);

% pre-allocate results matrix
mapping = NaN(max(size(map))*3,3);
counter = 1;

% determine entries withouth any overlap
% for r1
% problem with empty matrix
test = ~any(map,2);

% Additional testing condition to infer
% whether r1 or r2 are nonempty
if ( nnz(test) && size(map,1) )
    i = find(test);
    no_overlaps = numel(i)-1;
    mapping(counter:counter+no_overlaps,1) = i;
    counter = counter + no_overlaps + 1;
end
% for r2
test = ~any(map);
if ( nnz(test) && size(map,2) )
    [i,j] = find(test);
    no_overlaps = numel(j)-1;
    mapping(counter:counter+no_overlaps,2) = j;
    counter = counter + no_overlaps + 1;
end

% matching up annotations
while ( any(overlap>0) && counter < size(mapping,1))
    
    % determine maximum value
    [max_value,max_id] = max(overlap);
    tmp_r1i = r1i(max_id);
    tmp_r2i = r2i(max_id);
    
    % store value
    mapping(counter,:) = [tmp_r1i,...
        tmp_r2i,...
        max_value];
    counter = counter + 1;
    
    % mark overlap dirty
    overlap(max_id) = -13;    
    overlap(r1i == tmp_r1i) = -13;
    overlap(r2i == tmp_r2i) = -13;
    
end % while

% unmatched objects
[no_r1,no_r2] = size(map);
no_nan_r1 = ~isnan(mapping(:,1));
no_nan_r2 = ~isnan(mapping(:,2));

no_match_r1 = setdiff(1:no_r1,mapping(no_nan_r1,1));
no_match_r2 = setdiff(1:no_r2,mapping(no_nan_r2,2));

mapping(counter:(counter+numel(no_match_r1)-1),1) = no_match_r1;
counter = counter + numel(no_match_r1);
mapping(counter:(counter+numel(no_match_r2)-1),2) = no_match_r2;
counter = counter + numel(no_match_r2);

% discard superflous rows
mapping(counter:end,:) = [];

%mapping = mapping(1:(find(all(isnan(mapping')),1)-1),:);
mapping = sortrows(mapping);

