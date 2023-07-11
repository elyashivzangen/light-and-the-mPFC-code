function t = struct2table_open(s)
    % Initialize variables
    vars = fieldnames(s);
    n = length(vars);
    nested_vars = fieldnames(s.(vars{1}));
    m = length(nested_vars);
    t = table;

    % Iterate over each field of the structure
    for i = 1:n

        % Get the field name and its contents
        var_name = vars{i};
        var_values = s.(var_name);

        % Make sure the field is a structure
        if isstruct(var_values)
            % Get the field names of the nested structure
            nested_vars = fieldnames(var_values);
            m = length(nested_vars);

            % Iterate over each nested field and add its contents to the table
            for j = 1:m
                nested_var_name = nested_vars{j};
                t.(nested_var_name){i} = var_values.(nested_var_name);
            end
        else
            % If the field is not a structure, add its contents directly to the table
            t.(var_name) = var_values;
        end
    end
    t.Properties.RowNames = vars;
end
