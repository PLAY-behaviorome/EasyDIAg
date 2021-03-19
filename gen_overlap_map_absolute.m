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

function map = gen_overlap_map_absolute(r1,r2,ref)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_overlap_map
% Generates an overlap map
% Only diagnoal + upper triangle are further used.
% The overlap between two annotations is calculated according
% to the proportion of the smaller to larger annotation.
% INPUT:
% r1    = Rater 1 scoring
% r2    = Rater 2 scoring
% ref   = reference for overlap 1 = larger {default}, 0 = smaller
% OUTPUT:
% map = sparse overlap matrix
% SIDEEFFECTS
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ( nargin == 2 )
        ref = 1;
    end

    no_annotations_r1 = size(r1,1);
    no_annotations_r2 = size(r2,1);
    max_anno = max(no_annotations_r1,no_annotations_r2);
    map = sparse([],[],[],no_annotations_r1,no_annotations_r2,...
        max_anno*3);

    % calculate overlap between all annotations
    % and arrange in sparce matrix
    for i = 1:no_annotations_r1
       for j = 1:no_annotations_r2
            if ( check_overlap(r1(i,1:2),r2(j,1:2)) )
                if ref
                    map(i,j) = calculate_overlap(r1(i,1:2),r2(j,1:2));
                else
                    map(i,j) = calculate_overlap_small(r1(i,1:2),r2(j,1:2));
                end
            end
       end
    end
    
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checks whether two annotations overlap
% INPUT:
% anno1 = annotation [start end] time
% anno2 = annotation [start end] time
% OUTPUT:
% b = Boolean value 1 = overlap, 0 = don't overlap
% SIDEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function b = check_overlap(anno1,anno2)

    if ( (anno1(1) >= anno2(1) && anno1(1) <= anno2(2)) || ...
         (anno1(1) <= anno2(2) && anno1(2) >= anno2(2)) || ...
         (anno1(2) >= anno2(1) && anno1(2) <= anno2(2)) )
        b = 1;
    else
        b = 0;
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the overlap based on the length
% of the longer annotation
% INPUT:
% anno1 = annotation [start end] time
% anno2 = annotation [start end] time
% OUTPUT:
% p = overlap (%)
% MODIFICATION:
% p_abs = overlap (ms)
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_abs = calculate_overlap(anno1, anno2)
%     p = (min(anno1(2),anno2(2))-max(anno1(1),anno2(1))) / ...
%         max(diff(anno1),diff(anno2));
      % absolute overlap in ms
      p_abs = (min(anno1(2),anno2(2))-max(anno1(1),anno2(1)));
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates the overlap based on the length
% of the smaller annotation
% INPUT:
% anno1 = annotation [start end] time
% anno2 = annotation [start end] time
% OUTPUT:
% p = overlap (%)
% MODIFICATION:
% p_abs = overlap (ms)
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p_abs = calculate_overlap_small( anno1, anno2 )
%     p = (min(anno1(2),anno2(2))-max(anno1(1),anno2(1))) / ...
%         min(diff(anno1),diff(anno2));
      % absolute overlap in ms
      p_abs = (min(anno1(2),anno2(2))-max(anno1(1),anno2(1)));

end
