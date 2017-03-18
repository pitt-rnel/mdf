function res = assH(obj,indata)
    % function res = obj.assH(indata)
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


    % key
    % group.object.component
    %
    % Examples
    % - saves everything related to vmd group in this habitat
    %   it does not separate def, metadata and data
    % > vmd.mdf_all.mdf_all -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c
    %
    % - saves def and metadata for every object in this habitat
    %   def and metadata will be saved in the same document
    % > vmd.mdf_all.mdf_dmd -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c
    %
    % - save all data property for every object in the habitat
    %   all the data properties are saved in the same document
    % > vmd.mdf_all.mdf_data -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c
    %
    % - save def and metadata for object type "ql_message" in the habitat
    % > vmd.ql_message.mdf_dmd -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c
    %
    % - save only data property, all in separate documents
    % > vmd.ql_message.mdf_data.mdf_individual -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c
    %
    % - save only data property named wf of mdf object type ql_message in the documents
    % > vmd.ql_message.mdf_data.wf -> 1ec528de-f5ee-4ecd-be3f-3fae08ebf65c

    res = {};

    % loops on all the habitats
    for i1 = [1:length(obj.configuration)]

        % extract habitat
        hab = obj.configuration{i1};

        % prepare selector string and habuuid
        for i2 = [1:length(hab.objects.object)]
            for i3 = [1:length(hab.components.component)]
            
                % connection string:
                % group.object.component[:data-prop]
                res{end+1} = [ ...
                    hab.group '.' ...
                    hab.objects.object{i2} '.' ...
                    hab.components.component{i3} ];

            end %for

        end %for

    end % for

end %function
