function tinted_import(jsonFile)
% TINTED_IMPORT
% Reads a JSON file containing a color scheme and applies the color-related
% settings in Matlab using the `settings` function.
%
% The JSON file should contain a settings tree and the color values
% must be specified as an 8-bit (0-255) RGB triplet array, for example
% `[248, 248, 242]`.
%
% Example:
%   tinted_import("schemes/base16-dracula.json")
%   tinted_import    % -- opens a file picker

% If no file provided, open file picker
if nargin < 1 || isempty(jsonFile)
    [file, path] = uigetfile({'*.json', 'JSON files (*.json)'; '*.*', 'All files'}, ...
        'Select a JSON settings file');
    if isequal(file, 0)
        fprintf('Operation cancelled by user.\n');
        return;
    end
    jsonFile = fullfile(path, file);
end

% Read and parse the JSON
txt = fileread(jsonFile);
data = jsondecode(txt);

if ~isfield(data, "matlab")
    error("'matlab' key not found at the top level of scheme file.");
end

root = settings;
root.matlab.colors.UseSystemColor.PersonalValue = false;
applySettingsStruct(root.matlab, data.matlab, "matlab");

fprintf("Color scheme %s by %s applied.\n", data.ColorSchemeName, data.ColorSchemeAuthor);
if isMATLABReleaseOlderThan("R2025a")
    preferences("Colors")
    fprintf("Matlab < R2025a detected: Click 'OK' in the preferences window to finish applying the theme.\n");
end
end

function applySettingsStruct(currentGroup, jsonStruct, fullPath)
% Recursively apply settings from JSON to MATLAB's settings tree.

fields = fieldnames(jsonStruct);
for i = 1:numel(fields)
    name = fields{i};
    val = jsonStruct.(name);

    if isstruct(val)
        % Recurse into nested groups
        if isprop(currentGroup, name)
            subGroup = currentGroup.(name);
            applySettingsStruct(subGroup, val, fullPath + "." + name);
        else
            fprintf('⚠️  Skipping unknown group: %s.%s\n', fullPath, name);
        end

    elseif isnumeric(val) && numel(val) == 3
        % Apply RGB setting
        if isprop(currentGroup, name)
            try
                currentGroup.(name).PersonalValue = int32(val);
                % fprintf('✅ Updated %s.%s = [%g %g %g]\n', ...
                %     fullPath, name, val(1), val(2), val(3));
            catch ME
                warning('Failed to set %s.%s: %s\n', fullPath, name, ME.message);
            end
        else
            warning('Unknown setting: %s.%s\n', fullPath, name);
        end
    else
        fprintf('Skipping non-RGB value at %s.%s\n', fullPath, name);
    end
end
end
