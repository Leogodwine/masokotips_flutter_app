import os
import re

directory = r"d:\flutterProjects\masoko_tips\lib\models"

target_block_regex = re.compile(
    r"if \([^\)]*\.startsWith\('http://'\) \|\| [^\)]*\.startsWith\('https://'\)\) \{\s*"
    r"[^;]*\.replaceAll\(RegExp\(r'/storage/\+/storage/'\), '/storage/'\);\s*"
    r"[^;]*\.replaceAll\(RegExp\(r'/\+/'\), '/'\);\s*"
    r"if \([^\)]*\.startsWith\('https:/'\) && ![^\)]*\.startsWith\('https://'\)\) \{\s*"
    r"[^;]*\.replaceFirst\('https:/', 'https://'\);\s*"
    r"\}\s*"
    r"if \([^\)]*\.startsWith\('http:/'\) && ![^\)]*\.startsWith\('http://'\)\) \{\s*"
    r"[^;]*\.replaceFirst\('http:/', 'http://'\);\s*"
    r"\}\s*"
    r"return[^;]+;\s*"
    r"\}",
    re.MULTILINE
)

def patch_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = target_block_regex.sub(
        r"if (path.startsWith('http://') || path.startsWith('https://')) {\n      return path;\n    }", 
        content
    )

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Patched fragile regex in: {os.path.basename(filepath)}")

for f in os.listdir(directory):
    if f.endswith('.dart'):
        patch_file(os.path.join(directory, f))

print("Patching complete!")
