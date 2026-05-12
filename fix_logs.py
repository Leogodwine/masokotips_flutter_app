import re

with open('lib/services/api_service.dart', 'r') as f:
    content = f.read()

content = content.replace("Log.e('ApiService: Fetching main categories from: $uri');", "Log.d('ApiService: Fetching main categories from: $uri');")
content = content.replace("Log.e('ApiService: Response status: ${response.statusCode}');", "Log.d('ApiService: Response status: ${response.statusCode}');")
content = content.replace("Log.e('ApiService: Response headers: ${response.headers}');", "Log.d('ApiService: Response headers: ${response.headers}');")
content = re.sub(r"Log\.e\(\s*'ApiService: Response body \(partial\): \$\{response\.body\.substring[^}]+\}\'\);", "Log.d('ApiService: Response body logging skipped');", content)

with open('lib/services/api_service.dart', 'w') as f:
    f.write(content)
