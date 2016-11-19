function label = kmeans(X, k, label)
% Perform k-means clustering.
%   X: d x n data matrix  (d: the number of features)
%   k: number of seeds
% Written by Michael Chen (sth4nth@gmail.com).
% http://www.mathworks.com/matlabcentral/fileexchange/24616
% in this function we should give the initial values to start clustering 
n = size(X,2);
last = 0;
%label = ceil(k*rand(1,n));  % random initialization
while any(label ~= last)
    [u,~,label] = unique(label);   % remove empty clusters
    k = length(u);
    E = sparse(1:n,label,1,n,k,n);  % transform label into indicator matrix
    m = X*(E*spdiags(1./sum(E,1)',0,k,k));    % compute m of each cluster
    last = label;
    [~,label] = max(bsxfun(@minus,m'*X,dot(m,m,1)'/2),[],1); % assign samples to the nearest centers
end
[~,~,label] = unique(label);
