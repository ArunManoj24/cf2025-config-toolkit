<!--- 
ColdFusion 2025 Log Viewer Dashboard Module
Compatible with Adobe ColdFusion 2025 Developer Edition
--->
<cfparam name="url.logFile" default="application.log"/>
<cfparam name="url.search" default=""/>
<cfparam name="url.page" default="1"/>
<cfparam name="url.refresh" default="false"/>

<!--- Settings --->
<cfset linesPerPage = 50>
<cfset logDirectory = expandPath("/WEB-INF/cfusion/logs/")>
<cfset altLogPaths = [
    "C:\ColdFusion2025\cfusion\logs\",
    "/opt/coldfusion2025/cfusion/logs/",
    expandPath("../logs/"),
    expandPath("../../logs/")
]>
<cfset availableLogs = [
    {name: "Application Log", file: "application.log"},
    {name: "Exception Log", file: "exception.log"},
    {name: "Server Log", file: "server.log"},
    {name: "Scheduler Log", file: "scheduler.log"},
    {name: "Mail Log", file: "mail.log"},
    {name: "CF Admin Log", file: "cfadmin.log"}
]>
<!--- Find the correct log directory --->
<cfset logPath = "">
<cfloop array="#altLogPaths#" index="path">
    <cfif directoryExists(path)>
        <cfset logPath = path>
        <cfbreak>
    </cfif>
</cfloop>
<cfif logPath EQ "">
    <cfset logPath = logDirectory>
</cfif>

<!--- Ensure log file exists --->
<cfset currentLogFile = logPath & url.logFile>
<cfif NOT fileExists(currentLogFile)>
    <cfset currentLogFile = "">
</cfif>

<!--- Initialize variables --->
<cfset logEntries = []>
<cfset totalLines = 0>
<cfset currentPage = val(url.page)>
<cfif currentPage LT 1>
    <cfset currentPage = 1>
</cfif>
<cfset errorMessage = "">

<!--- Exception handling wrapper --->
<cftry>
    <!--- Read and parse log file --->
    <cfif currentLogFile NEQ "" AND fileExists(currentLogFile)>
        <cftry>
            <cfset fileContent = fileRead(currentLogFile)>
            <cfset allLines = listToArray(fileContent, chr(10))>
            <cfset totalLines = arrayLen(allLines)>

            <!--- Reverse array to show newest entries first --->
            <cfset reversedLines = []>
            <cfloop from="#arrayLen(allLines)#" to="1" step="-1" index="i">
                <cfset arrayAppend(reversedLines, allLines[i])>
            </cfloop>
            <cfset allLines = reversedLines>

            <!--- Filter by search term if provided --->
            <cfif len(trim(url.search)) GT 0>
                <cfset filteredLines = []>
                <cfloop array="#allLines#" index="line">
                    <cfif findNoCase(url.search, line) GT 0>
                        <cfset arrayAppend(filteredLines, line)>
                    </cfif>
                </cfloop>
                <cfset allLines = filteredLines>
                <cfset totalLines = arrayLen(allLines)>
            </cfif>

            <!--- Calculate pagination --->
            <cfset startIndex = ((currentPage - 1) * linesPerPage) + 1>
            <cfset endIndex = min(startIndex + linesPerPage - 1, totalLines)>
            <cfset totalPages = ceiling(totalLines / linesPerPage)>

            <!--- Extract entries for current page --->
            <cfloop from="#startIndex#" to="#endIndex#" index="i">
                <cfif i LTE arrayLen(allLines)>
                    <cfset arrayAppend(logEntries, Application.formatUtils.parseLogEntry(allLines[i]))>
                </cfif>
            </cfloop>
        <cfcatch type="any">
            <cfset errorMessage = "Error reading log file: " & cfcatch.message>
        </cfcatch>
        </cftry>
    <cfelse>
        <cfset errorMessage = "Log file not found: " & currentLogFile>
    </cfif>
<cfcatch type="any">
    <cfset errorMessage = "An unexpected error occurred: " & cfcatch.message>
</cfcatch>
</cftry>

<html lang="en"> 
    <cfset variables.header = "ColdFusion Log Viewer">
    <cfset variables.styleSheet = "style.css">
    <cfinclude template="header.cfm">

    <body>
        <div class="container-fluid mt-4">
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header bg-primary text-white">
                            <h4 class="mb-0">
                                <i class="bi bi-file-text"></i> ColdFusion Log Viewer
                            </h4>
                        </div>
                        <div class="card-body">
                            
                            <!--- Controls Form --->
                            <form method="get" class="row g-3 mb-4">
                                <div class="col-md-3">
                                    <label for="logFile" class="form-label">Log File:</label>
                                    <select name="logFile" id="logFile" class="form-select">
                                        <cfloop array="#availableLogs#" index="log">
                                            <cfoutput>
                                                <option value="#log.file#" <cfif url.logFile eq log.file>selected</cfif>>
                                                    #log.name#
                                                </option>
                                            </cfoutput>
                                        </cfloop>
                                    </select>
                                </div>
                                
                                <cftry>
                                    <div class="col-md-4">
                                        <label for="search" class="form-label">Search/Filter:</label>
                                        <input type="text" name="search" id="search" class="form-control" 
                                            value="<cfoutput>#url.search#</cfoutput>" 
                                            placeholder="Enter keywords to filter logs...">
                                    </div>
                                <cfcatch type="any">
                                    <div class="col-md-4">
                                        <div class="alert alert-danger mt-2">
                                            <i class="bi bi-exclamation-triangle"></i>
                                            Error displaying search box: <cfoutput>#cfcatch.message#</cfoutput>
                                        </div>
                                    </div>
                                </cfcatch>
                                </cftry>
                                
                                <div class="col-md-2">
                                    <label class="form-label">&nbsp;</label><br>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-search"></i> Filter
                                    </button>
                                </div>
                                
                                <div class="col-md-2">
                                    <label class="form-label">&nbsp;</label><br>
                                    <button type="submit" name="refresh" value="true" class="btn btn-success">
                                        <i class="bi bi-arrow-clockwise refresh-icon"></i>
                                        <div class="spinner-border spinner-border-sm refresh-spinner" role="status">
                                            <span class="visually-hidden">Loading...</span>
                                        </div>
                                        Refresh
                                    </button>
                                </div>
                                
                                <div class="col-md-1">
                                    <label class="form-label">&nbsp;</label><br>
                                    <a href="?" class="btn btn-outline-secondary">
                                        <i class="bi bi-arrow-counterclockwise"></i> Reset
                                    </a>
                                </div>
                            </form>
                            
                            <!--- Error Message --->
                            <cftry>
                                <cfif len(errorMessage) gt 0>
                                    <div class="alert alert-danger">
                                        <i class="bi bi-exclamation-triangle"></i>
                                        <cfoutput>#errorMessage#</cfoutput>
                                    </div>
                                </cfif>
                            <cfcatch type="any">
                                <div class="alert alert-danger">
                                    <i class="bi bi-exclamation-triangle"></i>
                                    An error occurred while displaying the error message: <cfoutput>#cfcatch.message#</cfoutput>
                                </div>
                            </cfcatch>
                            </cftry>
                            
                            <!--- Log Info --->
                            <cftry>
                                <cfif currentLogFile neq "" and fileExists(currentLogFile)>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <small class="text-muted">
                                                <strong>File:</strong> <cfoutput>#currentLogFile#</cfoutput><br>
                                                <strong>Total Entries:</strong> <cfoutput>#numberFormat(totalLines)#</cfoutput>
                                                <cfif len(trim(url.search)) gt 0>
                                                    (filtered by: "<cfoutput>#url.search#</cfoutput>")
                                                </cfif>
                                            </small>
                                        </div>
                                        <div class="col-md-6 text-end">
                                            <small class="text-muted">
                                                <strong>Last Modified:</strong> 
                                                <cfoutput>#dateFormat(getFileInfo(currentLogFile).lastModified, "mm/dd/yyyy")# 
                                                #timeFormat(getFileInfo(currentLogFile).lastModified, "HH:mm:ss")#</cfoutput>
                                            </small>
                                        </div>
                                    </div>
                                </cfif>
                            <cfcatch type="any">
                                <div class="alert alert-danger">
                                    <i class="bi bi-exclamation-triangle"></i>
                                    Error displaying log info: <cfoutput>#cfcatch.message#</cfoutput>
                                </div>
                            </cfcatch>
                            </cftry>
                            
                            <!--- Pagination Top --->
                            <cftry>
                                <cfif totalLines gt linesPerPage>
                                    <nav aria-label="Log pagination">
                                        <ul class="pagination pagination-sm justify-content-center">
                                            <cfif currentPage gt 1>
                                                <li class="page-item">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#currentPage-1#</cfoutput>">Previous</a>
                                                </li>
                                            </cfif>
                                            
                                            <cfloop from="#max(1, currentPage-2)#" to="#min(totalPages, currentPage+2)#" index="pageNum">
                                                <li class="page-item <cfif pageNum eq currentPage>active</cfif>">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#pageNum#</cfoutput>">
                                                        <cfoutput>#pageNum#</cfoutput>
                                                    </a>
                                                </li>
                                            </cfloop>
                                            
                                            <cfif currentPage lt totalPages>
                                                <li class="page-item">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#currentPage+1#</cfoutput>">Next</a>
                                                </li>
                                            </cfif>
                                        </ul>
                                    </nav>
                                </cfif>
                            <cfcatch type="any">
                                <div class="alert alert-danger">
                                    <i class="bi bi-exclamation-triangle"></i>
                                    Error displaying pagination: <cfoutput>#cfcatch.message#</cfoutput>
                                </div>
                            </cfcatch>
                            </cftry>
                            
                            <!--- Log Entries Table --->
                            <div class="table-container">
                                <cftry>
                                <table class="table table-striped table-hover table-sm">
                                    <thead class="table-dark sticky-top">
                                        <tr>
                                            <th style="width: 150px;">Date/Time</th>
                                            <th style="width: 80px;">Level</th>
                                            <th>Message</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfif arrayLen(logEntries) gt 0>
                                            <cfloop array="#logEntries#" index="entry">
                                                <cfset rowClass = "">
                                                <cfswitch expression="#lcase(entry.level)#">
                                                    <cfcase value="error,fatal">
                                                        <cfset rowClass = "log-entry-error">
                                                    </cfcase>
                                                    <cfcase value="warn,warning">
                                                        <cfset rowClass = "log-entry-warn">
                                                    </cfcase>
                                                    <cfcase value="info,debug">
                                                        <cfset rowClass = "log-entry-info">
                                                    </cfcase>
                                                </cfswitch>
                                                
                                                <tr class="<cfoutput>#rowClass#</cfoutput>">
                                                    <td class="text-nowrap">
                                                        <small><cfoutput>#entry.datetime#</cfoutput></small>
                                                    </td>
                                                    <td>
                                                        <cfswitch expression="#lcase(entry.level)#">
                                                            <cfcase value="error,fatal">
                                                                <span class="badge bg-danger log-level-badge">
                                                                    <cfoutput>#ucase(entry.level)#</cfoutput>
                                                                </span>
                                                            </cfcase>
                                                            <cfcase value="warn,warning">
                                                                <span class="badge bg-warning text-dark log-level-badge">
                                                                    <cfoutput>#ucase(entry.level)#</cfoutput>
                                                                </span>
                                                            </cfcase>
                                                            <cfcase value="info">
                                                                <span class="badge bg-info log-level-badge">
                                                                    <cfoutput>#ucase(entry.level)#</cfoutput>
                                                                </span>
                                                            </cfcase>
                                                            <cfdefaultcase>
                                                                <span class="badge bg-secondary log-level-badge">
                                                                    <cfoutput>#ucase(entry.level)#</cfoutput>
                                                                </span>
                                                            </cfdefaultcase>
                                                        </cfswitch>
                                                    </td>
                                                    <td class="log-message">
                                                        <cfoutput>#entry.message#</cfoutput>
                                                    </td>
                                                </tr>
                                            </cfloop>
                                        <cfelse>
                                            <tr>
                                                <td colspan="3" class="text-center text-muted py-4">
                                                    <i class="bi bi-inbox fs-1"></i><br>
                                                    No log entries found
                                                    <cfif len(trim(url.search)) gt 0>
                                                        matching your search criteria
                                                    </cfif>
                                                </td>
                                            </tr>
                                        </cfif>
                                    </tbody>
                                </table>
                                <cfcatch type="any">
                                    <div class="alert alert-danger">
                                        <i class="bi bi-exclamation-triangle"></i>
                                        Error displaying log entries: <cfoutput>#cfcatch.message#</cfoutput>
                                    </div>
                                </cfcatch>
                                </cftry>
                            </div>
                            
                            <!--- Pagination Bottom --->
                            <cftry>
                                <cfif totalLines gt linesPerPage>
                                    <nav aria-label="Log pagination">
                                        <ul class="pagination pagination-sm justify-content-center mt-3">
                                            <cfif currentPage gt 1>
                                                <li class="page-item">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#currentPage-1#</cfoutput>">Previous</a>
                                                </li>
                                            </cfif>
                                            
                                            <cfloop from="#max(1, currentPage-2)#" to="#min(totalPages, currentPage+2)#" index="pageNum">
                                                <li class="page-item <cfif pageNum eq currentPage>active</cfif>">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#pageNum#</cfoutput>">
                                                        <cfoutput>#pageNum#</cfoutput>
                                                    </a>
                                                </li>
                                            </cfloop>
                                            
                                            <cfif currentPage lt totalPages>
                                                <li class="page-item">
                                                    <a class="page-link" href="?logFile=<cfoutput>#urlEncodedFormat(url.logFile)#</cfoutput>&search=<cfoutput>#urlEncodedFormat(url.search)#</cfoutput>&page=<cfoutput>#currentPage+1#</cfoutput>">Next</a>
                                                </li>
                                            </cfif>
                                        </ul>
                                    </nav>
                                    
                                    <div class="text-center mt-2">
                                        <small class="text-muted">
                                            Showing <cfoutput>#startIndex#</cfoutput> to <cfoutput>#min(endIndex, totalLines)#</cfoutput> 
                                            of <cfoutput>#numberFormat(totalLines)#</cfoutput> entries 
                                            (Page <cfoutput>#currentPage#</cfoutput> of <cfoutput>#totalPages#</cfoutput>)
                                        </small>
                                    </div>

                                    <div class="text-center mt-4">
                                        <a href="/dashboardapp/views/dashboard/main.cfm" class="badge bg-light text-dark btn btn-secondary">
                                            <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
                                        </a>
                                    </div>
                                </cfif>
                            <cfcatch type="any">
                                <div class="alert alert-danger">
                                    <i class="bi bi-exclamation-triangle"></i>
                                    Error displaying pagination: <cfoutput>#cfcatch.message#</cfoutput>
                                </div>
                            </cfcatch>
                            </cftry>
                            
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
        <script>
            // Auto-submit form when log file selection changes
            document.getElementById('logFile').addEventListener('change', function() {
                this.form.submit();
            });
            
            // Show spinner on refresh button click
            document.querySelector('button[name="refresh"]').addEventListener('click', function() {
                this.querySelector('.refresh-icon').style.display = 'none';
                this.querySelector('.refresh-spinner').style.display = 'inline-block';
            });
            
            // Highlight search terms in the table
            <cfif len(trim(url.search)) gt 0>
                const searchTerm = '<cfoutput>#url.search#</cfoutput>';
                if (searchTerm) {
                    const cells = document.querySelectorAll('.log-message');
                    cells.forEach(cell => {
                        const regex = new RegExp('(' + searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
                        cell.innerHTML = cell.innerHTML.replace(regex, '<mark>$1</mark>');
                    });
                }
            </cfif>
            
            // Auto-refresh functionality (optional)
            let autoRefresh = false;
            let refreshInterval;
            
            function toggleAutoRefresh() {
                if (autoRefresh) {
                    clearInterval(refreshInterval);
                    autoRefresh = false;
                } else {
                    refreshInterval = setInterval(() => {
                        window.location.reload();
                    }, 30000); // Refresh every 30 seconds
                    autoRefresh = true;
                }
            }
        </script>
    </body> 
</html>
