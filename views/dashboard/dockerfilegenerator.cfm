<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ColdFusion Dockerfile Generator</title>
        <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
        <link rel ="stylesheet" href="../../configs/assets/css/style.css">
    </head>
    <body class="bg-light">
        <cfoutput> 
            <cftry>
                <cfparam name="form.submitted" default="false">
                <cfparam name="form.appName" default="mycfapp">
                <cfparam name="form.cfVersion" default="2025">
                <cfparam name="form.portNumber" default="8500">

                <cfset variables.dockerfile = "">
                <cfset variables.errorMessage = "">
                <cfset variables.successMessage = "">
                <cfset variables.configFileName = "">
               
                <!--- Process form submission --->
                <cftry>
                    <cfif structKeyExists(form,"submitted") AND form.submitted eq "true">
                            <!--- Validate required fields --->
                            <cfif structKeyExists(form,"appName")  AND len(trim(form.appName)) eq 0>
                                <cfset variables.errorMessage = "App Name is required.">
                            <cfelseif structKeyExists(form,"portNumber")  AND len(trim(form.portNumber)) eq 0 or not isNumeric(form.portNumber)>
                                <cfset variables.errorMessage = "Port Number must be a valid number.">
                            <cfelseif structKeyExists(form,"portNumber")  AND val(form.portNumber) lt 1 or val(form.portNumber) gt 65535>
                                <cfset variables.errorMessage = "Port Number must be between 1 and 65535.">
                            <cfelse>
                                <!--- Handle file upload --->
                                <cfif structKeyExists(form, "configFile") and len(form.configFile)>
                                    <!--- Create temp directory if it doesn't exist --->
                                    <cfset variables.tempDir = expandPath("./temp")>
                                    <cfif not directoryExists(variables.tempDir)>
                                        <cfdirectory action="create" directory="#variables.tempDir#">
                                    </cfif>
                                    
                                    <!--- Upload the config file --->
                                    <cffile action="upload" 
                                            filefield="configFile" 
                                            destination="#variables.tempDir#" 
                                            nameconflict="makeunique"
                                            accept="application/json,text/json,.json">
                                    
                                    <cfset variables.configFileName = cffile.serverFile>
                                    <cfset variables.successMessage = "Config file uploaded successfully: #variables.configFileName#">
                                </cfif>
                                
                                <!--- Generate Dockerfile content --->
                                <cfset variables.baseImage = "adobecoldfusion/coldfusion" & form.cfVersion>
                                <cfset variables.dockerfile = "FROM " & variables.baseImage & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & "LABEL maintainer=""ColdFusion Developer""" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & "LABEL app-name=""#form.appName#""" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & chr(10)>
                                
                                <!--- Add config file copy if uploaded --->
                                <cfif len(variables.configFileName)>
                                    <cfset variables.dockerfile = variables.dockerfile & "## Copy configuration file" & chr(10)>
                                    <cfset variables.dockerfile = variables.dockerfile & "COPY #variables.configFileName# /app/config.json" & chr(10)>
                                    <cfset variables.dockerfile = variables.dockerfile & chr(10)>
                                </cfif>
                                
                                <!--- Add port exposure --->
                                <cfset variables.dockerfile = variables.dockerfile & "## Expose ColdFusion port" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & "EXPOSE #form.portNumber#" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & chr(10)>
                                
                                <!--- Add working directory --->
                                <cfset variables.dockerfile = variables.dockerfile & "## Set working directory" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & "WORKDIR /app" & chr(10)>
                                <cfset variables.dockerfile = variables.dockerfile & chr(10)>
                                
                                <!--- Add startup command --->
                                <cfset variables.dockerfile = variables.dockerfile & "## Start ColdFusion with configuration" & chr(10)>
                                <cfif len(variables.configFileName)>
                                    <cfset variables.dockerfile = variables.dockerfile & "CMD [""/bin/bash"", ""-c"", ""cfsetup import all /app/config.json cfusion && coldfusion start""]">
                                <cfelse>
                                    <cfset variables.dockerfile = variables.dockerfile & "CMD [""/bin/bash"", ""-c"", ""coldfusion start""]">
                                </cfif>
                                
                                <cfif len(variables.errorMessage) eq 0>
                                    <cfset variables.successMessage = "Dockerfile generated successfully!">
                                </cfif>
                            </cfif>  
                           
                    </cfif>
                    <cfcatch type="any">
                        <cfdump var="#cfcatch#" label="Error Processing Request line 125" abort="true">
                        <!--- <cfset variables.errorMessage = "Error processing request: " & cfcatch.message> --->
                    </cfcatch>
                </cftry>
                <div class="container mt-5">
                    <div class="row justify-content-center">
                        <div class="col-lg-10">
                            <!--- Header --->
                            <div class="text-center mb-5">
                                <h1 class="display-4 fw-bold">
                                    <i class="fab fa-docker text-primary me-3"></i>
                                    ColdFusion Dockerfile Generator
                                </h1>
                                <p class="lead text-muted">Generate Docker containers for Adobe ColdFusion applications</p>
                                <div class="badge bg-success fs-6">Compatible with ColdFusion 2025 Developer Edition</div>
                            </div>

                            <!--- Main Form Card --->
                            <div class="card shadow-lg border-0 mb-4">
                                <div class="card-header py-3">
                                    <h4 class="mb-0">
                                        <i class="fas fa-cogs me-2"></i>
                                        Configuration Settings
                                    </h4>
                                </div>
                                <div class="card-body p-4">
                                    <!--- Error/Success Messages --->
                                    <cfif len(variables.errorMessage)>
                                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                            <i class="fas fa-exclamation-triangle me-2"></i>
                                            <strong>Error:</strong> #variables.errorMessage#
                                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                        </div>
                                    </cfif>
                                    
                                    <cfif len(variables.successMessage)>
                                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                                            <i class="fas fa-check-circle me-2"></i>
                                            <strong>Success:</strong> #variables.successMessage#
                                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                        </div>
                                    </cfif>

                                    <!--- Configuration Form --->
                                    <form method="post" enctype="multipart/form-data">
                                        <input type="hidden" name="submitted" value="true">
                                        
                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label for="appName" class="form-label fw-semibold">
                                                    <i class="fas fa-tag me-1"></i>
                                                    Application Name
                                                </label>
                                                <input type="text" 
                                                    class="form-control" 
                                                    id="appName" 
                                                    name="appName" 
                                                    value="#form.appName#" 
                                                    placeholder="Enter application name"
                                                    required>
                                                <div class="form-text">Used for Docker container labeling</div>
                                            </div>
                                            
                                            <div class="col-md-6 mb-3">
                                                <label for="cfVersion" class="form-label fw-semibold">
                                                    <i class="fas fa-code-branch me-1"></i>
                                                    ColdFusion Version
                                                </label>
                                                <select class="form-select" id="cfVersion" name="cfVersion" required>
                                                    <option value="2023" <cfif form.cfVersion eq "2023">selected</cfif>>ColdFusion 2023</option>
                                                    <option value="2025" <cfif form.cfVersion eq "2025">selected</cfif>>ColdFusion 2025</option>
                                                </select>
                                                <div class="form-text">Select your target ColdFusion version</div>
                                            </div>
                                        </div>

                                        <div class="row">
                                            <div class="col-md-6 mb-3">
                                                <label for="portNumber" class="form-label fw-semibold">
                                                    <i class="fas fa-network-wired me-1"></i>
                                                    Port Number
                                                </label>
                                                <input type="number" 
                                                    class="form-control" 
                                                    id="portNumber" 
                                                    name="portNumber" 
                                                    value="#form.portNumber#" 
                                                    min="1" 
                                                    max="65535"
                                                    placeholder="8500"
                                                    required>
                                                <div class="form-text">Port to expose for ColdFusion (1-65535)</div>
                                            </div>
                                            
                                            <div class="col-md-6 mb-3">
                                                <label for="configFile" class="form-label fw-semibold">
                                                    <i class="fas fa-file-upload me-1"></i>
                                                    Configuration File
                                                    <span class="badge bg-secondary ms-1">Optional</span>
                                                </label>
                                                <input type="file" 
                                                    class="form-control" 
                                                    id="configFile" 
                                                    name="configFile"
                                                    accept=".json,application/json">
                                                <div class="form-text">Upload a JSON configuration file for ColdFusion setup</div>
                                            </div>
                                        </div>

                                        <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                            <button type="submit" class="btn btn-primary btn-lg px-4">
                                                <i class="fas fa-rocket me-2"></i>
                                                Generate Dockerfile
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!--- Generated Dockerfile Display --->
                            <cfif len(variables.dockerfile) and len(variables.errorMessage) eq 0>                  
                                <div class="card shadow-lg border-0">
                                    <div class="card-header py-3 testing">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <h4 class="mb-0">
                                                <i class="fab fa-docker me-2"></i>
                                                Generated Dockerfile
                                            </h4>
                                            <div>
                                                <button type="button" class="btn btn-outline-light btn-sm me-2" onclick="copyToClipboard()">
                                                    <i class="fas fa-copy me-1"></i>
                                                    Copy
                                                </button>
                                                <!--- <a href="?download=true" class="btn btn-light btn-sm">
                                                    <i class="fas fa-download me-1"></i>
                                                    Download
                                                </a> --->
                                                <button type="button" class="btn btn-light btn-sm" onclick="downloadDockerfile()">
                                                    <i class="fas fa-download me-1"></i>
                                                    Download
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="card-body p-0">
                                        <div class="code-block" id="dockerfileContent">#variables.dockerfile#</div>
                                    </div>
                                    <div class="card-footer bg-light">
                                        <div class="row text-center">
                                            <div class="col-md-4">
                                                <small class="text-muted">
                                                    <i class="fas fa-tag me-1"></i>
                                                    <strong>App:</strong> #form.appName#
                                                </small>
                                            </div>
                                            <div class="col-md-4">
                                                <small class="text-muted">
                                                    <i class="fas fa-code-branch me-1"></i>
                                                    <strong>Version:</strong> ColdFusion #form.cfVersion#
                                                </small>
                                            </div>
                                            <div class="col-md-4">
                                                <small class="text-muted">
                                                    <i class="fas fa-network-wired me-1"></i>
                                                    <strong>Port:</strong> #form.portNumber#
                                                </small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                               
                                <!--- Usage Instructions --->
                                <div class="card shadow-sm border-0 mt-4">
                                    <div class="card-header bg-info text-white py-3">
                                        <h5 class="mb-0">
                                            <i class="fas fa-info-circle me-2"></i>
                                            Usage Instructions
                                        </h5>
                                    </div>
                                    <div class="card-body">
                                        <ol class="mb-0">
                                            <li class="mb-2">Save the generated Dockerfile to your project directory</li>
                                            <cfif len(variables.configFileName)>
                                                <li class="mb-2">Ensure your config file (<code>#variables.configFileName#</code>) is in the same directory</li>
                                            </cfif>
                                            <li class="mb-2">Build the Docker image: <code class="bg-light p-1 rounded">docker build -t #form.appName# .</code></li>
                                            <li class="mb-0">Run the container: <code class="bg-light p-1 rounded">docker run -p #form.portNumber#:#form.portNumber# #form.appName#</code></li>
                                        </ol>
                                    </div>
                                </div>
                            </cfif>
                        </div>
                    </div>
                </div>
                <div class="text-center mt-4">
                    <a href="/dashboardapp/views/dashboard/main.cfm" class="badge bg-light text-dark btn btn-secondary">
                        <i class="fas fa-arrow-left me-1"></i> Back to Dashboard
                    </a>
                </div>
                <!--- Footer --->
                <cfinclude template="footer.cfm">

                <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
                <script src="../../configs/assets/js/dockerfile_script.js"></script>
                <cfcatch type="any">
                    <!--- Initialize form variables --->
                    <cfdump var="#cfcatch#">
                </cfcatch>
            </cftry>
        </cfoutput>
    </body>
</html>