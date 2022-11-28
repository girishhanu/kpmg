var myValue=''
var myObj ="{a:{b:{c:d}}}"
getValueInObject(myObj)
function getValueInObject(myObj){
  myObj = myObj.replace(/[{}]/g, "");
  myObj = myObj.split(":");
  objLen = myObj.length;
  myValue = myObj[objLen-1]
  }
console.log(myValue) 