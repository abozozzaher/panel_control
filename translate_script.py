import os
import json
from googletrans import Translator

def translate_file(src_file, target_lang):
    # Initialize the translator
    translator = Translator()

    # Read the source file
    with open(src_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Generate the target file name
    src_filename = os.path.basename(src_file)
    target_filename = src_filename.replace("en", target_lang)
    target_file = os.path.join(os.path.dirname(src_file), target_filename)

    # Read the target file if it exists
    if os.path.exists(target_file):
        with open(target_file, 'r', encoding='utf-8') as f:
            translated_data = json.load(f)
    else:
        translated_data = {}

    # Translate each value in the source file if it's not already translated
    for key, value in data.items():
        if isinstance(value, str) and key not in translated_data:
            translated_value = translator.translate(value, dest=target_lang).text
            translated_data[key] = translated_value
        elif key not in translated_data:
            translated_data[key] = value

    # Write the translated data to the target file
    with open(target_file, 'w', encoding='utf-8') as f:
        json.dump(translated_data, f, ensure_ascii=False, indent=4)

    print(f"Translated file saved as {target_file}")

# Usage
src_file = 'lib/l10n/intl_en.arb'
target_lang = 'tr'  # Set the target language code
translate_file(src_file, target_lang)




#تغير رمز ال ar الى اللغة التي اريدها
#python3 translate_script.py
#ثم شغل الامر التالي
#flutter pub run intl_utils:generate