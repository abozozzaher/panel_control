import os
import re
import json

def process_file(file_path, translations):
    """Process the given file to find and replace texts and update translations."""
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Find all occurrences of Text('...')
    matches = re.findall(r"Text\('([^']*)'\)", content)

    for match in matches:
        if '$' in match:
            continue

        # Convert match to the new format
        new_key = match.replace(' ', '_').lower()
        new_value = match

        if new_key not in translations:
            translations[new_key] = new_value

        # Replace Text('...') with Text(S().key)
        content = content.replace(f"Text('{match}')", f"Text(S().{new_key})")

    with open(file_path, 'w', encoding='utf-8') as file:
        file.write(content)

def update_ar_files(ar_files, translations):
    """Update .arb files with the new translations."""
    for ar_file in ar_files:
        if not os.path.isfile(ar_file):
            continue
        
        with open(ar_file, 'r', encoding='utf-8') as file:
            content = file.read()

        # Convert content to JSON
        try:
            content_json = json.loads(content)
        except json.JSONDecodeError:
            content_json = {}

        # Add new translations
        for key, value in translations.items():
            if key not in content_json:
                content_json[key] = value

        # Write the updated content
        with open(ar_file, 'w', encoding='utf-8') as file:
            json.dump(content_json, file, ensure_ascii=False, indent=4)

def main():
    lib_dir = 'lib'
    ar_files = {
        'ar': 'lib/l10n/intl_ar.arb',
        'tr': 'lib/l10n/intl_tr.arb',
        'en': 'lib/l10n/intl_en.arb'
    }
    translations = {}

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file), translations)

    # Update files based on their language
    for lang, file_path in ar_files.items():
        if os.path.isfile(file_path):
            # Filter translations for the current language file
            lang_translations = {k: v for k, v in translations.items() if lang in file_path}
            update_ar_files([file_path], lang_translations)

if __name__ == '__main__':
    main()

# لتشغيل الكود:
# 1. لتحديث النصوص واستخراج الترجمات:
# python3 extract_texts.py
# 2. لترجمة النصوص:
# python3 translate_script.py
# 3. لتحديث ملفات اللغات:
# flutter pub run intl_utils:generate
