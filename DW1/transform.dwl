//How to Compare two JSON and group them together to get the output.
%dw 2.0
output application/json
//here i was taken the first input as a variable in1
var in1 = {
  "prod": [
    {
      "Id": "123456",
      "value": "ABC"
    },
    {
      "Id": "123456",
      "value": "DEF"
    },
    {
      "Id": "987654",
      "value": "DEF"
    }
  ]
}
//here i was taken the first input as a variable in2
var in2 = {
  "ProdInfo": {
    "Prod": [
      {
        "Id": "123456",
        "value1": "LMN"
      },
      {
        "Id": "123456",
        "value1": "OPQ"
      },
      {
        "Id": "654321",
        "value1": "OPQ"
      }
    ]
  }
}
//The script used to compare two JSON objects, in1 and in2, and group them together based on their Id values. The script first extracts the Id values from both objects using the .* operator and stores them in the variables Id1 and Id2, respectively. 
var Id1 = in1.prod.*Id
var Id2 = in2.ProdInfo.Prod.*Id
//The ++ operator is then used to concatenate the two arrays of Id values, and the distinctBy function is used to remove any duplicates.
var sumId = (Id1 ++ Id2) distinctBy ((item, index) -> item)
var sum = in1.prod ++ in2.ProdInfo.Prod
//The script then concatenates the two original objects using the ++ operator and stores the result in the sum variable. 
var value11 = ((sum filter ($.Id == "123456")).value)reduce ($$ ++ $) 
var value12 = ((sum filter ($.Id == "123456")).value1) reduce ($ ++ $)
//And i used filter function to extract the values of the value and value1 properties for each Id value. 
var value2 = ((sum filter ($.Id == "654321")).value1) reduce ($)
var value3 = ((sum filter ($.Id == "987654")).value) reduce ($)
//And i used  reduce function is then used to concatenate the values into a single string.

var value1 = (flatten(value11 scan ".{3}")) ++ (flatten(value12 scan ".{3}"))
//The script generates a new value1 array by splitting the concatenated value and value1 strings into groups of three characters using the scan function. 
//The flatten function is then used to flatten the resulting array of arrays into a single array.
var finalResp = sumId map {
    "method": if((Id1 contains $) and (Id2 contains $)) "PATCH"
                else if ((Id1 contains $) and !(Id2 contains $)) "POST"
                else "DELETE",
//it generates a new JSON object, finalResp, by mapping over the sumId array of Id values. 
//For each Id value, the script checks if it is present in both in1 and in2. 
//If it is, the script generates a PATCH request with the value1 array as the body. 
//If it is only present in in1, the script generates a POST request with the value2 string as the body. 
//If it is only present in in2, the script generates a DELETE request with the value3 string as the body.
    "body": {
        "Id": $,
        "Value": if((Id1 contains $) and (Id2 contains $)) value1 
                else if ((Id1 contains $) and !(Id2 contains $)) value2
                else value3
    }            
}
---
{
    "output":
    [
        "Request":
         finalResp map(()-> if($.method == "PATCH") $ ++ $.&method ++ {"body":{
      "CurrentTime": now() 
  }}  else $ )
    ]
}
//Finally, 
// the script generates a new JSON object with a single property, output, 
// which contains a list of requests to be made to update the original objects. 
// If the request is a PATCH request, the script adds a CurrentTime property to the request body.