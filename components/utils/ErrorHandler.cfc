component displayname="ErrorHandler" accessors="true" {
    function init() {
        return this;
    }

    function logError(error, context) {
        writeLog(type="error", file="dashboard", text="[#context#] #error.message# - #error.detail#");
    }

    function createError(message, detail = "") {
        return createObject("java", "java.lang.Exception").init(message, detail);
    }

    
    public string function formatError(required any error) {
        writeDump(error);
        // var msg = "Error: #error.message#";
        // if (structKeyExists(error, "detail") && len(error.detail)) {
        //     msg &= " | Detail: #error.detail#";
        // }
        // return msg;
    }
}