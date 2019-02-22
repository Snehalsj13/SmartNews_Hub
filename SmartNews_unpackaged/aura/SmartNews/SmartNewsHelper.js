({
    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");
        console.log("fieldName:"+fieldName);
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fieldName": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            //console.log('fieldName '+ fieldName);
            //console.log('response.getState(): '+ response.getState());
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                //console.log("Picklist response: " + allValues);
                //console.log("Picklist response: " + allValues[0]);
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "None",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    //console.log("i: " + allValues[i]);
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    { console.log("Error message: " + errors[0].message); }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})