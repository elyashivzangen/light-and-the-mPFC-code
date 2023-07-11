function coords3D = convert2Dto3D(coords2D, coords2D_common, coords3D_common)
  % Extract the number of points
  nPoints = size(coords2D,1);

  % Preallocate the 3D coordinates matrix
  coords3D = zeros(nPoints,3);

  % Fit a transformation from the 2D common points to the 3D common points
  tform = fitgeotrans(coords2D_common, coords3D_common, 'nonreflectivesimilarity');

  % Loop through each point
  for i = 1:nPoints
    % Extract the current 2D point
    x = coords2D(i,1);
    y = coords2D(i,2);

    % Transform the 2D point to 3D using the fitted transformation
    [x3,y3,z3] = transformPointsForward(tform,x,y);

    % Store the 3D point in the 3D coordinates matrix
    coords3D(i,:) = [x3,y3,z3];
  end
end
