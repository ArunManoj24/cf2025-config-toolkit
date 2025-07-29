component displayname="DashboardService" accessors="true" {
    function init() {
        this.adminObj = createObject("component", "cfide.adminapi.administrator");
        this.adminObj.login("admin", "admin"); // Replace with actual admin credentials
        this.dsAPI = createObject("component", "cfide.adminapi.datasource");
        return this;
    }

    function getDashboardData() {
        // writeDump(var="#server#", label="Server Information", abort=true);
        try {
            var runtime = createObject("java", "java.lang.Runtime").getRuntime();
            var dashboardData = {
                serverName = server.coldfusion.productname,
                serverVersion = server.coldfusion.productversion,
                serverEdition = server.coldfusion.productlevel,
                currentTime = now(),
                serverTimeZone = getTimeZoneInfo().name,
                javaVersion = server.system.properties.java.version,
                javaVendor = server.system.properties.java.vendor,
                osName = server.os.name,
                osVersion = server.os.version,
                osArch = server.os.arch,
                maxMemory = runtime.maxMemory(),
                totalMemory = runtime.totalMemory(),
                freeMemory = runtime.freeMemory(),
                usedMemory = runtime.totalMemory() - runtime.freeMemory(),
                activeThreads = createObject("java", "java.lang.Thread").activeCount(),
                peakThreads = 0, // Placeholder, as original code used N/A
                errorMessage = ""
                
            };

            // Server Uptime Calculation
            if (dashboardData.osName CONTAINS "Windows") {
                cfexecute(name="cmd.exe", arguments="/c wmic os get lastbootuptime", variable="bootInfo", timeout="5");
                var bootLines = listToArray(bootInfo, chr(10));
                var lastBoot = trim(bootLines[2]);
                var bootTime = createDateTime(
                    left(lastBoot, 4),
                    mid(lastBoot, 5, 2),
                    mid(lastBoot, 7, 2),
                    mid(lastBoot, 9, 2),
                    mid(lastBoot, 11, 2),
                    mid(lastBoot, 13, 2)
                );
                dashboardData.uptimeSeconds = dateDiff("s", bootTime, now());
            } else {
                // Linux/macOS
                cfexecute(name="/bin/bash", arguments="-c 'cut -f1 -d. /proc/uptime'", variable="uptimeSeconds", timeout="5");
                dashboardData.uptimeSeconds = int(trim(uptimeSeconds));
            }

            // Calculate uptime components
            dashboardData.uptimeDays = int(dashboardData.uptimeSeconds / (24 * 3600));
            dashboardData.uptimeHours = int((dashboardData.uptimeSeconds % (24 * 3600)) / 3600);
            dashboardData.uptimeMinutes = int((dashboardData.uptimeSeconds % 3600) / 60);

            // Calculate memory metrics
            dashboardData.usedMemoryMB = dashboardData.usedMemory / 1024 / 1024;
            dashboardData.freeMemoryMB = dashboardData.freeMemory / 1024 / 1024;
            dashboardData.totalMemoryMB = dashboardData.totalMemory / 1024 / 1024;
            dashboardData.memoryUsagePercent = numberFormat((dashboardData.usedMemory / dashboardData.totalMemory) * 100, "0.00");
           dashboardData.maxMemoryMB = round(dashboardData.maxMemory / 1048576);
            return dashboardData;
        } catch (any e) {
            var errorHandler = createObject("component", "components.utils.ErrorHandler");
            errorHandler.logError(e, "DashboardService.getDashboardData");
            dashboardData.errorMessage = e.message;
            return dashboardData;
        }
    }

    /**
     * Retrieves a list of datasources configured in the ColdFusion Administrator.
     * @return {array} An array of datasource information objects.
     */
   public array function getDatasources() {
        var arrdata = []; // Proper local scoping
        try {
            if (isDefined("this.adminObj") && isObject(this.adminObj)) {
                this.adminObj = createObject("component", "cfide.adminapi.administrator");
            }   
            this.adminObj.login("admin", "admin");             
            if (!isDefined("this.dsAPI")) {
                this.dsAPI = createObject("component", "cfide.adminapi.datasource");
            }

            var allDatasources = this.dsAPI.getDatasources();

            // Defensive check: make sure it’s a struct
            if (isStruct(allDatasources)) {
                for (var key in allDatasources) {
                    var dsInfo = duplicate(allDatasources[key]);
                    dsInfo.name = key;
                    arrayAppend(arrdata, dsInfo);
                }
            }
        } catch (any ex) {
            writeDump(var=ex, label="Datasource Exception", abort=true);
        }

        return arrdata;
    }


    public numeric function getDatasourceCount(){
        return arrayLen(getDatasources());
    }
}