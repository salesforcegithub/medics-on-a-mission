({
	getMemberData : function(cmp) {
		return this.controllerCallout(cmp, "c.getMemberAccountData", {'recordId' : cmp.get('v.recordId')})
	},
	updateDoDMember : function(cmp, updateAccount) {
		return this.controllerCallout(cmp, "c.updateMemberAccount", {'updateAccount' : updateAccount})
	},
	updateAccount: function(cmp, updateAccount) {
		return this.controllerCallout(cmp, "c.updateSFRecord", {'updateAccount' : updateAccount})
	},
	controllerCallout : function(cmp, cFunction, params) {
		return new Promise($A.getCallback((resolve,reject) => {
			var action = cmp.get(cFunction)
			params && action.setParams(params)
      action.setCallback(this, (response,event) => {
        var state = response.getState()
        if (state === "SUCCESS") {
          resolve(response.getReturnValue())
        }
        else {
          reject(event)
        }
      })
      $A.enqueueAction(action)
    }))
	}
})