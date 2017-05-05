#!/bin/sh

echo "Writing .jupyter_config.py"
touch ./.jupyter_config.py
echo 'c = get_config()
### If you want to auto-save .html and .py versions of your notebook:
# modified from: https://github.com/ipython/ipython/issues/8009
import os
from subprocess import check_call

def post_save(model, os_path, contents_manager):
    """post-save hook for converting notebooks to .py scripts"""
    if model["type"] != "notebook":
        return # only do this for notebooks
    d, fname = os.path.split(os_path)
    check_call(["jupyter", "nbconvert", "--to", "rst", fname], cwd=d)
    check_call(["jupyter", "nbconvert", "--to", "html", fname], cwd=d)


c.FileContentsManager.post_save_hook = post_save' > ./.jupyter_config.py

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
