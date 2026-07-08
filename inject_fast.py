import os, re, json, codecs
from translation_dict import translations

print('Starting injection...')
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
    vals = list(key_map.values())
    keys = list(key_map.keys())
    while key in vals and keys[vals.index(key)] != en_text:
        key += 'Alt'
        vals = list(key_map.values())
        keys = list(key_map.keys())
    
    key_map[en_text] = key
    if key not in en_data: en_data[key] = en_text
    if key not in sw_data: sw_data[key] = sw_text

with codecs.open(en_filename, 'w', encoding='utf-8') as f:
    json.dump(en_data, f, indent=2, ensure_ascii=False)
with codecs.open(sw_filename, 'w', encoding='utf-8') as f:
    json.dump(sw_data, f, indent=2, ensure_ascii=False)
print('Updated ARB files.')

compiled_patterns = []
for en_text, key in key_map.items():
    safe_en = re.escape(en_text)
    # Match Text('en_text') or Text("en_text") and optionally leading const
    pat = re.compile(r'(?:const\s+)?Text\(\s*[\'\"]' + safe_en + r'[\'\"]\s*\)')
    rep = f'Text(AppLocalizations.of(context)!.' + key + ')'
    compiled_patterns.append((pat, rep))

import_statement = "import 'package:masoko_tips/l10n/app_localizations.dart';"
directory = 'lib/screens'
files_changed = 0

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            print(f'Processing {filepath}...')
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            original_content = content
            
            for pat, rep in compiled_patterns:
                content = pat.sub(rep, content)
            
            if content != original_content:
                if 'app_localizations.dart' not in content:
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

print(f'Updated {files_changed} files.')
