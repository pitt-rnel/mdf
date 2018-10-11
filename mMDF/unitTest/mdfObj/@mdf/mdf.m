classdef (Sealed) mdf < handle

    methods (Static)
        
        function [uuid,obj] = getUAO(indata)
            if isa(indata,'mdfObj')
                uuid = indata.uuid;
                obj = indata;
            else
                % get mdf manage andsee if we need to load it
                om = mdfManage.getInstance();
                uuid = indata;
                obj = om.get(uuid);
                if isempty(obj)
                    obj =mdfObj.load(uuid);
                end %if
            end %if
        end %function

        function uuid = UUID()
            uuid = char(java.util.UUID.randomUUID);
        end %function

        function outdata = toJson(indata)
            % outdata = mdf.toJson(indata)
            %
            % convert matlab structure to json
            %

            % we need to get the configuration object
            oc = mdfConf.getInstance(); 

            % convert according
            switch (oc.getConstant('MDF_JSONAPI'))
                case 'MATLAB'
                    outdata = char(jsonencode(indata));
                case 'JSONLAB'
                    outdata = savejson('',indata);
            end %switch    
  
        end %function

        function outdata = fromJson(indata)
            % outdata = mdf.toJson(indata)
            %
            % convert json to matlab structure
            %

            % we need to get the configuration object
            oc = mdfConf.getInstance(); 
   
            % convert according
            switch (oc.getConstant('MDF_JSONAPI'))
                case 'MATLAB'
                    outdata = jsondecode(indata);
                case 'JSONLAB'
                    outdata = loadjson(indata);
            end %switch    

        end %function

        function outdata = c2s(indata)
            % function outdata = mdf.c2s(indata)
            %
            % transform a cell array of homogeneus struct in to an a array of
            % struct
            % it is needed and it is useful because conversion from json and yaml
	    % to matlab internal data, sometimes structures becomes cell arrays
	    %
	    % input
	    % - indata: cell array of structures equelly defined
	    %
	    % output
	    % - outdata: array of struct containing the same data
	    %
    
	    outdata = indata;
	    if isa(indata,'cell')
		% due to data type conversion, mdf_parents is a cell
		% we want an array of struct
		first = true;
		outdata = [];
		for j = 1:length(indata)
		    if first
			% first iteraction, define new structure
			outdata = indata{j};
			first = false;
		    else
			% sebsequent iteractions, append at the end
			outdata(end+1) = indata{j};
		    end %if
               end %for
           end %for
       end %function

    end %methods

end %classdef
