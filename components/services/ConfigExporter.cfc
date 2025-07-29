<cfcomponent displayname="ConfigExporter" hint="Handles exporting ColdFusion configuration">

    <cffunction name="init" access="public" returntype="ConfigExporter" output="false">
        <cfset variables.cfsetupPath = "C:\ColdFusion2025\config\cfsetup\cfsetup.bat">
        <cfset variables.cfhome = "C:\ColdFusion2025\cfusion">
        <cfreturn this>
    </cffunction>

    <cffunction name="exportConfig" access="public" returntype="struct" output="false" hint="Exports ColdFusion configuration to a JSON file">
        <cfargument name="outputFile" type="string" required="false" default="#expandPath('myconfig.json')#">
        
        <cfset var result = {
            success: false,
            outputFile: arguments.outputFile,
            output: "",
            errorMessage: ""
        }>
        
        <cftry>
            <cfexecute 
                name="#variables.cfsetupPath#" 
                arguments="export all #arguments.outputFile# #variables.cfhome#" 
                timeout="10"
                variable="cmdOutput"
                errorVariable="cmdError">
            </cfexecute>
            
            <cfset result.success = true>
            <cfset result.output = cmdOutput>
            <cfset result.errorMessage = cmdError>
            
            <cfcatch type="any">
                <cfset result.errorMessage = cfcatch.message & (len(cfcatch.detail) ? " - " & cfcatch.detail : "")>
            </cfcatch>
        </cftry>
        
        <cfreturn result>
    </cffunction>

</cfcomponent>