({
	doInit : function(component, event, helper) {
        var actionGetNews = component.get("c.parseJSONResponse");
        console.log("Creepy webservice please let me catch exceptions please work!");
        
        // Create a callback that is executed after the server-side action returns
        actionGetNews.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Server response: " + response.getReturnValue());
                component.set("v.newsList", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    { console.log("Error message: " + errors[0].message); }
                } else {
                    console.log("Unknown error");
                }
            }
        });
         // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(actionGetNews);
        helper.fetchPickListVal(component, 'Category__c', 'category');
        helper.fetchPickListVal(component, 'Language__c', 'language');
        helper.fetchPickListVal(component, 'Country__c', 'country');
        helper.fetchPickListVal(component, 'Name__c', 'source');
	},
    
    onPicklistChange: function(component, event, helper) {
        // get id and source
        alert(event.getSource().getLocalId());
		alert(event.getSource().get("v.value"));
    },
    
    onButtonClick: function(component, event, helper) {
        // get id and source
        alert(event.getSource().getLocalId());
		alert(event.getSource().get("v.value"));
    },
})