import os
import sys
sys.path.insert(0, os.path.abspath('../src'))

project = "PIC mesh helpers"
author = "Artemii Kravchuk"
release = "1.0.0"

extensions = ['myst_parser']  # enable markdown support

templates_path = ['_templates']
exclude_patterns = []
html_theme = 'sphinx_rtd_theme'  # or 'sphinx_rtd_theme'

source_suffix = ['.rst', '.md']
