function arrOut = insertAt(arr,val,index)
    
     
    c=false(1,length(arr)+length(index));
    c(index)=true;
    arrOut=nan(size(c));
    arrOut(~c)=arr;
    arrOut(c)=val;
end