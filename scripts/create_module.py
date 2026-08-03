import argparse
import importlib.util
import os
import re
import sys

TEMPLATE_MODULE = "xyz"
WORD_RE = re.compile(r"[A-Z]+(?=[A-Z][a-z]|[0-9]|$)|[A-Z]?[a-z]+|[0-9]+")
SCREEN_SUFFIXES = ("add", "details", "list", "update")


def split_words(name: str) -> list[str]:
	cleaned = name.strip()
	if not cleaned:
		return []

	cleaned = cleaned.replace("-", "_").replace(" ", "_")
	parts = [part for part in cleaned.split("_") if part]
	words: list[str] = []
	for part in parts:
		tokens = WORD_RE.findall(part)
		if tokens:
			words.extend(tokens)
		else:
			words.append(part)
	return words


def to_snake(words: list[str]) -> str:
	return "_".join(word.lower() for word in words)


def to_pascal(words: list[str]) -> str:
	converted = []
	for word in words:
		if word.isupper():
			converted.append(word)
		else:
			converted.append(word[:1].upper() + word[1:].lower())
	return "".join(converted)


def transform_content(content: str, snake: str, pascal: str) -> str:
	replacements = [
		("modules/xyz", f"modules/{snake}"),
		("Xyz", pascal),
		("XYZ", pascal),
		("xyz", snake),
	]
	for old, new in replacements:
		content = content.replace(old, new)
	return content


def generate_module(
	module_name: str,
	template_root: str,
	modules_root: str,
) -> tuple[int, int]:
	words = split_words(module_name)
	if not words:
		print(f"Skipping empty module name: {module_name!r}")
		return 0, 0

	snake = to_snake(words)
	pascal = to_pascal(words)
	module_root = os.path.join(modules_root, snake)

	created = 0
	skipped = 0

	for dirpath, _, filenames in os.walk(template_root):
		rel_dir = os.path.relpath(dirpath, template_root)
		if rel_dir == ".":
			rel_dir = ""
		target_rel_dir = rel_dir.replace(TEMPLATE_MODULE, snake)
		target_dir = os.path.join(module_root, target_rel_dir)
		os.makedirs(target_dir, exist_ok=True)

		for filename in filenames:
			target_filename = filename.replace(TEMPLATE_MODULE, snake)
			src_file = os.path.join(dirpath, filename)
			dest_file = os.path.join(target_dir, target_filename)

			if os.path.exists(dest_file):
				skipped += 1
				continue

			with open(src_file, "r", encoding="utf-8") as handle:
				content = handle.read()

			new_content = transform_content(content, snake, pascal)
			with open(dest_file, "w", encoding="utf-8", newline="\n") as handle:
				handle.write(new_content)
			created += 1

	print(f"{module_name} -> {snake} / {pascal}: created {created}, skipped {skipped}")
	return created, skipped





def update_main_di(module_name: str, root_dir: str) -> int:
	words = split_words(module_name)
	if not words:
		return 0

	snake = to_snake(words)
	pascal = to_pascal(words)
	main_di_path = os.path.join(root_dir, "lib", "core", "di", "main_di.dart")

	if not os.path.isfile(main_di_path):
		print(f"main_di.dart not found: {main_di_path}", file=sys.stderr)
		return 1

	repo_type = f"{pascal}Repo"
	fake_impl = f"{pascal}RepoFakeImpl"
	repo_import = (
		"import 'package:tahfez/modules/"
		f"{snake}/domain/{snake}_repo.dart';"
	)
	fake_import = (
		"import 'package:tahfez/modules/"
		f"{snake}/data/repos/{snake}_repo_fake_impl.dart';"
	)
	register_line = (
		f"  getIt.registerFactory<{repo_type}>(() => {fake_impl}());"
	)

	with open(main_di_path, "r", encoding="utf-8") as handle:
		content = handle.read()

	updated = content

	if repo_import not in updated or fake_import not in updated:
		lines = updated.splitlines()
		last_import_index = -1
		for index, line in enumerate(lines):
			if line.startswith("import "):
				last_import_index = index
		if last_import_index != -1:
			imports_to_add = []
			if repo_import not in updated:
				imports_to_add.append(repo_import)
			if fake_import not in updated:
				imports_to_add.append(fake_import)
			insert_index = last_import_index + 1
			lines[insert_index:insert_index] = imports_to_add
			updated = "\n".join(lines)
			if content.endswith("\n"):
				updated += "\n"

	if register_line not in updated:
		lines = updated.splitlines()
		insert_index = None
		for index in range(len(lines) - 1, -1, -1):
			if lines[index].strip() == "}":
				insert_index = index
				break
		if insert_index is not None:
			lines[insert_index:insert_index] = ["", register_line]
			updated = "\n".join(lines)
			if content.endswith("\n"):
				updated += "\n"

	if updated != content:
		with open(main_di_path, "w", encoding="utf-8", newline="\n") as handle:
			handle.write(updated)

	return 0


def main(argv: list[str]) -> int:
	parser = argparse.ArgumentParser(
		description="Generate module scaffolding from lib/modules/xyz template.",
		usage="python create_module.py <module1> <module2> ...",
	)
	parser.add_argument(
		"modules",
		nargs="*",
		help="Module names in camelCase or snake_case.",
	)
	args = parser.parse_args(argv)

	if not args.modules:
		parser.print_usage()
		return 2

	# Get the directory where the script lives (e.g., your_project/scripts)
	script_dir = os.path.dirname(os.path.abspath(__file__))

	# Go up one level to hit the root project directory (e.g., your_project)
	root_dir = os.path.abspath(os.path.join(script_dir, ".."))

	# These will now resolve correctly to your_project/lib/...
	template_root = os.path.join(root_dir, "lib", "modules", TEMPLATE_MODULE)
	modules_root = os.path.join(root_dir, "lib", "modules")

	if not os.path.isdir(template_root):
		print(f"Template module not found: {template_root}", file=sys.stderr)
		return 1

	total_created = 0
	total_skipped = 0
	total_screen_errors = 0
	total_di_errors = 0
	seen: set[str] = set()

	for module_name in args.modules:
		if module_name in seen:
			continue
		seen.add(module_name)
		created, skipped = generate_module(module_name, template_root, modules_root)
		total_created += created
		total_skipped += skipped
		total_di_errors += update_main_di(module_name, root_dir)

	print(f"Done. Created {total_created} files, skipped {total_skipped}.")
	if total_screen_errors or total_di_errors:
		return 1
	return 0


if __name__ == "__main__":
	raise SystemExit(main(sys.argv[1:]))
