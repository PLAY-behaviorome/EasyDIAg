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

function squares = reduce_mapping_to_square(mapping,threshold,no_types,version)
% reduce_mapping_to_square
% Reduce the mappings between annotations to a 2x2 square
% using the scoring algorithm developed by Holle & Rein.
% Square can be subsequently used to calculate Cohen's kappa.
% INPUT:
% r1 = annotation from rater 1
% r2 = annotation from rater 2
% mapping = mapping between annotations
% threshold = overlap scoring
% OUTPUT:
% squares = 2x2 table
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 4
    version = 1;
end

if nargin < 3
    types = unique([mapping(:,4);mapping(:,5)]);
    types = types(~isnan(types));
    no_types = numel(types);
end

if nargin < 2
    threshold = 0.6;
end

squares = zeros(2,2,no_types);

for type = 1:no_types
    
    % testing pairs
    
    % both right type    
    idx = mapping(:,4) == type & mapping(:,5) == type;
    
    % overlap sufficient agreement
    % Following the GSEQ approach matching annotations
    % are scored through by adding two to diagonal
    squares(1,1,type) = 2*sum(mapping(idx,3)>=threshold);
    
    % overlap not sufficient two penalties
    squares(2,1,type) = sum(mapping(idx,3)<threshold);
    squares(1,2,type) = squares(2,1,type);
    
    % r1 saw right type
    idx = mapping(:,4) == type & mapping(:,5) ~= type;
    squares(2,1,type) = squares(2,1,type) + sum(idx);
    
    % r2 saw right type
    idx = mapping(:,4) ~= type & mapping(:,5) == type;
    squares(1,2,type) = squares(1,2,type) + sum(idx);
    % end pairs
    
    switch version
        
        case 1 % Most anti-conservative.
            % Everything goes into agreement
            
            % both didn't see right type
            idx = mapping(:,4) ~= type & mapping(:,5) ~= type;
            squares(2,2,type) = sum(idx);
            
        case 2
            % Both didn't see right type but any other type
            % and overlap is satisfied.
            idx = mapping(:,4) ~= type & mapping(:,5) ~= type & ...
                mapping(:,3) > threshold;
            
        case 3
            % Both agree on not seeing type and threshold is satisfied.
            idx = mapping(:,3) > threshold & ...
                mapping(:,4) ~= type &...
                mapping(:,4) == mapping(:,5);
            
    end
    squares(2,2,type) = sum(idx);
    
    
end % type = 1:no_types
