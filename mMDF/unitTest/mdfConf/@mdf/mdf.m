classdef mdf

  methods (Static)

    function outdata = fromJson(indata)
      % outdata = mdf.toJson(indata)
      %
      % convert json to matlab structure
      %

      % check which jsonlibrary is available
      if (exist('jsondecode') == 5)
        outdata = jsondecode(indata);
      else
        outdata = loadjson(indata);
      end %if

    end %function

  end %method

end
