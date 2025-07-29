<cfparam name="url.export" default="false">

<!--- Initialize variables --->
<cfset variables.exportResult = {success: false, outputFile: "", output: "", errorMessage: ""}>

<!--- Perform export if requested --->
<cfif url.export eq "true">
    <cftry>
        <!--- Create the exportJson directory if it doesn't exist --->
        <cfset fileName = "cf-config-#dateTimeFormat(now(), 'yyyy-mm-dd-hhnnss')#.json">
        <cfset exportDir = expandPath("../../exportJson/#fileName#")>
        <cfif not directoryExists(expandPath("../../exportJson/"))>
            <cfdirectory action="create" directory="#exportDir#">
        </cfif>
        <!--- Pass the export directory to the exportConfig function --->
        <cfset variables.exportResult = application.configExporter.exportConfig(exportDir)>
        <cfcatch type="any">
            <cfdump var="#cfcatch#" label="Export Error">
            <cfabort>
        </cfcatch>
    </cftry>
</cfif>



<cfoutput>
    <!DOCTYPE html>
    <html lang="en">    
        <cfset variables.header = "Export ColdFusion Configuration">
        <cfset variables.styleSheet = "style.css">
        <cfinclude template="header.cfm">
        <body> 
            <div class="header-gradient text-white py-4 mb-4">
                <div class="container">
                    <div class="row align-items-center">
                        <div class="col">
                            <h1 class="mb-0"><i class="fas fa-file-export me-2"></i>  ColdFusion Configuration Export</h1>
                            <p class="mb-0 opacity-75">Export ColdFusion configuration using cfsetup command</p>
                        </div>
                        <div class="col-auto">
                            <span class="badge bg-light text-dark">CF 2025</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="container mt-5">
                <div class="card shadow-lg border-0 mt-4">
                    <div class="card-header py-3 bg-info text-white d-flex align-items-center justify-content-between">
                        <div>
                            <h4 class="mb-0">
                                <i class="fas fa-file-export me-2"></i>
                                Export Configuration
                            </h4>
                            <small class="text-white-50">Export your server settings for backup or migration.</small>
                        </div>
                        <a href="?export=true" class="btn btn-primary btn-sm" id="exportButton">
                            <i class="fas fa-download me-1"></i>
                            Export
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <p class="text-muted mb-1">
                                Easily export your ColdFusion configuration to a JSON file using the CFSetup tool.
                            </p>
                            <ul class="small text-muted ps-3 mb-0">
                                <li>Includes datasources, mail servers, mappings, and more.</li>
                                <li>Use the exported file for backup or to migrate settings to another server.</li>
                            </ul>
                        </div>
                        <div class="d-flex align-items-center mb-3">
                            <i class="fas fa-info-circle text-info me-2"></i>
                            <span class="text-info small">No changes will be made to your server during export.</span>
                        </div>
                        <cfif url.export eq "true">
                            <div class="mt-3">
                                <h5 class="mb-3"><i class="fas fa-terminal me-2"></i>Export Results</h5>
                                <cfif variables.exportResult.success>
                                    <div class="alert alert-success d-flex align-items-center" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>
                                        <div>
                                            <strong>Success:</strong> Configuration exported to
                                            <code>#variables.exportResult.outputFile#</code>
                                        </div>
                                    </div>
                                    <cfif len(variables.exportResult.output)>
                                        <div class="mt-2">
                                            <strong>Command Output:</strong>
                                            <pre class="bg-light p-2 rounded border mb-0" style="max-height:200px;overflow:auto;">#variables.exportResult.output#</pre>
                                        </div>
                                    </cfif>
                                    <div class="mt-3">
                                        <a href="#variables.exportResult.outputFile#" class="btn btn-outline-success btn-sm" download>
                                            <i class="fas fa-file-download me-1"></i>Download Exported File
                                        </a>
                                    </div>
                                <cfelse>
                                    <div class="alert alert-danger d-flex align-items-center" role="alert">
                                        <i class="fas fa-exclamation-triangle me-2"></i>
                                        <div>
                                            <strong>Error:</strong> #variables.exportResult.errorMessage#
                                        </div>
                                    </div>
                                </cfif>
                                <cfif len(variables.exportResult.errorMessage) and variables.exportResult.success>
                                    <div class="alert alert-warning d-flex align-items-center mt-2" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>
                                        <div>
                                            <strong>Command Error Output:</strong>
                                            <pre class="bg-light p-2 rounded border mb-0" style="max-height:150px;overflow:auto;">#variables.exportResult.errorMessage#</pre>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </cfif>
                    </div>
                </div>
            </div> 
            
            <div class="container mt-4">
                <a href="/dashboardapp/views/dashboard/main.cfm" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
                </a>
            </div>
        </body>
    </html>
    
</cfoutput>