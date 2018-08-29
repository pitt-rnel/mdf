{
  mapReduce: "<COLLECTION>",
  map: "function(){var a,t,e,f=function(a,t,e){var d,m,y;if(y={}.toString.call(a).match(/\\s([a-zA-Z]+)/)[1].toLowerCase(),0<=[\"array\",\"bson\",\"object\"].indexOf(y))for(d in a)a.hasOwnProperty(d)&&(m=\"array\"===y?t+\".$\":\"\"===t?d:t+\".\"+d,e=f(a[d],m,e));return\"\"===t||(e.hasOwnProperty(t)||(e[t]={}),e[t].hasOwnProperty(y)||(e[t][y]=1)),e};for(k in t=f(this.mdf_metadata,\"\",{}))if(t.hasOwnProperty(k)){for(e in t[k])t[k].hasOwnProperty(e)&&(a={mdf_type:this.mdf_def.mdf_type,value_type:e,data_type:\"metadata\",field:k},emit(a,t[k][e]));a={mdf_type:this.mdf_def.mdf_type,value_type:\"all\",data_type:\"metadata\",field:k},emit(a,1)}a={mdf_type:this.mdf_def.mdf_type,value_type:\"all\",data_type:\"all\",field:\"all\"},emit(a,1)}",
  reduce: "function(r,n){return Array.sum(n)}",
  finalize: "function(t,e){return result={mdf_type:t.mdf_type,value_type:t.value_type,data_type:t.data_type,field:t.field,count:e}}",
  out: { inline: 1 }
}

