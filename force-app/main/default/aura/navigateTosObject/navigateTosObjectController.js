({    invoke : function(component, event, helper) {

    helper.showToast(component, 'Éxito', 'El registro fue creado correctamente.', 'success');

   // Get the record ID attribute
   var record = component.get("v.recordId");
   window.setTimeout(function() {
        // Get the Lightning event that opens a record in a new tab
        var redirect = $A.get("e.force:navigateToSObject");
        
        // Pass the record ID to the event
        redirect.setParams({
            "recordId": record
        });
                
        // Open the record
        redirect.fire();
   }, 2000);
}})