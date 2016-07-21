# modification of config created here: https://gist.github.com/cscorley/9144544

try:
    from urllib.parse import quote  # Py 3
except ImportError:
    from urllib2 import quote  # Py 2
import os
import sys

f = None
for arg in sys.argv:
    if arg.endswith('.ipynb'):
        f = arg.split('.ipynb')[0]
        break
post_name = os.path.split(f)[-1]

c = get_config()


c.NbConvertApp.export_format = 'markdown'
c.Application.verbose_crash=True

# modify this function to point your images to a custom path
# by default this saves all images to a directory 'images' in the root of the blog directory
def path2support(path):
    """Turn a file path into a URL"""
    return '/resources/%s/%s' % (post_name, os.path.basename(path))

def relpath2support(content):
    """Turn all relative paths into URLs!!"""
    return content.replace('./', '/resources/%s/' % (post_name))

c.MarkdownExporter.filters = {
    'path2support': path2support,
    'relpath2support': relpath2support,
}

# Preprocess javascript
from IPython.nbconvert.preprocessors import *
class RemoveLanguageMagicsPreprocessor(Preprocessor):
    def preprocess_cell(self, cell, resources, index):
        outputs = cell.get('outputs', [])
        output_types = [t for o in outputs for t in o.get('data', {})]
        if 'text/html' in output_types:
            cell['metadata']['magics_language'] = 'HTML'
        if 'magics_language' in cell['metadata']:
            magics = cell['metadata']['magics_language']
            cell['source'] = cell['source'][len(magics)+3:]
        return cell, resources

class SetMetadataPreprocessor(Preprocessor):
    def preprocess_cell(self, cell, resources, index):
        name = resources['metadata']['name']
        name = name[11:].replace('-', ' ').capitalize()
        resources['metadata']['title'] = name
        return cell, resources

c.Exporter.preprocessors = [
    HighlightMagicsPreprocessor, 
    RemoveLanguageMagicsPreprocessor,
    SetMetadataPreprocessor]

c.NbConvertBase.display_data_priority = [
    'svg',
    'png',
    'html',
    'markdown',
    'jpeg',
    'javascript',
    'text',
    'latex',
    ]