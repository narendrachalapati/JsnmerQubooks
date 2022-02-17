({
    doInit : function(component, event, helper) {
        
    },

    invokeTokenFlowJS : function(component, event, helper){
        alert("Version 1");
        component.set("v.responseStatus", 'Please wait while we fetch the token...');

        let action = component.get("c.invokeTokenFlow");
        action.setParams({"oauthConfigId" : component.get("v.recordId")});
        action.setCallback(this,function(response){
            let state = response.getState();
            if(state === 'SUCCESS'){
                alert("Sucess");
            }else{
                alert("Error");
            }
        });

        $A.enqueueAction(action);
    }
})