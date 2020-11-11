function res = testEnv1()
    % function res = testEnv1()
    %
    % creates a test environment that can be used to test the system or
    % learning environment
    %
    % If the function returns 1, this is the object and structure that you
    % will have in the system
    % .subject: 1
    % ..experiment: 1 --> Sessions+
    % ...trial: 1,2,3 <-----------+
    % ....type of signals:
    % .....emgs
    % ......channel: 1,2,3
    % .subject: 2
    % ..experiment: 1 ----> Sessions+
    % ...trial: 1,2,3,4 <-----------+
    % ....type of signals: 
    % .....emgs:
    % ......channel: 1,2,3,4
    % .....forces:
    % ...... channels: 4 paws
    %
    % than additional objects will be added:
    % - sessions
    % - electrodes
    % - people
    %
    % Input
    %   none
    %
    
    % set output to 0
    res = 0;

    % get mdf path
    % get all the paths
    allpaths = strsplit(path,pathsep);
    % extract mdf path
    corepath = allpaths{cellfun(@(path) ~isempty(strfind(path,['mMDF' filesep 'core'])),allpaths)};
    temp1 = strsplit(corepath,filesep);
    mdfpath = strjoin(temp1(1:end-1),filesep);
    clear temp1
    
    % user folder
    if ispc
        userdir= getenv('USERPROFILE');
    else
        userdir= getenv('HOME');
    end %if
    
    % template test conf file
    tpltestfile = fullfile(mdfpath,'templates','mdf.conf.test.xml');
    % configuration test file
    testconffile = fullfile(userdir,'mdf','conf','mdf.conf.test.env1.xml');
    
    % load template file
    fid = fopen(tpltestfile,'r');
    conf = char(fread(fid,'char')');
    fclose(fid);
    % replace mdf test folder
    conf = strrep(conf,'<TEST_BASE_FOLDER>',userdir);
    % replace mdf code folder
    conf = strrep(conf,'<TEST_CODE_BASE>',mdfpath);
    
    % save test environment configuration
    fid = fopen(testconffile,'w');
    fwrite(fid,conf);
    fclose(fid);
    
    % create data folder
    mkdir(fullfile(userdir,'mdf','data','mdftest'));
    
    % instantiate mdf environment
    omdfc = mdf.init(testconffile);
        
    % insert 2 type of electrodes
    disp('Creating electrodes...');
    % electrode 1
    oele1 = mdfObj;
    oele1.type = 'electrode';
    oele1.uuid = mdf.UUID();
    % populate subject
    oele1.md.id = 1;
    oele1.md.name = 'Surface Electrode 1';
    oele1.md.type = 'surface electrode';
    oele1.md.files = { 'electrodes/surface/se12345.pdf' };
    oele1.md.specs = struct();
    oele1.md.specs.numElectrodes = 3;
    oele1.md.specs.dimensions = [0.5 0.5 0.5; 0.3 0.3 0.3];
    oele1.md.specs.units = ['um', 'um', 'um'];
    oele1.md.notes = '';
    % set location where to save
    oele1.setFiles(fullfile('<DATA_BASE>','electrodes','ele-1'));
    % save file
    oele1.save();
    %
    % electrode 2
    oele2 = mdfObj;
    oele2.type = 'electrode';
    oele2.uuid = mdf.UUID();
    % populate subject
    oele2.md.id = 2;
    oele2.md.name = 'Penetrating Electrode 2';
    oele2.md.type = 'penetrating electrode';
    oele2.md.files = { 'electrodes/surface/pe98765.pdf' };
    oele2.md.specs = struct();
    oele2.md.specs.numElectrodes = 3;
    oele2.md.specs.length = [1.2 0.4 0.9];
    oele2.md.specs.units = 'mm';
    oele2.md.specs.location = [0.1 0.1; 0.1 0.4; 0.1 0.7];
    oele2.md.specs.substrate = [0.2, 0.8];
    oele2.md.visFunction = 'pe3d.m';
    oele2.md.notes = '';
    % set location where to save
    oele2.setFiles(fullfile('<DATA_BASE>','electrodes','ele-2'));
    % save file
    oele2.save();
    disp('...Done!!!');
    
    
    % instantiate subject
    disp('Creating Subject 1 ...');
    osbj = mdfObj;
    osbj.type = 'subject';
    osbj.uuid = mdf.UUID();
    % populate subject
    osbj.md.id = 1;
    osbj.md.name = 'Tuesday';
    osbj.md.species = 'human';
    osbj.md.notes = ['High energy' char(13) 'Difficult subject'];
    % set location where to save
    osbj.setFiles(fullfile('<DATA_BASE>','sbj-1','sbj-1'));
    % save file
    osbj.save();
    disp('...Done!!!');
    
    % instantiate experiment
    disp('Creating Experiment...');
    oexp = mdfObj;
    oexp.type = 'experiment';
    oexp.uuid = mdf.UUID();
    % populate object
    oexp.md.id = 1;
    oexp.md.subjectid = 1;
    oexp.md.type = 'intense neural recording';
    oexp.md.started = '2016-05-19';
    oexp.md.ended = '';
    oexp.md.notes = 'Check electrodes. There were some trouble placing electrodes in few trials';
    % set location
    oexp.setFiles(fullfile('<DATA_BASE>','sbj-1','experiments','sbj-1.exp-1'));
    % append experiment under subject
    mdf.apcr(osbj,oexp,'experiments');
    % save object
    oexp.save();
    osbj.save();
    disp('...Done!!!');
    
    % trials type
    tt = { 'baseline recording', 'emg activity', 'emg activity with stimulation' };
    % trials id
    tid = {'' '' ''};
    
    % create trials
    for j = 1:3
        disp(['Creating trial ' num2str(j)]);
        otr1 = mdfObj;
        otr1.type = 'trial';
        otr1.uuid = mdf.UUID();
        tid{j} = otr1.uuid;
        % populate object
        otr1.md.id = j;
        otr1.md.subjectId = 1;
        otr1.md.experimentId = 1;
        otr1.md.type = 'baseline recording';
        otr1.md.started = ['2016-05-2' num2str(j) ' 10:00'];
        otr1.md.ended = ['2016-05-2' num2str(j) ' 12:00'];
        otr1.md.notes = 'Electrodes placing difficult';
        switch j
            case {1, 3}
                otr1.md.dataQuality = 'medium';
            case 2
                otr1.md.dataQuality = 'high';
        end %switch
        otr1.md.successful = 'yes';
        % set location
        otr1.setFiles(fullfile('<DATA_BASE>','sbj-1','trials',['sbj-1.tr-' num2str(j)]));
        % append trial under experiment
        mdf.apcr(oexp,otr1,'trials');
        % save object
        otr1.save();
        oexp.save();
        disp('...Done!!!');
    
        % add data
        disp(['Creating Muscle Activity container for trial ' num2str(j) '...']);
        oemg = mdfObj;
        oemg.type = 'muscle-activity';
        oemg.uuid = mdf.UUID();
        % populate object
        oemg.md.id = 1;
        oemg.md.subjectId = 1;
        oemg.md.experimentId = 1;
        oemg.md.trialId = j;
        oemg.md.notes = '';
        % add time
        oemg.d.time = [1:1000]/100;
        % set location
        oemg.setFiles(fullfile('<DATA_BASE>','sbj-1','trials',['tr-' num2str(j)],['sbj-1.tr-' num2str(j) '.ma']));
        % append trial under experiment
        mdf.apcr(otr1,oemg,'mas');
        % add link to electrode used
        if j == 1
            mdf.aul(oemg,oele1,'electrode');
        else
            mdf.abl(oemg,oele2,'electrode','data');
            oele2.save();
        end %if
        % save object
        oemg.save();
        otr1.save();
        disp('...Done!!!');
    
        % add channels
        for i = 1:3;
            disp(['Creating muscle activity channel ' num2str(i) ' for trial ' num2str(j) '...']);
            och = mdfObj;
            och.type = 'muscle-activity-channel';
            och.uuid = mdf.UUID();
            % populate object
            och.md.id = i;
            och.md.subjectId = 1;
            och.md.experimentId = 1;
            och.md.trialId = j;
            och.md.masId = 1;
            och.md.notes = '';
            % add data
            och.d.waveform = rand(1,1000);
            % set location
            och.setFiles( ...
                fullfile( ...
                    '<DATA_BASE>','sbj-1','trials',['tr-' num2str(j)],'ma',['sbj-1.tr-' num2str(j) '.mac-' num2str(i)]));
            % append trial under experiment
            mdf.apcr(oemg,och,'channels');
            % save object
            oemg.save();
            och.save();
            disp('...Done!!!');
        end %for
    end %for
    
    % first session
    disp('Creating Sessions...');
    oses1 = mdfObj();
    oses1.type = 'session';
    oses1.uuid = mdf.UUID();
    oses1.md.started = '2016-05-21 09:30';
    oses1.md.ended = '2016-05-22 12:30';
    oses1.md.notes = 'Long session';
    oses1.md.people = {'RG','MN'};
    % set files
    oses1.setFiles( ...
        fullfile( ...
        	'<DATA_BASE>','sbj-1','sessions','sbj-1.ses-1'));
    % start saving the object as is
    oses1.save();
    
    % now create hierarchy
    % set it as child of experiment
    mdf.apcr(oexp,oses1,'sessions');
    oses1.save();
    oexp.save();
    % first trial
    otr = mdf.load(tid{1});
    mdf.apcr(oses1,otr,'trials');
    oses1.save();
    otr.save();
	% second trial
    otr = mdf.load(tid{2});
    mdf.apcr(oses1,otr,'trials');
    oses1.save();
    otr.save();

    % second session
    oses2 = mdfObj();
    oses2.type = 'session';
    oses2.uuid = mdf.UUID();
    oses2.md.started = '2016-05-23 09:30';
    oses2.md.ended = '2016-05-23 12:30';
    oses2.md.notes = 'Short session';
    oses2.md.people = {'LF','MN', 'AN' };
    % set files
    oses2.setFiles( ...
        fullfile( ...
        	'<DATA_BASE>','sbj-1','sessions','sbj-1.ses-2'));
    % start saving the object as is
    oses2.save();
    
    % now create hierarchy
    % set it as child of experiment
    mdf.apcr(oexp,oses2,'sessions');
    oses2.save();
    oexp.save();
    % first trial
    otr = mdf.load(tid{3});
    mdf.apcr(oses1,otr,'trials');
    oses2.save();
    otr.save();
    disp('...Done!!!');

    res = omdfc;
    
end %function
