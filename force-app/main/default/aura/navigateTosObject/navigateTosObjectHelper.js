({
    showToast : function(component, title, message, type) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": title,
        "message": message,
        "type": type  // 'success', 'error', 'warning', 'info'
    });
    toastEvent.fire();
}
})