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

% Check if we are running in New Desktop in R2024 or R2023
if isMATLABReleaseOlderThan("R2025a") && rendererinfo().GraphicsRenderer == "WebGL"
    error("This function is not compatible with the New Desktop beta add-on in Matlab releases older than R2025a")
end

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
data = mixBgHighlight(data);

fprintf("Color scheme %s by %s applied.\n", data.ColorSchemeName, data.ColorSchemeAuthor);
if isMATLABReleaseOlderThan("R2025a")
    applySettingsStruct(root.matlab, data.matlab, "matlab");
    preferences("Colors")
    fprintf("Matlab < R2025a detected: Click 'OK' in the preferences window to finish applying the theme.\n");
else
    applyColorSettingsR2025(root.matlab, data.matlab);
end
end

function newStruct = mixBgHighlight(jsonColorsStruct)
% Mix highlight background colors with the base background color in order
% to produce highlight color that produces a reasonable contrast with the
% foreground (text) color.
bgcolor = jsonColorsStruct.matlab.colors.BackgroundColor;
autofixColor = jsonColorsStruct.matlab.colors.programmingtools.AutofixHighlightColor;
variablehlColor = jsonColorsStruct.matlab.colors.programmingtools.VariableHighlightColor;

alpha = 0.4;
newStruct = jsonColorsStruct;
newStruct.matlab.colors.programmingtools.AutofixHighlightColor = ...
    (1 - alpha) * bgcolor + alpha * autofixColor;
newStruct.matlab.colors.programmingtools.VariableHighlightColor = ...
    (1 - alpha) * bgcolor + alpha * variablehlColor;
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

function [exists, value] = getStructPath(s, path)
%GETSTRUCTPATH  Recursively resolve a dotted field path in a struct
%
%   [exists, value] = getStructPath(s, path)
%
%   s     : struct to search
%   path  : string or char, e.g. ".colors.commandwindow.HyperlinkColor"
%
%   exists: logical true if the path exists
%   value : value at the path if it exists, [] otherwise

    arguments
        s (1,1) struct
        path {mustBeTextScalar}
    end

    % Normalize path: remove leading dot if present
    path = char(path);
    if startsWith(path, '.')
        path = path(2:end);
    end

    % Split first field from remainder
    parts = split(path, '.');
    head  = parts{1};

    % Base failure
    if ~isfield(s, head)
        exists = false;
        value  = [];
        return
    end

    % Base success
    if isscalar(parts)
        exists = true;
        value  = s.(head);
        return
    end

    % Recursive descent
    next = s.(head);
    if ~isstruct(next)
        exists = false;
        value  = [];
        return
    end

    tail = strjoin(parts(2:end), '.');
    [exists, value] = getStructPath(next, tail);
end

function [exists, hexColor] = getStructPathColorHex(s, path)
% Get value from struct path, check if it is a valid color, and convert to
% hex color format.

[exists, value] = getStructPath(s, path);

if isnumeric(value) && numel(value) == 3
    hexColor = lower(rgb2hex(reshape(value, 1, 3) / 255));
else
    % Value does not match a [R, G, B] color
    exists = false;
    hexColor = [];
end
end

function set_json_colors(setting_obj, matlab_theme, scheme, fieldsDict)
% Set color values in a Setting object which takes a json string as value,
% with each key in the json representing a color.

if isempty(setting_obj.ActiveValue)
    setting_struct = struct;
else
    setting_struct = jsondecode(setting_obj.ActiveValue);
end

if isfield(setting_struct, matlab_theme)
    s = setting_struct.(matlab_theme);
else
    s = struct;
end

color_fields = fieldsDict.keys;
for fieldName = color_fields'
    scheme_path = fieldsDict(fieldName);
    [exists, colorValue] = getStructPathColorHex(scheme, scheme_path);
    if exists
        s.(fieldName) = colorValue;
    else
        warning("Color setting not found in scheme file: %s", src_path)
    end
end

setting_struct.(matlab_theme) = s;
setting_obj.PersonalValue = jsonencode(setting_struct);

end

function applyColorSettingsR2025(root, scheme_struct)
% Apply color settings for version R2025a+
%
% It appears that in Matlab R2025+, the color settings are not defined in
% "flat" Settings objects like in previous versions (2018-2024), where the
% values are single [R G B] arrays.
%
% Instead, many colors are "grouped" together in a single Settings object,
% stored encoded as a JSON string, where the keys are the setting names and
% the values are colors defined in lower-case hex format ("#ffffff"). These
% JSON strings each store two color variants, for the dark and light desktop
% theme.

% Get currently active Matlab Desktop theme (light or dark)
% We will apply the color settings to the currently active theme.
theme = lower(root.appearance.MATLABTheme.ActiveValue);

syntaxColorsDict = dictionary( ...
    "KeywordColor",                     ".colors.KeywordColor", ...
    "CommentColor",                     ".colors.CommentColor", ...
    "StringColor",                      ".colors.StringColor", ...
    "UnterminatedStringColor",          ".colors.UnterminatedStringColor", ...
    "SystemCommandColor",               ".colors.SystemCommandColor", ...
    "SyntaxErrorColor",                 ".colors.SyntaxErrorColor", ...
    "HyperlinkColor",                   ".colors.commandwindow.HyperlinkColor", ...
    "ErrorColor",                       ".colors.commandwindow.ErrorColor", ...
    "WarningColor",                     ".colors.commandwindow.WarningColor", ...
    "CodeAnalyzerWarningColor",         ".colors.programmingtools.CodeAnalyzerWarningColor", ...
    "AutofixHighlightColor",            ".colors.programmingtools.AutofixHighlightColor", ...
    "VariableHighlightColor",           ".colors.programmingtools.VariableHighlightColor", ...
    "VariablesWithSharedScopeColor",    ".colors.programmingtools.VariablesWithSharedScopeColor", ...
    "HighlightCurrentLineColor",        ".editor.displaysettings.HighlightCurrentLineColor", ...
    "LineColor",                        ".editor.displaysettings.linelimit.LineColor", ...
    "CodeColor",                        ".colors.ForegroundColor", ...
    "NormalColor",                      ".colors.ForegroundColor" ...
);

desktopColorsDict = dictionary( ...
    "ForegroundColor", ".colors.ForegroundColor", ...
    "BackgroundColor", ".colors.BackgroundColor" ...
);

plangs_dictionaries = dictionary;

plangs_dictionaries("cpp") = dictionary( ...
    "CharactersColor"             , ".cpp.CharactersColor", ...
    "CommentColor"                , ".cpp.CommentColor", ...
    "KeywordColor"                , ".cpp.KeywordColor", ...
    "PreprocessorColor"           , ".cpp.PreprocessorColor", ...
    "StringsColor"                , ".cpp.StringsColor" ...
);

plangs_dictionaries("html") = dictionary( ...
    "AttributeNameColor"          , ".html.AttributeNameColor", ...
    "AttributeValueColor"         , ".html.AttributeValueColor", ...
    "CdataSectionColor"           , ".html.CdataSectionColor", ...
    "CharacterColor"              , ".html.CharacterColor", ...
    "CommentColor"                , ".html.CommentColor", ...
    "DoctypeDeclarationColor"     , ".html.DoctypeDeclarationColor", ...
    "ErrorColor"                  , ".html.ErrorColor", ...
    "ProcessingInstructionColor"  , ".html.ProcessingInstructionColor", ...
    "TagColor"                    , ".html.TagColor" ...
);

plangs_dictionaries("java") = dictionary( ...
    "CharactersColor"             , ".java.CharactersColor", ...
    "CommentColor"                , ".java.CommentColor", ...
    "KeywordColor"                , ".java.KeywordColor", ...
    "StringsColor"                , ".java.StringsColor" ...
);

plangs_dictionaries("tlc") = dictionary( ...
    "CommentColor"                , ".tlc.CommentColor", ...
    "KeywordColor"                , ".tlc.KeywordColor", ...
    "MacroColor"                  , ".tlc.MacroColor", ...
    "StringsColor"                , ".tlc.StringsColor" ...
);

plangs_dictionaries("verilog") = dictionary( ...
    "CommentColor"                , ".verilog.CommentColor", ...
    "KeywordColor"                , ".verilog.KeywordColor", ...
    "OperatorColor"               , ".verilog.OperatorColor", ...
    "StringColor"                 , ".verilog.StringColor" ...
);

plangs_dictionaries("vhdl") = dictionary( ...
    "CommentColor"                , ".vhdl.CommentColor", ...
    "KeywordColor"                , ".vhdl.KeywordColor", ...
    "OperatorColor"               , ".vhdl.OperatorColor", ...
    "StringColor"                 , ".vhdl.StringColor" ...
);

set_json_colors(root.colors.SyntaxHighlightingColors, theme, scheme_struct, syntaxColorsDict)
set_json_colors(root.colors.DesktopColors, theme, scheme_struct, desktopColorsDict)

plang_names = keys(plangs_dictionaries);
scheme_plangs = scheme_struct.editor.language;
for lang = plang_names'
    sObj = root.editor.language.(lang).SyntaxHighlightingColors;
    set_json_colors(sObj, theme, scheme_plangs, plangs_dictionaries(lang));
end

end
