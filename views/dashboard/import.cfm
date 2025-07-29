<!---
Import Configuration Module for Adobe ColdFusion 2025
Provides web UI for importing CF configuration via cfsetup command
--->

<cfparam name="form.action" default="">
<cfparam name="form.overwrite" default="false">
<cfparam name="form.targetInstance" default="cfusion">
<cfparam name="form.cfHomePath" default="">
<cfparam name="variables.header" default="ColdFusion Configuration Import">
<cfparam name="variables.targetParam" default="C:\ColdFusion2025\cfusion">

<cfset FormatObj = createObject("component", "components.utils.FormatUtils")>
<cfset variables.message = "">
<cfset variables.messageType = "">
<cfset variables.tempDir = getTempDirectory()>

<cfif form.action eq "import">
     <cftry>
        <!--- Validate file upload --->
        <cfif not structKeyExists(form, "configFile") or not len(trim(form.configFile))>
            <cfset variables.message = "Please select a configuration file to upload.">
            <cfset variables.messageType = "error">
        <cfelse>
            <!--- Get uploaded file info --->
            <cffile action="upload" 
                    filefield="configFile" 
                    destination="#variables.tempDir#" 
                    nameconflict="makeunique"
                    result="uploadResult">
            
            <!--- Validate file extension --->
            <cfif not listFindNoCase("json", listLast(uploadResult.serverFile, "."))>
                <!--- Delete invalid file --->
                <cffile action="delete" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#">
                <cfset variables.message = "Invalid file type. Please upload a JSON file.">
                <cfset variables.messageType = "error">
            <cfelse>
                <!--- Validate JSON content --->
                <cffile action="read" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#" variable="jsonContent">
                
                <cftry>
                    <cfset deserializeJSON(jsonContent)>
                    <cfset variables.isValidJSON = true>
                    <cfcatch type="any">
                        <cfset variables.isValidJSON = false>
                        <cfset variables.message = "Invalid JSON file format. Please check your configuration file.">
                        <cfset variables.messageType = "error">
                    </cfcatch>
                </cftry>
                
                <cfif variables.isValidJSON>
                    <!--- Determine target instance --->
                    <cfset variables.targetParam = len(trim(form.cfHomePath)) ? trim(form.cfHomePath) : trim(form.targetInstance)>
                    
                    <!--- Build cfsetup command --->
                    <cfset variables.command = "C:\ColdFusion2025\config\cfsetup\cfsetup.bat">
                    <cfset variables.arguments = "import all ""#uploadResult.serverDirectory#/#uploadResult.serverFile#"" ""#variables.targetParam#""">
                    
                    <!--- Add force flag if overwrite is selected --->
                    <cfif form.overwrite eq "true">
                        <cfset variables.arguments = variables.arguments & " --force">
                    </cfif>
                    
                    <!--- Execute cfsetup command --->
                    <cfexecute name="#variables.command#" 
                               arguments="#variables.arguments#"
                               timeout="60"
                               variable="executeResult"
                               errorVariable="executeError">
                    </cfexecute>
                    <!--- Check execution result --->
                    <cfif len(trim(executeError))>
                        <cfset variables.message = "Configuration import failed: #executeError#">
                        <cfset variables.messageType = "error">
                    <cfelse>

                        <cfset variables.message = "Configuration imported successfully!<br><strong>Target:</strong> #variables.targetParam#<br><strong>Details:</strong> #FormatObj.getResulthtmlformat(executeResult)#">
                        <cfset variables.messageType = "success">
                    </cfif>
                </cfif>
                
                <!--- Clean up temporary file --->
                <cftry>
                    <cffile action="delete" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#">
                    <cfcatch type="any">
                        <!--- Log error but don't interrupt process --->
                        <cflog file="cf_import_config" text="Failed to delete temp file: #uploadResult.serverDirectory#/#uploadResult.serverFile#">
                    </cfcatch>
                </cftry>
            </cfif>
        </cfif>
        
        <cfcatch type="any">
            <cfset variables.message = "An unexpected error occurred: #cfcatch.message#">
            <cfset variables.messageType = "error">
            
            <!--- Clean up any temp files if they exist --->
            <cfif isDefined("uploadResult.serverDirectory") and isDefined("uploadResult.serverFile")>
                <cftry>
                    <cffile action="delete" file="#uploadResult.serverDirectory#/#uploadResult.serverFile#">
                    <cfcatch type="any">
                        <!--- Ignore cleanup errors --->
                    </cfcatch>
                </cftry>
            </cfif>
        </cfcatch>
    </cftry>
</cfif>

<!DOCTYPE html>
<html lang="en">
    <cfset variables.header = "ColdFusion Configuration Import">
    <cfset variables.styleSheet = "style.css">
    <cfinclude template="header.cfm">
    <body class="bg-light">
        <div class="header-gradient text-white py-4 mb-4">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col">
                        <h1 class="mb-0"><i class="fas fa-upload me-2"></i>ColdFusion Configuration Import</h1>
                        <p class="mb-0 opacity-75">Import ColdFusion configuration using cfsetup command</p>
                    </div>
                    <div class="col-auto">
                        <span class="badge bg-light text-dark">CF 2025</span>
                    </div>
                    <div class="col-auto">
                        <a href="/dashboardapp/views/dashboard/main.cfm" class="badge bg-light text-dark">
                            <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
                        </a>
                    </div>
                </div>
            </div>
            <div class="container mt-5">
            </div>
        </div>

        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6">
                    
                    <!--- Display messages --->
                    <cfif len(variables.message)>
                        <div class="alert alert-<cfif variables.messageType eq 'error'>danger<cfelse>success</cfif> alert-dismissible fade show" role="alert">
                            <i class="fas fa-<cfif variables.messageType eq 'error'>exclamation-triangle<cfelse>check-circle</cfif> me-2"></i>
                            <cfoutput>
                                #variables.message#
                            </cfoutput>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </cfif>

                    <div class="card card-shadow border-0">
                        <div class="card-header bg-white border-bottom">
                            <h4 class="card-title mb-0">
                                <i class="fas fa-cog me-2 text-primary"></i>Import Configuration
                            </h4>
                            <small class="text-muted">Upload and import a JSON configuration file exported via cfsetup</small>
                        </div>
                        
                        <div class="card-body">
                            <form method="post" enctype="multipart/form-data" id="importForm">
                                <input type="hidden" name="action" value="import">
                                
                                <!--- File Upload Section --->
                                <div class="mb-4">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-file-upload me-2"></i>Configuration File
                                        <span class="text-danger">*</span>
                                    </label>
                                    <div class="file-upload-wrapper">
                                        <input type="file" 
                                            name="configFile" 
                                            id="configFile" 
                                            accept=".json"
                                            class="file-upload-input"
                                            required>
                                        <label for="configFile" class="file-upload-label" id="fileLabel">
                                            <i class="fas fa-cloud-upload-alt fa-2x mb-2 text-muted"></i><br>
                                            <span class="text-muted">Click to select JSON configuration file</span><br>
                                            <small class="text-muted">Only .json files are accepted</small>
                                        </label>
                                    </div>
                                </div>

                                <!--- Target Instance Section --->
                                <div class="mb-4">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-server me-2"></i>Target Configuration
                                    </label>
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <label for="targetInstance" class="form-label">Instance Alias</label>
                                            <cfoutput>
                                            <input type="text" 
                                                class="form-control" 
                                                id="targetInstance" 
                                                name="targetInstance" 
                                                value="#(form.targetInstance)#"
                                                placeholder="cfusion">
                                            </cfoutput>
                                            <small class="form-text text-muted">Default: cfusion</small>
                                        </div>
                                        <div class="col-md-6">
                                            <label for="cfHomePath" class="form-label">Or CF Home Path</label>
                                            <cfoutput>
                                            <input type="text" 
                                                class="form-control" 
                                                id="cfHomePath" 
                                                name="cfHomePath" 
                                                value="#(form.cfHomePath)#"
                                                placeholder="/opt/coldfusion/cfusion">
                                            </cfoutput>
                                            <small class="form-text text-muted">Overrides instance alias if provided</small>
                                        </div>
                                    </div>
                                </div>

                                <!--- Options Section --->
                                <div class="mb-4">
                                    <label class="form-label fw-bold">
                                        <i class="fas fa-cogs me-2"></i>Import Options
                                    </label>
                                    <div class="form-check">
                                        <input type="checkbox" 
                                            class="form-check-input" 
                                            id="overwrite" 
                                            name="overwrite" 
                                            value="true"
                                            <cfif form.overwrite eq "true">checked</cfif>>
                                        <label class="form-check-label" for="overwrite">
                                            <strong>Force Overwrite</strong>
                                            <small class="d-block text-muted">Overwrite existing settings without prompting</small>
                                        </label>
                                    </div>
                                </div>

                                <!--- Submit Button --->
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-primary btn-lg" id="submitBtn">
                                        <i class="fas fa-download me-2"></i>Import Configuration
                                    </button>
                                </div>
                            </form>
                        </div>
                        
                        <div class="card-footer bg-light border-top-0">
                            <small class="text-muted">
                                <i class="fas fa-info-circle me-1"></i>
                                This tool uses the <code>cfsetup import</code> command to apply configuration settings.
                                Ensure ColdFusion Administrator services are running before importing.
                            </small>
                        </div>
                    </div>

                    <!--- Help Section --->
                    <div class="card mt-4 border-0 bg-transparent">
                        <div class="card-body">
                            <h6 class="text-muted mb-3">
                                <i class="fas fa-question-circle me-2"></i>How to use:
                            </h6>
                            <ol class="text-muted small">
                                <li>Export your configuration using: <code>cfsetup export config.json instance_name</code></li>
                                <li>Upload the exported JSON file using the form above</li>
                                <li>Specify the target instance alias or CF home path</li>
                                <li>Check "Force Overwrite" to replace existing settings without prompts</li>
                                <li>Click "Import Configuration" to apply the settings</li>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="../../configs/assets/js/import_script.js"></script>
    </body>
</html>