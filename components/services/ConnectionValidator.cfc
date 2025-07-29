<cfcomponent displayname="ConnectionValidator" hint="Validates datasource connections">

    <cffunction name="init" access="public" returntype="ConnectionValidator" output="false">
        <cfset this.adminObj01 = createObject("component", "cfide.adminapi.administrator")>
        <cfset this.adminObj01.login("admin", "admin")>
        <cfset this.dsAPI = createObject("component", "cfide.adminapi.datasource")>
        <cfreturn this>
    </cffunction>

    <cffunction name="validateDatasources" access="public" returntype="struct" output="false" hint="Validates all datasources and returns status counts">
        <cfargument name="datasources" type="array" required="true">
        <cfset var result = {
            validCount: 0,
            invalidCount: 0,
            datasources: []
        }>
        
        <!--- Create a new array to store mutable datasource structs --->
        <cfset result.datasources = []>

        <cfloop array="#arguments.datasources#" index="i" item="datasource">

            <cfset var mutableDs = {}>
            <cfset structAppend(mutableDs, arguments.datasources[i], true)>
            <cftry>
                <cfset var verifyResult = variables.dsAPI.verifyDSN(mutableDs.name)>
                <cfset mutableDs.status = "valid">
                <cfset mutableDs.errorMessage = "">
                <cfset result.datasources.append(mutableDs)>
                <cfset result.validCount++>
                <cfcatch type="any">
                    <cfset mutableDs.status = "invalid">
                    <cfset mutableDs.errorMessage = cfcatch.message & (len(cfcatch.detail) ? " - " & cfcatch.detail : "")>
                    <cfset result.datasources.append(mutableDs)>
                    <cfset result.invalidCount++>
                </cfcatch>
            </cftry>
        </cfloop> 
        <cfreturn result>
    </cffunction>

</cfcomponent>