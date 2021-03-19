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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ipf
% Calculates expected frequencies using iterative proportional fitting.
% INPUT:
% u = row marginals 
% v = column marginals
% m_hat = initial values
% OUTPUT:
% m_hat = matrix with expected frequencies
% SIDEEFFECTS:
% None.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m_hat = ipf(u,v,m_hat)

    if nargin < 3
        m_hat = ones(numel(v),numel(u));
    end
    
    if iscolumn(u)
        u = u';
    end
    if iscolumn(v)
        v = v';
    end
    
    for i = 1:20
    
        r = u./sum(m_hat,2)';
        m_hat = diag(r) * m_hat;
        
        s = v./sum(m_hat);
        m_hat = m_hat * diag(s);
    
    end
    m_hat = m_hat';

end
