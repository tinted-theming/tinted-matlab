function reset_colors()
%RESET_COLORS Remove all customized color settings
%   Only supported for MATLAB R2025+ for the moment

if isMATLABReleaseOlderThan("R2025a")
    error("This function only support MATLAB R2025+ for the moment.")
end

root = settings;

root.matlab.colors.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.colors.DesktopColors.PersonalValue = '';
root.matlab.editor.language.c.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.cpp.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.html.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.java.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.javascript.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.json.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.markdown.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.python.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.simscape.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.tlc.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.typescript.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.verilog.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.vhdl.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.xml.SyntaxHighlightingColors.PersonalValue = '';
root.matlab.editor.language.yaml.SyntaxHighlightingColors.PersonalValue = '';
end