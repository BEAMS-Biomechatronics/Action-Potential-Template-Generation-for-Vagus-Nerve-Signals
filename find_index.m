function iPoint = find_index(point_x, point_z, x, z)
x_indices = find(round(x,7)==round(point_x,7));
z_indices = find(round(z,7)==round(point_z,7));
iPoint = intersect(x_indices, z_indices);
end