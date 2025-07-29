<cfparam name="url.refresh" default="false">
<cfparam name="variables.totalDatasources" default="0">
<cfparam name="variables.validCount" default="0">
<cfparam name="variables.invalidCount" default="0">


<!--- Initialize variables --->
<cfset variables.errorMessage = "">
<cfset variables.datasources = []>
<cfset variables.totalDatasources = 0>
<cfset variables.validCount = 0>
<cfset variables.invalidCount = 0>
 

<!--- Fetch datasources --->
<cftry>
    <cfset variables.datasources = application.dashboardService.getDatasources()>
    <cfset variables.totalDatasources = application.dashboardService.getDatasourceCount()>
    
    <!--- Validate connections if requested --->
   
    <cfif structKeyExists(url,"refresh") AND  url.refresh eq "true">
        <cfset validationResult = application.connectionValidator.validateDatasources(variables.datasources)>
        <cfset variables.validCount = validationResult.validCount>
        <cfset variables.invalidCount = validationResult.invalidCount>
        <cfset variables.datasources = validationResult.datasources>
    <cfelse>
        <cfloop array="#variables.datasources#" index="idx" item="itm">
            <cfset mutableDs = {}>
            <cfset structAppend(mutableDs, variables.datasources[idx], true)>
            <cfset mutableDs.status = "unchecked">
            <cfset mutableDs.errorMessage = "">
            <cfset variables.datasources[idx] = mutableDs>
        </cfloop>

    </cfif>
    <cfcatch type="any">
        <!--- <cfset variables.errorMessage = "Error accessing ColdFusion Admin API: " & errorHandler.formatError(cfcatch)> --->
        <cfdump var="#cfcatch#" label="Error Details" abort="false">
    </cfcatch>
</cftry>

<!--- HTML Output --->
<cfoutput>
    <!DOCTYPE html>
    <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ColdFusion Datasource Status Checker</title>
            <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
             <link href="../../configs/assets/css/styles.css" rel="stylesheet">
        </head>
        <body class="bg-light">
            <div class="container-fluid mt-4">
                <div class="row">
                    <div class="col-12">
                        <!--- Header --->
                        <div class="text-center mb-4">
                            <h1 class="display-5 fw-bold">
                                <i class="fas fa-database text-success me-3"></i>
                                ColdFusion Datasource Status Checker
                            </h1>
                            <p class="lead text-muted">Monitor the health and connectivity of all configured datasources</p>
                            <div class="badge bg-info fs-6">Compatible with Adobe ColdFusion 2025</div>
                        </div>
                        
                        <!--- Error Display --->
                        <cfif len(variables.errorMessage)>
                            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                <strong>Admin API Error:</strong> #variables.errorMessage#
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                <hr>
                                <small class="text-muted">
                                    <strong>Possible causes:</strong>
                                    <ul class="mb-0 mt-2">
                                        <cfloop array="#errorHandler.getErrorSuggestions()#" index="suggestion">
                                            <li>#suggestion#</li>
                                        </cfloop>
                                    </ul>
                                </small>
                            </div>
                        </cfif>
                        
                        <!--- Datasource Summary --->
                        <cfif arrayLen(variables.datasources) gt 0>
                            <div class="row mb-4">
                                <div class="col-md-3">
                                    <div class="card border-0 shadow-sm">
                                        <div class="card-body text-center">
                                            <i class="fas fa-database fa-2x text-primary mb-2"></i>
                                            <h4 class="mb-1">#variables.totalDatasources#</h4>
                                            <small class="text-muted">Total Datasources</small>
                                        </div>
                                    </div>
                                </div>
                                <cfif url.refresh eq "true">
                                    <div class="col-md-3">
                                        <div class="card border-0 shadow-sm">
                                            <div class="card-body text-center">
                                                <i class="fas fa-check-circle fa-2x text-success mb-2"></i>
                                                <h4 class="mb-1">#variables.validCount#</h4>
                                                <small class="text-muted">Valid Connections</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="card border-0 shadow-sm">
                                            <div class="card-body text-center">
                                                <i class="fas fa-times-circle fa-2x text-danger mb-2"></i>
                                                <h4 class="mb-1">#variables.invalidCount#</h4>
                                                <small class="text-muted">Invalid Connections</small>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="card border-0 shadow-sm">
                                            <div class="card-body text-center">
                                                <i class="fas fa-percentage fa-2x text-info mb-2"></i>
                                                <h4 class="mb-1">
                                                    <cfif variables.totalDatasources gt 0>
                                                        #round((variables.validCount / variables.totalDatasources) * 100)#%
                                                    <cfelse>
                                                        0%
                                                    </cfif>
                                                </h4>
                                                <small class="text-muted">Success Rate</small>
                                            </div>
                                        </div>
                                    </div>
                                <cfelse>
                                    <div class="col-md-9">
                                        <div class="card border-0 shadow-sm">
                                            <div class="card-body text-center">
                                                <i class="fas fa-info-circle fa-2x text-warning mb-2"></i>
                                                <h5 class="mb-1">Click "Check All Connections" to test datasource connectivity</h5>
                                                <small class="text-muted">Connection status will be verified using the ColdFusion Admin API</small>
                                            </div>
                                        </div>
                                    </div>
                                </cfif>
                            </div>
                        </cfif>

                        <!--- Main Datasources Table --->
                        <div class="card shadow-lg border-0">
                            <div class="card-header py-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h4 class="mb-0">
                                        <i class="fas fa-list me-2"></i>
                                        Configured Datasources
                                        <cfif arrayLen(variables.datasources) gt 0>
                                            <span class="badge bg-light text-dark ms-2">#variables.totalDatasources#</span>
                                        </cfif>
                                    </h4>
                                    <div>
                                        <a href="/dashboardapp/views/dashboard/main.cfm" class="badge bg-light text-dark">
                                            Back to Dashboard
                                        </a>
                                        <cfif arrayLen(variables.datasources) gt 0>
                                            <button type="button" class="btn btn-light btn-sm" onclick="location.reload()">
                                                <i class="fas fa-redo me-1 refresh-icon"></i>
                                                Refresh Page
                                            </button>
                                            <a href="?refresh=true" class="btn btn-primary btn-sm ms-2" id="checkButton">
                                                <i class="fas fa-plug me-1"></i>
                                                Check All Connections
                                            </a>
                                        </cfif>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <cfif arrayLen(variables.datasources) eq 0>
                                    <div class="text-center py-5">
                                        <i class="fas fa-database fa-4x text-muted mb-3"></i>
                                        <h5 class="text-muted">No datasources configured</h5>
                                        <p class="text-muted">Configure datasources through the ColdFusion Administrator</p>
                                    </div>
                                <cfelse>
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th scope="col">
                                                        <i class="fas fa-tag me-1"></i>
                                                        Datasource Name
                                                    </th>
                                                    <th scope="col">
                                                        <i class="fas fa-cog me-1"></i>
                                                        Database Type
                                                    </th>
                                                    <th scope="col">
                                                        <i class="fas fa-server me-1"></i>
                                                        Host &amp; Port
                                                    </th>
                                                    <th scope="col">
                                                        <i class="fas fa-heartbeat me-1"></i>
                                                        Connection Status
                                                    </th>
                                                    <th scope="col">
                                                        <i class="fas fa-info-circle me-1"></i>
                                                        Details
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfoutput>
                                                    <cfloop array="#variables.datasources#" index="ds">
                                                        <cfset connectionInfo = application.dbFormatter.parseConnectionInfo(ds.url ?: "")>
                                                        <tr class="datasource-row">
                                                            <td>
                                                                <strong class="text-primary">#(ds.name)#</strong>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-secondary">
                                                                    #application.dbFormatter.getDatabaseTypeDisplay(ds.driver ?: "unknown", ds.class ?: "")#
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <cfif len(connectionInfo.host)>
                                                                    <i class="fas fa-server me-1 text-muted"></i>
                                                                    #(connectionInfo.host)#
                                                                    <cfif len(connectionInfo.port)>
                                                                        <br><small class="text-muted">Port: #connectionInfo.port#</small>
                                                                    </cfif>
                                                                <cfelse>
                                                                    <small class="text-muted">N/A</small>
                                                                </cfif>
                                                            </td> 
                                                            
                                                            <td>
                                                                <cfswitch expression="#ds.status#">
                                                                    <cfcase value="valid">
                                                                        <span class="status-valid px-3 py-2">
                                                                            <i class="fas fa-check-circle me-1"></i>
                                                                            Valid
                                                                        </span>
                                                                    </cfcase>
                                                                    <cfcase value="invalid">
                                                                        <span class="status-valid px-3 py-2" 
                                                                            data-bs-toggle="tooltip" 
                                                                            data-bs-placement="top" 
                                                                            data-bs-html="true"
                                                                            title="<strong>Connection Error:</strong><br>#(ds.errorMessage)#">
                                                                            <i class="fas fa-times-circle me-1"></i>
                                                                            Invalid
                                                                        </span>
                                                                    </cfcase>
                                                                    <cfdefaultcase>
                                                                        <span class="badge bg-secondary px-3 py-2">
                                                                            <i class="fas fa-question-circle me-1"></i>
                                                                            Not Checked
                                                                        </span>
                                                                    </cfdefaultcase>
                                                                </cfswitch>
                                                            </td>
                                                            <td>
                                                                <cfif structKeyExists(ds, "description") and len(ds.description)>
                                                                    <small class="text-muted">#(ds.description)#</small>
                                                                <cfelse>
                                                                    <small class="text-muted">No description</small>
                                                                </cfif>
                                                            </td>
                                                        </tr>
                                                    </cfloop>
                                                </cfoutput>
                                            </tbody>
                                        </table>
                                    </div>
                                </cfif>
                            </div>
                            <cfif arrayLen(variables.datasources) gt 0>
                                <div class="card-footer bg-light">
                                    <div class="row align-items-center">
                                        <div class="col-md-8">
                                            <small class="text-muted">
                                                <i class="fas fa-info-circle me-1"></i>
                                                <strong>Legend:</strong>
                                                <span class="badge status-valid ms-2">Valid</span> - Connection successful
                                                <span class="badge status-invalid ms-2">Invalid</span> - Connection failed
                                                <span class="badge bg-secondary ms-2">Not Checked</span> - Status unknown
                                            </small>
                                        </div>
                                        <div class="col-md-4 text-end">
                                            <small class="text-muted">
                                                <cfif url.refresh eq "true">
                                                    <i class="fas fa-clock me-1"></i>
                                                    Last checked: #dateFormat(now(), "yyyy-mm-dd")# #timeFormat(now(), "HH:mm:ss")#
                                                <cfelse>
                                                    <i class="fas fa-exclamation-triangle me-1"></i>
                                                    Click "Check All Connections" to verify status
                                                </cfif>
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </cfif>
                        </div>

                        <!--- Additional Information --->
                        <div class="row mt-4">
                            <div class="col-md-6">
                                <div class="card border-0 shadow-sm">
                                    <div class="card-header bg-info text-white">
                                        <h6 class="mb-0">
                                            <i class="fas fa-lightbulb me-2"></i>
                                            How It Works
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <ul class="mb-0 small">
                                            <li>Uses ColdFusion Admin API to retrieve datasource configurations</li>
                                            <li>Tests connectivity using <code>verifyDSN()</code> method</li>
                                            <li>Displays real-time connection status with detailed error messages</li>
                                            <li>Automatically parses connection strings for host/port information</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="card border-0 shadow-sm">
                                    <div class="card-header bg-warning text-dark">
                                        <h6 class="mb-0">
                                            <i class="fas fa-exclamation-triangle me-2"></i>
                                            Requirements
                                        </h6>
                                    </div>
                                    <div class="card-body">
                                        <ul class="mb-0 small">
                                            <li>Requires access to ColdFusion Administrator</li>
                                            <li>Admin API must be enabled and accessible</li>
                                            <li>Sufficient permissions to execute datasource operations</li>
                                            <li>Compatible with Adobe ColdFusion 2025 Developer Edition</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <cfinclude template="Footer.cfm">
            
            <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
            <script src="/assets/js/scripts.js"></script>
        </body>
    </html>
</cfoutput>