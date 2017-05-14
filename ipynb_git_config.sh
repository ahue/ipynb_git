#!/bin/sh

echo "Writing .jupyter_config.py"
touch ./.jupyter_config.py
echo 'c = get_config()
### If you want to auto-save .html and .py versions of your notebook:
# modified from: https://gist.github.com/whatalnk/c8b3207267d798be713ea4a4664e2ccf
import os
import io
from nbconvert.exporters.html import HTMLExporter
from nbconvert.exporters.rst import RSTExporter
import nbformat
from notebook.utils import to_api_path

def pre_save(model, path, contents_manager, **kwargs):
    """On save store the notebook als .html (with output) and .rst (without output)"""

    # only run on notebooks
    if model["type"] != "notebook":
        return
    # only run on nbformat v4
    if model["content"]["nbformat"] != 4:
        return

    log = contents_manager.log    

    base, ext = os.path.splitext(path)

    # Create a NotebookNode object from current model
    nbmodel = nbformat.from_dict(model["content"])

    # Create HTML before removing output
    _html_exporter = HTMLExporter(parent=contents_manager)

    html_fname = base + ".html"
    html, html_resources = _html_exporter.from_notebook_node(nbmodel)
    html_fname = base + html_resources.get("output_extension", ".html")
    log.info("Saving HTML /%s", to_api_path(html_fname, contents_manager.root_dir))
    with io.open(html_fname, "w", encoding="utf-8") as f:
        f.write(html)

    # Remove output for rst    
    for c in nbmodel.cells:
        if c.cell_type != "code":
          continue
        c.outputs = []
        c.execution_count = None    

    # Export rst
    _rst_exporter = RSTExporter(parent=contents_manager)

    rst_fname = base + ".rst"
    rst, resources = _rst_exporter.from_notebook_node(nbmodel)
    rst_fname = base + resources.get("output_extension", ".rst")
    log.info("Saving rst /%s", to_api_path(rst_fname, contents_manager.root_dir))
    with io.open(rst_fname, "w", encoding="utf-8") as f:
        f.write(rst)

c.FileContentsManager.pre_save_hook = pre_save' > ./.jupyter_config.py

# Configure .gitignore
echo "Adding *.ipynb to .gitignore"
touch ./.gitignore
echo "*.ipynb" >> ./.gitignore

echo "Writing git post-checkout hook"
touch ./.git/hooks/post-checkout
echo '#!/bin/sh

echo "Post checkout hook triggered"
changed_files="$(git diff-tree -r --name-only --no-commit-id $1 $2)"
 
check_run() {
  echo "$changed_files" | grep "$1" && eval "$2"
}

check_run_all() {
  echo "$changed_files" | grep "$1" | while read line ; do $(eval "echo $line | $2") ; done 
}

check_run_all \\.rst$ "cut -d'\''.'\'' -f1 | awk '\''{print \"rst2ipynb\",\$0\".rst -o\",\$0\".ipynb\"}'\''"' > ./.git/hooks/post-checkout

echo "Writing git post-merge hook"
touch ./.git/hooks/post-merge
echo '#!/bin/sh

echo "Post merge hook triggered"
changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
 
check_run() {
  echo "$changed_files" | grep "$1" && eval "$2"
}

check_run_all() {
  echo "$changed_files" | grep "$1" | while read line ; do $(eval "echo $line | $2") ; done 
}

check_run_all \\.rst$ "cut -d'\''.'\'' -f1 | awk '\''{print \"rst2ipynb\",\$0\".rst -o\",\$0\".ipynb\"}'\''"' > ./.git/hooks/post-merge

mkdir ./scripts
touch ./scripts/nwbgit.sh
echo "#!/bin/sh
jupyter notebook --config=./.jupyter_config.py --no-browser" > ./scripts/nwbgit.sh

echo "Use $> nbwgit in this directory to start the notebook"
alias nbwgit='jupyter notebook --config=./.jupyter_config.py --no-browser'
