import os
import re
import json
import codecs
from translation_dict import translations

# 1. Generate ARB dictionaries
en_filename = 'lib/l10n/app_en.arb'
sw_filename = 'lib/l10n/app_sw.arb'

with codecs.open(en_filename, 'r', encoding='utf-8') as f:
    en_data = json.load(f)
with codecs.open(sw_filename, 'r', encoding='utf-8') as f:
    sw_data = json.load(f)

def make_key(s):
    s = re.sub(r'[^a-zA-Z0-9\s]', '', s)
    words = s.split()
    if not words: return 'emptyKey'
    return words[0].lower() + ''.join(w.capitalize() for w in words[1:6])

key_map = {}
for en_text, sw_text in translations.items():
    key = make_key(en_text)
    # Just in case of duplicates
    while key in key_map.values() and list(key_map.keys())[list(key_map.values()).index(key)] != en_text:
        key += 'Alt'
    
    key_map[en_text] = key
    
    if key not in en_data:
        en_data[key] = en_text
    if key not in sw_data:
        sw_data[key] = sw_text

with codecs.open(en_filename, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, indent=2, ensure_ascii=False)
with codecs.open(sw_filename, 'w', encoding='utf-8') as f:
    json.dump(sw_data, f, indent=2, ensure_ascii=False)

print("Updated ARB files.")

# 2. Inject into dart files
directory = 'lib/screens'
import_statement = "import 'package:masoko_tips/l10n/app_localizations.dart';"

def escape_regex(s):
    return re.escape(s)

files_changed = 0

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            for en_text, key in key_map.items():
                # We need to replace Text('en_text') or const Text('en_text')
                # and also with double quotes.
                
                # We use regex to match both with and without const
                # pattern: (?:const\s+)?Text\(\s*['"]EN_TEXT['"]\s*\)
                safe_en = escape_regex(en_text)
                pattern = r'(?:const\s+)?Text\(\s*[\'"]' + safe_en + r'[\'"]\s*\)'
                replacement = f'Text(AppLocalizations.of(context)!.{key})'
                
                content = re.sub(pattern, replacement, content)
            
            if content != original_content:
                # Add import if missing
                if 'app_localizations.dart' not in content:
                    # Find last import
                    import_idx = content.rfind('import ')
                    if import_idx != -1:
                        end_of_line = content.find('\n', import_idx)
                        if end_of_line != -1:
                            content = content[:end_of_line+1] + import_statement + '\n' + content[end_of_line+1:]
                    else:
                        content = import_statement + '\n\n' + content
                
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                files_changed += 1

print(f"Updated {files_changed} files.")
