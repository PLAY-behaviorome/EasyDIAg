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


function [kappa,var,ci] = Cohenskappa(mat,weights)
% Cohenskappa
% Calculates the standard Cohenskappa statistic according to Cohen (1960).
% INPUT:
% mat       = contingency table
% weights   = weighting matrix (optional)
% OUTPUT:
% kappa = Cohen's kappa bound by zero
% var   = variance
% ci    = confidence interval
% Test
%
%mat = [ 53 5 2;
%        11 14 5;
%        1 6 3 ];
% kappa = 0.429    
%%%%%%%%%%%%%%%%%%%%

assert( size(mat,1) == size(mat,2),'Cohenskappa: matrix must be square');


if nargin == 1
    weights = ones(size(mat));
    for i = 1:size(mat,1)
        weights(i,i) = 0;
    end
end

n = sum(sum(mat));

pObs = mat/n;
pExp = sum(pObs,2)*sum(pObs,1);
qo = sum(sum(weights.*pObs));
qe = sum(sum(weights.*pExp));
kappa = 1 - qo/qe;
if ( kappa < 0 )
    kappa = 0;
end

tmp1 = sum(sum(weights.^2 .* pObs));
tmp2 = sum(sum(weights .* pObs))^2;
tmp3 = sum(sum(weights .* pExp))^2;

var = sqrt( (tmp1 - tmp2)/(n*tmp3) ) ;
ci = [kappa - 1.96*var, kappa + 1.96*var];

