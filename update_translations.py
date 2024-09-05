import os
import json
import string

def remove_punctuation(text):
    """Remove punctuation, including apostrophes, from the given text."""
    return text.translate(str.maketrans('', '', string.punctuation + "'"))

def process_file(file_path, search_text, translations):
    """Process the given file to find and replace texts and update translations."""
    clean_search_text = remove_punctuation(search_text)
    
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    # Find and replace occurrences of the search text
    if search_text in content:
        # Create a key from the cleaned search text
        new_key = clean_search_text.replace(' ', '_').lower()

        # Clean the search text value by removing apostrophes
        new_value = search_text.replace("'", "")

        if new_key not in translations:
            translations[new_key] = new_value

        # Replace the search text with the key
        content = content.replace(search_text, f"S().{new_key}")

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
    ar_files = ['lib/l10n/intl_ar.arb', 'lib/l10n/intl_tr.arb', 'lib/l10n/intl_en.arb']
    translations = {}

    # Input the text to search and replace
    search_text = input("Enter the text to search and replace: ")

    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                process_file(os.path.join(root, file), search_text, translations)

    update_ar_files(ar_files, translations)

if __name__ == '__main__':
    main()


# لتشغيل السكربت:
# python3 your_script_name.py
# هذا السكربت لتعديل جمل فقط
# بعد تشغيل السكربت يطلب مني اضافة الجملة تحت

# لتشغيل السكربت:
# python3 your_script_name.py

# python3 update_translations.py
# flutter pub run intl_utils:generate
