function p = refinePath(p)
    % function p = refinePath(p)
    %
    % p = file or folder path
    %
    % for some reason matworks decided to remove .. substitution from fullfile
    % this is the function that was used in 2014b
    %
    fs = filesep;
    p = strrep(p, '/', fs);
    singleDotPattern = [fs, '.', fs];
    p = strrep(p, singleDotPattern, fs);
    multipleFileSepPattern = [fs, fs];
    if ~isempty(strfind(p, multipleFileSepPattern))
        p = replaceMultipleFileSeps(p);
    end
    doubleDotPattern = [fs, '..', fs];
    if ~isempty(strfind(p, doubleDotPattern))
        p = replaceDoubleDots(p);
    end
end

function p = replaceMultipleFileSeps(p)
    fsEscape = ['\', filesep];
    multipleFileSepRegexpPattern = ['(?<!^(\w+:)?' fsEscape '*)', fsEscape, fsEscape '+'];
    p = regexprep(p, multipleFileSepRegexpPattern, filesep);
end

function p = replaceDoubleDots(p)
    fsEscape = ['\', filesep];
    currentFormat = '';
    doubleDotRegexpPattern = ['(', fsEscape,'|^)(?!(\.\.?|^\w+:)', fsEscape,')[^', fsEscape,']+', fsEscape,'\.\.(\1)?(?(2)|', fsEscape,'|$)'];
    while ~strcmp(currentFormat, p)
        currentFormat = p;
        p = regexprep(p,doubleDotRegexpPattern,'$2');
    end
end
