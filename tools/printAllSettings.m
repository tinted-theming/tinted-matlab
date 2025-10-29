%% Print Matlab settings tree.
%% Does not print hidden settings

function printAllSettings()
%PRINTALLSETTINGS Recursively prints all MATLAB settings and their values/types.
root = settings;
fprintf('MATLAB Settings Tree:\n');
traverseSettingsGroup(root, "");
end

function traverseSettingsGroup(group, prefix)
% Recursively traverse settings groups and print settings info

groupNames = fieldnames(group);
for i = 1:numel(groupNames)
    item = group.(groupNames{i});
    name = groupNames{i};

    if isa(item, 'matlab.settings.SettingsGroup')
        % Print group header
        fprintf('%s[%s]\n', prefix, name);
        traverseSettingsGroup(item, prefix + "  ");

    elseif isa(item, 'matlab.settings.Setting')
        % Try to get ActiveValue and class
        try
            val = item.ActiveValue;
            cls = class(val);
            % Make value printable
            if isnumeric(val)
                valStr = mat2str(val);
            elseif ischar(val)
                valStr = val;
            elseif isstring(val)
                valStr = char(val);
            elseif islogical(val)
                valStr = string(val);
            elseif iscell(val)
                valStr = sprintf('{%s}', strjoin(string(cellfun(@toStr, val, 'UniformOutput', false)), ', '));
            else
                valStr = sprintf('<%s object>', cls);
            end
        catch
            valStr = '<unavailable>';
            cls = '<unknown>';
        end

        % Print setting name, value, and type
        fprintf('%s%s = %s  (%s)\n', prefix, name, valStr, cls);

    else
        fprintf('%s%s <unknown type>\n', prefix, name);
    end
end
end

function s = toStr(v)
% Helper: make a short printable string from a value
if isnumeric(v)
    s = mat2str(v);
elseif ischar(v)
    s = v;
elseif isstring(v)
    s = char(v);
elseif islogical(v)
    s = string(v);
else
    s = class(v);
end
end
