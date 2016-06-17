
oSbj = rfObj()
oSbj.uuid = mdSbj.uuid
oSbj.vuuid = mdSbj.vuuid
oSbj.type = 'subject'
oSbj.metadata = rmfield(mdSbj,{'files','vuuid','uuid','constants','pictures','folder','images'})
