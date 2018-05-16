% define function to start mdf v1.5
function startMdfV1_5() 

  % add correct path
  addpath('/home/man8/repos/git/mdf-v1.5/mMDF/core');

  global omdfc;
  omdfc = mdf.init(struct('confFile','/home/man8/.rnel/mdf.1_5.xml.conf'));

end
