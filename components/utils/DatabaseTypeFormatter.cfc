component displayname="DatabaseTypeFormatter" hint="Formats database driver names" {

    public string function getDatabaseTypeDisplay(required string driver, string className="") {
        var displayName = arguments.driver;

        switch (lcase(arguments.driver)) {
            case "mysql":
            case "mysql5":
                displayName = "MySQL";
                break;
            case "mssqlserver":
                displayName = "Microsoft SQL Server";
                break;
            case "oracle":
                displayName = "Oracle";
                break;
            case "postgresql":
                displayName = "PostgreSQL";
                break;
            case "db2":
                displayName = "IBM DB2";
                break;
            case "other":
                if (findNoCase("mysql", arguments.className)) {
                    displayName = "MySQL (Custom)";
                } else if (findNoCase("sqlserver", arguments.className)) {
                    displayName = "SQL Server (Custom)";
                } else if (findNoCase("oracle", arguments.className)) {
                    displayName = "Oracle (Custom)";
                } else if (findNoCase("postgresql", arguments.className)) {
                    displayName = "PostgreSQL (Custom)";
                } else {
                    displayName = "Custom Driver";
                }
                break;
            default:
                displayName = ucase(left(arguments.driver, 1)) & lcase(mid(arguments.driver, 2, len(arguments.driver)));
        }

        return displayName;
    }

    public struct function parseConnectionInfo(required string url) {
        var result = {host: "", port: ""};
        try {
            // Parse different URL formats
            if (findNoCase("//", arguments.url)) {
                var urlPart = listLast(arguments.url, "//");
                if (find(":", urlPart)) {
                    result.host = listFirst(urlPart, ":/");
                    var portPart = listGetAt(urlPart, 2, ":");
                    if (isNumeric(listFirst(portPart, "/"))) {
                        result.port = listFirst(portPart, "/");
                    }
                } else {
                    result.host = listFirst(urlPart, "/");
                }
            }
        } catch (any e) {
            // Ignore parsing errors
        }
        return result;
    }
}
