component {
    this.name = "Application";
    this.sessionManagement = true;
    this.mappings["/components"] = expandPath("../../components");
   //   onApplicationStart();
     public any function onApplicationStart() {
      // Initialize components
         try {
            Application.dashboardService = createObject("component", "components.services.DashboardService").init();
            Application.formatUtils = createObject("component", "components.utils.FormatUtils");
            Application.connectionValidator = createObject("component", "components.services.ConnectionValidator").init();
            Application.dbFormatter = createObject("component", "components.utils.DatabaseTypeFormatter");
            Application.errorHandler = createObject("component", "components.utils.ErrorHandler");
            Application.configExporter = createObject("component", "components.services.ConfigExporter").init();
            
         } catch (any e) {
            // Handle initialization errors
            writeLog(type="error", text="Application component initialization failed: " & e.message);
            return false;
         }
        return true;
     }
     public any function onRequestStart(string targetPage) {
        // List of allowed URLs (relative to wwwroot\Testing)
        var allowedURLs = [
            "/dashboardapp/views/dashboard/main.cfm",
            "/dashboardapp/views/dashboard/export.cfm",
            "/dashboardapp/views/dashboard/import.cfm",
            "/dashboardapp/views/dashboard/datasourcechecker.cfm",
            "/dashboardapp/views/dashboard/logviewer.cfm",
            "/dashboardapp/views/dashboard/404.cfm",
            "/dashboardapp/views/dashboard/dockerfilegenerator.cfm"
        ];

        // Normalize the targetPage to a relative path
        var relTarget = replace(targetPage, getDirectoryFromPath(getCurrentTemplatePath()), "", "all");
        relTarget = replace(relTarget, "\", "/", "all");
        // Check if the requested page is allowed
        if (!arrayContains(allowedURLs, relTarget)) {
            // Redirect to custom 404 page
            location(url="/dashboardapp/views/dashboard/404.cfm", addtoken=false);
            return false;
        }
        return true;
    }
}