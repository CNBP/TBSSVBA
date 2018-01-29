function ud = readprocpar(procfile)
% function ud = readprocpar(procfile)
% read the parameters from the procpar file
ud = struct('descrip','file');
ud.lro=getPPV('lro',procfile);
ud.lpe=getPPV('lpe',procfile);
ud.lpe2=getPPV('lpe2',procfile);
ud.mainHdrSize = 32;

ud.nf = getPPV( 'nf', procfile);
ud.np = getPPV( 'np', procfile);
ud.nv = getPPV( 'nv', procfile);%nbre de pas de phase-encode
ud.nv2 = getPPV( 'nv2', procfile);
ud.ns = getPPV( 'ns', procfile);
ud.fn = getPPV( 'fn', procfile);
ud.fn1 = getPPV( 'fn1', procfile);

ud.pslabel = getPPV('pslabel',procfile);
ud.pss = getPPV( 'pss', procfile);
ud.thk = getPPV( 'thk', procfile);
ud.gap = getPPV( 'gap', procfile);

ud.seqcon = getPPV( 'seqcon', procfile);
ud.seqfil = getPPV( 'seqfil', procfile);
if strcmp(ud.seqfil,'fse3d') || strcmp(ud.seqfil,'fsems')
    ud.etl = getPPV( 'etl', procfile);
    ud.nseg = getPPV( 'nseg', procfile);
    ud.pelist = getPPV( 'pelist', procfile);
end
ud.sw=getPPV('sw',procfile);
ud.sw1=getPPV('sw1',procfile);
ud.sw2=getPPV('sw2',procfile);

ud.te = getPPV('te',procfile);
ud.tr = getPPV('tr',procfile);
ud.pro = getPPV('pro',procfile);

ud.dro = getPPV('dro',procfile);
ud.dsl = getPPV('dsl',procfile);
ud.dpe = getPPV('dpe',procfile);
ud.tdelta = getPPV('tdelta',procfile);
ud.tDELTA = getPPV('tDELTA',procfile);
ud.gdiff = getPPV('gdiff',procfile);
ud.array = getPPV('array',procfile);
ud.bvalrr = getPPV('bvalrr',procfile);
ud.bvalss = getPPV('bvalss',procfile);
ud.bvalpp = getPPV('bvalpp',procfile);
ud.bvalrs = getPPV('bvalrs',procfile);
ud.bvalsp = getPPV('bvalsp',procfile);
ud.bvalrp = getPPV('bvalrp',procfile);
ud.bvalue = getPPV('bvalue',procfile);
ud.nbzero = getPPV('nbzero',procfile);

ud.ppe = getPPV('ppe',procfile);
ud.pro = getPPV('pro',procfile);
ud.pss0 = getPPV('pss0',procfile);

return;