{
  mapReduce: "mdfDbTest",
  map: "function(){var a,t,e,d=function(a,t,e){var y,f,m,r=!1;if(m=a,r={}.toString.call(m).match(/\\s([a-zA-Z]+)/)[1].toLowerCase(),[\"array\",\"bson\",\"object\"].indexOf(r)>=0)for(y in a)a.hasOwnProperty(y)&&(f=\"array\"===r?t+\".$\":mdfGetNewKeyString(y,t),e=d(a[y],f,e));return\"\"===t?e:(e.hasOwnProperty(t)||(e[t]={}),e[t].hasOwnProperty(r)||(e[t][r]=1),e)};t=d(this.mdf_metadata,\"\",{});for(metadataKey in t)if(t.hasOwnProperty(metadataKey)){for(e in t[metadataKey])t[metadataKey].hasOwnProperty(e)&&(a={mdf_type:this.mdf_def.mdf_type,value_type:e,data_type:\"metadata\",field:metadataKey},emit(a,t[metadataKey][e]));a={mdf_type:this.mdf_def.mdf_type,value_type:\"all\",data_type:\"metadata\",field:metadataKey},emit(a,1)}a={mdf_type:this.mdf_def.mdf_type,value_type:\"all\",data_type:\"all\",field:\"all\"},emit(a,1)}",
  reduce: "function(r,n){return Array.sum(n)}",
  finalize: "function(t,e){return result={mdf_type:t.mdf_type,value_type:t.value_type,data_type:t.data_type,field:t.field,count:e}}",
  out: { inline: 1 }
}

