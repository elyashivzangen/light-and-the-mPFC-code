function coords3D = convert2Dto3D5(points2D, indices, points3D)
    % points2D: Nx2 matrix of 2D coordinates
    % indices: Nx1 vector of indices into points2D
    % points3D: Mx3 matrix of 3D reference points
    %
    % coords3D: Nx3 matrix of 3D coordinates corresponding to the 2D points

    % Extract the 2D points corresponding to the indices
    referencePoints2D = points2D(indices, :);
    
    % Solve for the 3D coordinates using least squares
    A = [referencePoints2D ones(size(referencePoints2D, 1), 1)];
    b = points3D;
    xyz = (A'*A)\(A'*b);
    xyz = (A'*A)\(A'*b)
    % Extract the 3D coordinates from the solution
    coords3D = [xyz(1, :); xyz(2, :); xyz(3, :)]';
end

