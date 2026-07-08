import os
import re
import json

directory = 'lib/screens'
extracted_strings = set()

# Regex to find Text('something') or Text("something")
# that don't contain $ (string interpolation)
text_pattern = re.compile(r'Text\(\s*\'([^\'$]+)\'\s*\)|Text\(\s*\"([^\$]+)\"\s*\)')

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = text_pattern.findall(content)
                for m1, m2 in matches:
                    text_val = m1 if m1 else m2
                    if text_val and text_val.strip() != '':
                        extracted_strings.add(text_val)

# Ignore ones we already translated or are not words
ignored_patterns = ['/', '.', '-', ' ', ':', '|', '%']
filtered = []
for s in extracted_strings:
    if len(s) <= 1 or all(c in ignored_patterns for c in s):
        continue
    filtered.append(s)

with open('extracted_strings.json', 'w', encoding='utf-8') as f:
    json.dump(filtered, f, indent=2, ensure_ascii=False)

print(f'Extracted {len(filtered)} unique strings.')
