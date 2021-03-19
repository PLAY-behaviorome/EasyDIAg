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


function [kappa,kappa_max,p0] = ckappa(mat)
% Calculates the Cohenskappa statistic using expected probabilites 
% obtained through iterative proportional fitting. 
% The algorithm assumes that mat has a structural zero at position mat(end,end)
% INPUT:
% mat       = contingency table
% OUTPUT:
% kappa     = kappa value
% kappa_max = maximum kappa value according to equ. 6
% p0        = raw agreement
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%

assert( size(mat,1) == size(mat,2),'Cohenskappa: matrix must be square');

N = sum(sum(mat));
p0 = sum(diag(mat))/N;

mat_hat = ones(size(mat));
mat_hat(end,end) = 0;
ipf_mat = ipf(sum(mat),sum(mat,2),mat_hat);
pe = sum(diag(ipf_mat))/N;

% ipf kappa
kappa = max(0,(p0 - pe)/(1 - pe));

% kappa_max
row_sum = sum(mat);
col_sum = sum(mat,2)';
min_sum = min([row_sum;col_sum]);
poM = sum(min_sum)/N;
kappa_max = (poM-pe)/(1-pe);

