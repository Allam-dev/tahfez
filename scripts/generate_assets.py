import os
import re

# ==================== CONFIGURATION ====================
# Since this script lives in 'scripts/', the project root is one level up ('..')
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))

# Define target paths relative to the project root
ASSETS_DIR = os.path.join(PROJECT_ROOT, 'assets')
OUTPUT_FILE_PATH = os.path.join(PROJECT_ROOT, 'lib', 'app', 'assets', 'assets.dart')

# Directories to exclude (Keep using forward slashes relative to the assets root)
EXCLUDE_DIRS = {
    'assets/translation',
}
# =======================================================

def snake_to_camel(snake_str):
    """Converts string/file_name to camelCase for variables."""
    clean_str = re.sub(r'[^a-zA-Z0-9]', '_', snake_str.split('.')[0])
    components = clean_str.split('_')
    components = [c for c in components if c]
    if not components:
        return "asset"
    return components[0].lower() + ''.join(x.title() for x in components[1:])

def path_to_class_name(dir_path):
    """Converts a directory path to IconsImagesAssets naming convention."""
    # Get the path relative to the PROJECT_ROOT to properly parse the folder names
    relative_path = os.path.relpath(dir_path, PROJECT_ROOT)
    parts = relative_path.split(os.sep)
    
    relevant_parts = [p for p in parts if p and p.lower() != 'assets']
    if not relevant_parts:
        return "Assets"
        
    reversed_parts = reversed(relevant_parts)
    class_name = ''.join(p.replace('_', ' ').replace('-', ' ').title().replace(' ', '') for p in reversed_parts) + "Assets"
    return class_name

def should_ignore(dir_path, exclude_set):
    """Checks if the current directory or its parent paths are in the exclusion set."""
    # Convert absolute walk path to a relative path matching the assets hierarchy format
    relative_path = os.path.relpath(dir_path, PROJECT_ROOT).replace(os.sep, '/')
    
    for exclude in exclude_set:
        if relative_path == exclude or relative_path.startswith(exclude + '/'):
            return True
    return False

def generate_assets_class():
    if not os.path.exists(ASSETS_DIR):
        print(f"Error: The directory '{ASSETS_DIR}' does not exist.")
        return

    output_dir = os.path.dirname(OUTPUT_FILE_PATH)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)

    generated_classes = []

    for root, dirs, files in os.walk(ASSETS_DIR):
        if should_ignore(root, EXCLUDE_DIRS):
            continue
            
        valid_files = [f for f in files if not f.startswith('.')]
        if not valid_files:
            continue 

        class_name = path_to_class_name(root)
        class_content = f"class {class_name} {{\n"
        class_content += f"  {class_name}._();\n\n"
        
        for file in sorted(valid_files):
            var_name = snake_to_camel(file)
            # Find path relative to project root so it starts with 'assets/...' in Dart
            relative_file_path = os.path.relpath(os.path.join(root, file), PROJECT_ROOT)
            full_path = relative_file_path.replace(os.sep, '/')
            class_content += f"  static const String {var_name} = '{full_path}';\n"
            
        class_content += "}\n"
        generated_classes.append(class_content)

    with open(OUTPUT_FILE_PATH, 'w', encoding='utf-8') as f:
        f.write("// GENERATED CODE - DO NOT MODIFY BY HAND\n")
        f.write(f"// Generated using asset automation script.\n\n")
        f.write('\n'.join(generated_classes))

    print(f"🎉 Successfully generated asset classes at: {OUTPUT_FILE_PATH}")

if __name__ == '__main__':
    generate_assets_class()