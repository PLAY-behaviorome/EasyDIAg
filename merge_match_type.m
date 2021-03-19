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

function mmap = merge_match_type(mapping,r1,r2)
% merge_match_type
% Combines match information with type and rater
% unit type information.
% INPUT:
% mapping = from match_annotations
% r1 = rater 1 annotations
% r2 = rater 2 annotations
% OUTPUT:
% mmap = merge mappings with type
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m,n] = size(mapping);
mmap = NaN(m,n+2);
mmap(:,1:3) = mapping;

% add rater 1 type information
idx = ~isnan(mapping(:,1));
mmap(idx,4) = r1(mapping(idx,1),3);

% add rater 2 type information
idx = ~isnan(mapping(:,2));
mmap(idx,5) = r2(mapping(idx,2),3);
