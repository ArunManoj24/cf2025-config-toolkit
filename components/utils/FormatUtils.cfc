component displayname="FormatUtils" accessors="true" {
    function init() {
        return this;
    }

    function formatMemory(bytes) {
        if (bytes < 1024) {
            return bytes & " bytes";
        } else if (bytes < 1024 * 1024) {
            return numberFormat(bytes / 1024, "0.00") & " KB";
        } else if (bytes < 1024 * 1024 * 1024) {
            return numberFormat(bytes / (1024 * 1024), "0.00") & " MB";
        } else {
            return numberFormat(bytes / (1024 * 1024 * 1024), "0.00") & " GB";
        }
    }

     // Function to parse log entry
    public struct function parseLogEntry(line) {
        var entry = {};
        var regexPattern = "^""([^""]+)""\s+""([^""]+)""\s+""([^""]+)""\s+""([^""]+)""\s+(.*)$";
        var matches = reMatch(regexPattern, line);
        
        if (arrayLen(matches) > 0) {
            // Standard CF log format: "severity" "thread" "date" "time" message
            var parts = reFind('\"([^\"]*)\"\s*\"([^\"]*)\"\s*\"([^\"]*)\"\s*\"([^\"]*)\"\s*(.*)', line, 1, true);
            if (parts.pos[1] > 0) {
                entry.level = mid(line, parts.pos[2], parts.len[2]);
                entry.thread = mid(line, parts.pos[3], parts.len[3]);
                entry.date = mid(line, parts.pos[4], parts.len[4]);
                entry.time = mid(line, parts.pos[5], parts.len[5]);
                entry.message = mid(line, parts.pos[6], parts.len[6]);
                entry.datetime = entry.date & " " & entry.time;
            } else {
                // Fallback parsing
                entry.level = "INFO";
                entry.datetime = dateFormat(now(), "mm/dd/yyyy") & " " & timeFormat(now(), "HH:mm:ss");
                entry.message = line;
            }
        } else {
            // Simple fallback for non-standard format
            entry.level = "INFO";
            entry.datetime = dateFormat(now(), "mm/dd/yyyy") & " " & timeFormat(now(), "HH:mm:ss");
            entry.message = line;
        }
        
        return entry;
    }


    function getResulthtmlformat(required string jsonString) {
        var lines = listToArray(arguments.jsonString, chr(10));
        var errors = [];
        var warnings = [];
        var htmlOutput = "";

        for (var line in lines) {
            line = trim(line);
            if (line != "") {
                if (left(line, 4) == "ERR:") {
                    arrayAppend(errors, line);
                } else if (left(line, 5) == "WARN:") {
                    arrayAppend(warnings, line);
                }
            }
        }

        htmlOutput &= "<h3>❌ Errors:</h3>";
        htmlOutput &= "<ul>";
        for (var e in errors) {
            htmlOutput &= "<li>" & e & "</li>";
        }
        htmlOutput &= "</ul>";

        htmlOutput &= "<h3>⚠️ Warnings:</h3>";
        htmlOutput &= "<ul>";
        for (var w in warnings) {
            htmlOutput &= "<li>" & w & "</li>";
        }
        htmlOutput &= "</ul>";

        return htmlOutput;
    }

}