<cftry>
    <cfset variables.errorMessage = "">
    <cfset variables = Application.dashboardService.getDashboardData()>
    <cfcatch>
        <cfset variables.errorMessage = "Error initializing DashboardService: #cfcatch.message#">
        <cfoutput>
            <div class="error-message">
                <h2>Initialization Error: #variables.errorMessage#</h2>
            </div>
        </cfoutput>
    </cfcatch>
</cftry>

<cfoutput>
    <!DOCTYPE html>
    <html lang="en">
        
        <cfset variables.header = "ColdFusion Server Dashboard">
        <cfset variables.styleSheet = "dashboardstyles.css">
        <cfinclude template="header.cfm">
        <body>
            <div class="dashboard-container">
                <cfif structKeyExists(variables, "errorMessage") and len(variables.errorMessage)>
                    <!--- Error Display --->
                    <div class="container mb-4">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            <strong>System Error:</strong> <cfoutput>#(variables.errorMessage)#</cfoutput>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </div>
                <cfelse>
                    <cftry>
                        <!--- Dashboard Header --->
                        <header>
                            <div class="dashboard-header py-4 mb-4 rounded-3 shadow">
                                <div class="container">
                                    <div class="row align-items-center">
                                        <div class="col-md-8">
                                            <h1 class="display-6 fw-bold mb-2">
                                                <i class="fas fa-tachometer-alt me-3"></i>
                                                ColdFusion Server Dashboard
                                            </h1>
                                            <p class="lead mb-0">Real-time monitoring of server performance and system resources</p>
                                        </div>
                                        <div class="col-md-4 text-end">
                                            <div class="btn-group">
                                                <button type="button" class="btn btn-light" onclick="location.reload()">
                                                    <i class="fas fa-sync-alt me-1"></i>
                                                    Refresh Now
                                                </button>
                                                <a href="?refresh=true" class="btn refresh-btn text-white">
                                                    <i class="fas fa-clock me-1"></i>
                                                    Auto Refresh
                                                </a>
                                            </div>
                                            <div class="mt-2">
                                                <small class="text-light">
                                                    <i class="fas fa-clock me-1"></i>
                                                    Last Updated: <cfoutput>#timeFormat(now(), "HH:mm:ss")#</cfoutput>
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </header>
                        <!--- Dashboard Content --->
                        <div class="container">
                            <!-- Server Information -->
                            <div class="row mb-4">
                                <!--- Server Information Panel --->
                                <div class="col-lg-8">
                                    <div class="card h-100">
                                        <div class="card-header">
                                            <h5 class="mb-0">
                                                <i class="fas fa-server me-2 text-primary"></i>
                                                Server Information
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="table-responsive">
                                                <table class="table table-borderless server-info-table">
                                                    <tbody>
                                                        <cfoutput>
                                                            <tr>
                                                                <th width="30%">
                                                                    <i class="fas fa-tag me-2 text-muted"></i>
                                                                    Server Name
                                                                </th>
                                                                <td><strong>#variables.serverName# #variables.serverVersion#</strong></td>
                                                            </tr>
                                                            <tr>
                                                                <th>
                                                                    <i class="fas fa-layer-group me-2 text-muted"></i>
                                                                    Edition
                                                                </th>
                                                                <td><span class="badge bg-primary">#variables.serverEdition#</span></td>
                                                            </tr>
                                                            <tr>
                                                                <th>
                                                                    <i class="fas fa-clock me-2 text-muted"></i>
                                                                    Current Time
                                                                </th>
                                                                <td>
                                                                    <span class="fw-bold">#dateFormat(variables.currentTime, "dddd, mmmm dd, yyyy")#</span><br>
                                                                    <span class="text-primary fs-5">#timeFormat(variables.currentTime, "HH:mm:ss")#</span>
                                                                    <small class="text-muted ms-2">(#variables.serverTimeZone#)</small>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th>
                                                                    <i class="fas fa-stopwatch me-2 text-muted"></i>
                                                                    Server Uptime
                                                                </th>
                                                                <td>
                                                                    <div class="uptime-display text-success">
                                                                        #variables.uptimeDays# days, #variables.uptimeHours# hours, #variables.uptimeMinutes# minutes
                                                                    </div>
                                                                    <small class="text-muted">(#numberFormat(variables.uptimeSeconds)# seconds)</small>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <th>
                                                                    <i class="fab fa-java me-2 text-muted"></i>
                                                                    Java Version
                                                                </th>
                                                                <td>#variables.javaVersion# (#variables.javaVendor#)</td>
                                                            </tr>
                                                            <tr>
                                                                <th>
                                                                    <i class="fas fa-desktop me-2 text-muted"></i>
                                                                    Operating System
                                                                </th>
                                                                <td>#variables.osName# #variables.osVersion# (#variables.osArch#)</td>
                                                            </tr>
                                                        </cfoutput>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!--- Quick Stats Panel --->
                                <div class="col-lg-4">
                                    <div class="row g-3">
                                        <div class="col-12">
                                            <div class="card stat-card">
                                                <div class="card-body text-center">
                                                    <i class="fas fa-memory metric-icon mb-2"></i>
                                                    <h4 class="mb-1"><cfoutput>#variables.memoryUsagePercent#%</cfoutput></h4>
                                                    <p class="mb-0">Memory Usage</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-12">
                                            <cftry>
                                                <div class="card <cfif variables.activeThreads gt 100>stat-card warning<cfelse>stat-card</cfif>">
                                                    <div class="card-body text-center">
                                                        <i class="fas fa-project-diagram metric-icon mb-2"></i>
                                                        <h4 class="mb-1"><cfoutput>#variables.activeThreads#</cfoutput></h4>
                                                        <p class="mb-0">Active Threads</p>
                                                        <small class="opacity-75">Peak: <cfoutput>#variables.peakThreads#</cfoutput></small>
                                                    </div>
                                                </div>
                                                <cfcatch>
                                                    <div class="card stat-card warning">
                                                        <div class="card-body text-center">
                                                            <i class="fas fa-project-diagram metric-icon mb-2"></i>
                                                            <h4 class="mb-1">N/A</h4>
                                                            <p class="mb-0">Active Threads</p>
                                                            <small class="opacity-75">Peak: N/A</small>
                                                        </div>
                                                    </div>
                                                </cfcatch>
                                            </cftry>
                                        </div>
                                        <div class="col-12">
                                            <div class="card stat-card">
                                                <div class="card-body text-center">
                                                    <i class="fas fa-hdd metric-icon mb-2"></i>
                                                    <h4 class="mb-1"><cfoutput>#Application.formatUtils.formatMemory(variables.maxMemory)#</cfoutput></h4>
                                                    <p class="mb-0">Max Memory</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!--- Memory Usage Charts --->
                            <div class="row mb-4">
                                <!--- Pie Chart --->
                                <div class="col-lg-6">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0">
                                                <i class="fas fa-chart-pie me-2 text-primary"></i>
                                                JVM Memory Distribution
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <cfchart format="png" 
                                                    chartwidth="600" 
                                                    chartheight="500" 
                                                    title="JVM Memory Usage"
                                                    font="Arial"
                                                    fontsize="12"
                                                    backgroundcolor="##FFFFFF"
                                                    show3d="yes">
                                                <cfchartseries type="pie" 
                                                            colorlist="##28a745,##dc3545,##ffc107">
                                                    <cfchartdata item="Used Memory" value="#variables.usedMemoryMB#">
                                                    <cfchartdata item="Free Memory" value="#variables.freeMemoryMB#">
                                                </cfchartseries>
                                            </cfchart>
                                        </div>
                                        <div class="chart-container">
                                            <div class="mt-3">
                                                <div class="row text-center">
                                                    <div class="col-6">
                                                        <div class="d-flex align-items-center justify-content-center">
                                                            <div class="bg-success rounded-circle me-2" style="width: 12px; height: 12px;"></div>
                                                            <small><strong>Used:</strong> <cfoutput>#variables.usedMemoryMB# MB</cfoutput></small>
                                                        </div>
                                                    </div>
                                                    <div class="col-6">
                                                        <div class="d-flex align-items-center justify-content-center">
                                                            <div class="bg-danger rounded-circle me-2" style="width: 12px; height: 12px;"></div>
                                                            <small><strong>Free:</strong> <cfoutput>#variables.freeMemoryMB# MB</cfoutput></small>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <!--- Bar Chart --->
                                <div class="col-lg-6">
                                    <div class="card" >
                                        <div class="card-header">
                                            <h5 class="mb-0">
                                                <i class="fas fa-chart-bar me-2 text-primary"></i>
                                                Memory Allocation Details
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="chart-container">
                                                <cfchart format="png" 
                                                        chartwidth="400" 
                                                        chartheight="300" 
                                                        title="Memory Allocation (MB)"
                                                        font="Arial"
                                                        fontsize="12"
                                                        backgroundcolor="##FFFFFF"
                                                        show3d="yes">
                                                    <cfchartseries type="bar" 
                                                                colorlist="##007bff,##28a745,##dc3545,##ffc107">
                                                        <cfchartdata item="Max Memory" value="#variables.maxMemoryMB#">
                                                        <cfchartdata item="Total Memory" value="#variables.totalMemoryMB#">
                                                        <cfchartdata item="Used Memory" value="#variables.usedMemoryMB#">
                                                        <cfchartdata item="Free Memory" value="#variables.freeMemoryMB#">
                                                    </cfchartseries>
                                                </cfchart>
                                            </div>
                                            <div class="mt-3">
                                                <div class="memory-bar">
                                                    <div class="memory-bar-fill" style="width: <cfoutput>#variables.memoryUsagePercent#%</cfoutput>"></div>
                                                </div>
                                                <div class="d-flex justify-content-between mt-2">
                                                    <small class="text-muted">0 MB</small>
                                                    <small class="fw-bold"><cfoutput>#variables.memoryUsagePercent#% Used</cfoutput></small>
                                                    <small class="text-muted"><cfoutput>#variables.totalMemoryMB# MB</cfoutput></small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="mt-5">
                                        <div class="card w-100" style="height: 20rem">
                                            <div class="card-header">
                                                <h5 class="mb-0">
                                                    <i class="fas fa-chart-bar me-2 text-primary"></i>
                                                    Export &amp; Import Data 
                                                </h5>
                                            </div>
                                            <div class="card-body" >
                                                <div class="export-import-Container" style="display: flex;  justify-content: center; gap: 0px 6rem;">
                                                    <div class="text-center mt-3 icon-container">
                                                        <a class="btn btn-primary refresh-btn" href="export.cfm" role="button" data-toggle="tooltip" data-placement="top" title="export configuration">
                                                            <i class="fa-solid fa-file-export"></i>
                                                        </a>
                                                    </div>
                                                    <div class="text-center mt-3 icon-container">
                                                        <a class="btn btn-primary refresh-btn" href="import.cfm" role="button" data-toggle="tooltip" data-placement="top" title="import configuration">
                                                            <i class="fa-solid fa-file-import"></i>
                                                        </a>
                                                    </div>
                                                    <div class="text-center mt-3 icon-container">
                                                        <a class="btn btn-primary refresh-btn" href="logviewer.cfm" role="button" data-toggle="tooltip" data-placement="top" title="view logs">
                                                            <i class="fa fa-eye" aria-hidden="true"></i>
                                                        </a>
                                                    </div>
                                                </div>
                                                <div class="d-flex justify-content-center mt-5">   
                                                    <a class="btn btn-primary refresh-btn" href="dockerfilegenerator.cfm" role="button" data-toggle="tooltip" data-placement="top" title="view logs">
                                                        <i class="fa-brands fa-docker"></i> DockerFile Generator
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>        
                                </div>
                            </div> 
                            
                            <!--- Detailed Memory Information --->
                            <div class="row mb-4">
                                <div class="col-12">
                                    <div class="card">
                                        <div class="card-header">
                                            <h5 class="mb-0">
                                                <i class="fas fa-info-circle me-2 text-primary"></i>
                                                Detailed Memory Information
                                            </h5>
                                        </div>
                                        <div class="card-body">
                                            <div class="row">
                                                <div class="col-md-3">
                                                    <div class="text-center p-3 border rounded">
                                                        <i class="fas fa-database fa-2x text-primary mb-2"></i>
                                                        <h6>Maximum Memory</h6>
                                                        <p class="h5 mb-0 text-primary"><cfoutput>#Application.formatUtils.formatMemory(variables.maxMemory)#</cfoutput></p>
                                                        <small class="text-muted">JVM Max Heap</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="text-center p-3 border rounded">
                                                        <i class="fas fa-chart-area fa-2x text-success mb-2"></i>
                                                        <h6>Total Allocated</h6>
                                                        <p class="h5 mb-0 text-success"><cfoutput>#Application.formatUtils.formatMemory(variables.totalMemory)#</cfoutput></p>
                                                        <small class="text-muted">Currently Allocated</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="text-center p-3 border rounded">
                                                        <i class="fas fa-exclamation-triangle fa-2x text-warning mb-2"></i>
                                                        <h6>Memory Used</h6>
                                                        <p class="h5 mb-0 text-warning"><cfoutput>#Application.formatUtils.formatMemory(variables.usedMemory)#</cfoutput></p>
                                                        <small class="text-muted">Currently In Use</small>
                                                    </div>
                                                </div>
                                                <div class="col-md-3">
                                                    <div class="text-center p-3 border rounded">
                                                        <i class="fas fa-check-circle fa-2x text-info mb-2"></i>
                                                        <h6>Free Memory</h6>
                                                        <p class="h5 mb-0 text-info"><cfoutput>#Application.formatUtils.formatMemory(variables.freeMemory)#</cfoutput></p>
                                                        <small class="text-muted">Available for Use</small>
                                                    </div>
                                                </div>
                                            </div>
                                            
                                            <hr class="my-4">
                                            
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <h6><i class="fas fa-lightbulb me-2"></i>Memory Usage Tips</h6>
                                                    <ul class="small">
                                                        <li>Memory usage above 80% may indicate need for optimization</li>
                                                        <li>Monitor for memory leaks if usage continuously increases</li>
                                                        <li>Consider increasing max heap size if frequently hitting limits</li>
                                                    </ul>
                                                </div>
                                                <div class="col-md-3">
                                                    <h6><i class="fas fa-cogs me-2"></i>JVM Configuration</h6>
                                                    <ul class="small">
                                                        <li>Max Heap: <cfoutput>#Application.formatUtils.formatMemory(variables.maxMemory)#</cfoutput></li>
                                                        <li>Active Threads: <cfoutput>#variables.activeThreads#</cfoutput></li>
                                                        <li>Peak Threads: <cfoutput>#variables.peakThreads#</cfoutput></li>
                                                    </ul>
                                                </div>
                                                <div class="col-md-3">
                                                    <h6><i class="fas fa-cogs me-2"></i>Data Soucre Checker</h6>
                                                    <ul class="small">
                                                        <li><a href="datasourcechecker.cfm" class="text-primary">Check Data Sources</a></li>
                                                        <li><a href="dockerfilegenerator.cfm" class="text-primary">Dockerfile Generator</a></li>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!--- Footer --->
                        <cfinclude template="Footer.cfm">
                        <cfcatch>
                            <div class="error-message">
                                <h2>Dashboard Error: #cfcatch.message#</h2>
                            </div>
                        </cfcatch>
                    </cftry>
                </cfif>
            </div>
        </body>
    </html>
</cfoutput>