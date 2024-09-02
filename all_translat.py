import json
import os
from googletrans import Translator

def load_json_file(file_path):
    with open(file_path, 'r', encoding='utf-8-sig') as file:
        return json.load(file)

def save_json_file(file_path, data):
    with open(file_path, 'w', encoding='utf-8-sig') as file:
        json.dump(data, file, ensure_ascii=False, indent=4)

def translate_text(translator, text, target_lang):
    try:
        translated = translator.translate(text, dest=target_lang)
        return translated.text
    except Exception as e:
        print(f"Error translating text: {e}")
        return None

def process_files(src_file, ar_file, tr_file, translator):
    en_data = load_json_file(src_file)
    ar_data = load_json_file(ar_file)
    tr_data = load_json_file(tr_file)

    updated_ar_data = ar_data.copy()
    updated_tr_data = tr_data.copy()

    for key, en_text in en_data.items():
        if key in ar_data and ar_data[key] != en_text:
            # If the word is already translated in Arabic, skip it
            continue
        if key in tr_data and tr_data[key] != en_text:
            # If the word is already translated in Turkish, skip it
            continue

        if any(c in en_text for c in 'أبتثجحخدذرزسشصضطظعغفقكلمنهـوي'):
            # If the word contains Arabic characters, translate it to English
            en_translation = translate_text(translator, en_text, 'en')
            if en_translation:
                updated_ar_data[key] = en_translation
        else:
            # Translate the word to Arabic and Turkish
            ar_translation = translate_text(translator, en_text, 'ar')
            tr_translation = translate_text(translator, en_text, 'tr')
            if ar_translation:
                updated_ar_data[key] = ar_translation
            if tr_translation:
                updated_tr_data[key] = tr_translation

    save_json_file(ar_file, updated_ar_data)
    save_json_file(tr_file, updated_tr_data)

def main():
    src_file = 'lib/l10n/intl_en.arb'
    ar_file = 'lib/l10n/intl_ar.arb'
    tr_file = 'lib/l10n/intl_tr.arb'

    translator = Translator()
    process_files(src_file, ar_file, tr_file, translator)

if __name__ == '__main__':
    main()


#  يقوم بترجمة من الانكليزي الى العربي و الخ
# يقوم هذا الكود بترجمة ملفات الترجمة الى اللغة الاساسية للملف
# ويعيد حفظ الملفات بعد الترجمة
# ويعمل على ملفين فقط حاليا
# يمكن تعديل الكود ليعمل على المزيد من الملفات
# كود تشغيل الكود
# python3 all_translat.py