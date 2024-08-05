import os
import re

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

        for key, value in translations.items():
            pattern = f'"{key}" :'
            if pattern not in content:
                content += f'\n"{key}" : "{value}",'

        with open(ar_file, 'w', encoding='utf-8') as file:
            file.write(content)

def main():
    lib_dir = 'lib'
    ar_files = ['lib/l10n/intl_ar.arb', 'lib/l10n/intl_en.arb']
    translations = {}

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file), translations)

    update_ar_files(ar_files, translations)

if __name__ == '__main__':
    main()


# لعمل ترجمة للملفات اولاً نقوم بتشغيل هذا الكود
# python3 extract_texts.py 
# ثم هذا ليقوم باضافة الكلمات الى ملف اللغات
# flutter pub run intl_utils:generate