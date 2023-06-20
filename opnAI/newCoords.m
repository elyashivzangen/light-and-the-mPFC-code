function newCoords = convert2Dto3D(coords2D, point1, point2, point3)
% convert2Dto3D converts 2D coordinates to 3D coordinates using 3 reference points
% in 3D space
%
%   coords2D: a Nx2 matrix of 2D coordinates to be converted to 3D
%   point1: a 1x3 vector representing the 3D coordinates of the first reference point
%   point2: a 1x3 vector representing the 3D coordinates of the second reference point
%   point3: a 1x3 vector representing the 3D coordinates of the third reference point
%
%   newCoords: a Nx3 matrix of 3D coordinates corresponding to the input 2D coordinates

% Calculate the plane formed by the 3 reference points
normal = cross(point2 - point1, point3 - point1);
d = -dot(normal, point1);

% Convert each 2D point to 3D using the plane equation
newCoords = zeros(size(coords2D, 1), 3);
for i = 1:size(coords2D, 1)
    % Solve for the third coordinate using the plane equation
    z = (-d - normal(1)*coords2D(i,1) - normal(2)*coords2D(i,2))/normal(3);
    newCoords(i,:) = [coords2D(i,1), coords2D(i,2), z];
end
end