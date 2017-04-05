function [total,used,free] = memoryUsage()
    % function [total,used,free] = memoryUsage()
    %
    % returns memory usage
    %
    % output
    % - total: total memory available in bytes
    % - used: used memory in bytes
    % - free: free memeory in bytes
    %
    
    total = nan;
    used = nan;
    free = nan;
    
    if ispc()
        % under windows, we can use the function "memory"
        % We care only about the physical memory usage
        % and we find it under the following output keys
        % - Available memory -> sys.PhysicalMemory.Available
        % - Total memory	 -> sys.PhysicalMemory.Total
        %
        [~,sys] = memory;
        %
        % transfer values in output variables
        total = sys.PhysicalMemory.Total;
        free = sys.PhysicalMemory.Available;
        used = total - free;
        
    elseif isunix()
        % run a system command.
        % matlab does not have function to track memory usage under *nix
        % systems
        %
        % > free
        %           total       used       free     shared    buffers     cached
        % Mem:      16382792   13919156    2463636     145680    1076532    5017920
        % -/+ buffers/cache:    7824704    8558088
        % Swap:     16727036     450408   16276628
        %
        % we use the physical memory, fields 1 to 3
        %
        try
            [~, temp1] = system('free -b | grep Mem | sed "s/  */,/g" | cut -d, -f2,3,4');
            % split string at comma
            temp2 = cellfun(@(x) str2num(x),strsplit(temp1,','));
            % save values in oputput variables
            total = temp2(1);
            used = temp2(2);
            free = temp2(3);
        catch
            total = 0;
            used = 0;
            free = 0;
        end %try/catch
        
    else
        throw( ...
            MException( ...
                'mdf:memoryUsage', ...
                'Unsupported platform'));
    end %if

end %function