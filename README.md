# DashboardApp

DashboardApp is a ColdFusion-based web application for managing and monitoring server configurations, datasources, and logs. It provides a user-friendly dashboard interface for exporting/importing configuration files, validating connections, viewing logs, and generating Dockerfiles.

## Features
- Dashboard overview
- Datasource checker
- Dockerfile generator
- Configuration export/import
- Log viewer
- Error handling and formatting utilities

## Project Structure
```
Application.cfc
components/
  services/
    ConfigExporter.cfc
    ConnectionValidator.cfc
    DashboardService.cfc
  utils/
    DatabaseTypeFormatter.cfc
    ErrorHandler.cfc
    FormatUtils.cfc
configs/
assets/
  css/
    dashboardstyles.css
    style.css
  js/
    dockerfile_script.js
    import_script.js
    script.js
exportJson/
views/
  dashboard/
    404.cfm
    datasourcechecker.cfm
    dockerfilegenerator.cfm
    export.cfm
    footer.cfm
    header.cfm
    import.cfm
    logviewer.cfm
    main.cfm
```

## Getting Started
1. Place the application in your ColdFusion webroot directory.
2. Ensure ColdFusion server is running.
3. Access the dashboard via your browser at `http://localhost:8500/dashboardapp/views/dashboard/main.cfm` (adjust port/path as needed).

## Usage
- Use the dashboard to view and manage server configurations.
- Export and import configuration files from the `exportJson/` directory.
- Check datasource connectivity and view logs for troubleshooting.

## Dependencies
- Adobe ColdFusion 2025 (or compatible engine)

