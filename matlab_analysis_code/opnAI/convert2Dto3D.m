function coords3D = convert2Dto3D(coords2D, coords2D_common, coords3D_common)
  % Extract the number of points
  nPoints = size(coords2D,1);

  % Preallocate the 3D coordinates matrix
  coords3D = zeros(nPoints,3);

  % Solve for the transformation equations using the 2D and 3D common points
  A = [coords2D_common ones(size(coords2D_common,1),1)];
  B = coords3D_common;
  X = A\B;

  % Loop through each point
  for i = 1:nPoints
    % Extract the current 2D point
    a = coords2D(i,1);
    b = coords2D(i,2);

    % Transform the 2D point to 3D using the transformation equations
    x = X(1)*a + X(2)*b + X(3);
    y = X(4)*a + X(5)*b + X(6);
    z = X(7)*a + X(8)*b + X(9);

    % Store the 3D point in the 3D coordinates matrix
    coords3D(i,:) = [x,y,z];
  end 
end
