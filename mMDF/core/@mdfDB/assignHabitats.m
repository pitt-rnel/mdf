function res = assignHabitats(obj,indata)
    % function res = obj.assignHabitats(indata)
    % 
    % return which habitat handle which data
    % mdf object use this function to assign their components to specific habitats
    %
    % input
    % - indata : ?
    %
    % output
    % - res : ?
    %

        %
        % <habitat>
        %  <uuid>1ec528de-f5ee-4ecd-be3f-3fae08ebf65c</uuid>
        %  <name>mdf test files repo</name>
        %  <connector>mdf_yaml</connector>
        %  <type>files</type>
        %  <mode>batch</mode>
        %  <access>rw</access>
        %  <base relative_path_to="DATA_BASE"></base>
        %  <group>vmd</group>
        %  <components>
        %   <component>mdf_all</component>
        %  </components>
        %  <objects>
        %   <object>mdf_all</object>
        %  </objects>
        % </habitat>
        % <habitat>
        %  <uuid>1ec528de-f5ee-4ecd-be3f-3fae18ebf65c</uuid>
        %  <name>mdf test collection 1</name>
        %  <loadOnInit>true</loadOnInit>
        %  <connector>mdf_mongodb</connector>
        %  <type>db</type>
        %  <mode>live</mode>
        %  <access>rw</access>
        %  <host>localhost</host>
        %  <port>27017</port>
        %  <database>mdf_test</database>
        %  <collection>mdf_test_1</collection>
        %  <group>vmd</group>
        %  <components>
        %   <component>mdf_def_metadata</component>
        %  </components>
        %  <objects>
        %   <object>mdf_all</object>
        %  </objects>
        % </habitat>
        %


end %function
