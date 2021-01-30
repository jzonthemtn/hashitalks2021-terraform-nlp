#!/bin/bash

echo "Executing create_pkg.sh..."

dir_name=lambda_dist_pkg/
mkdir -p $dir_name

# Create and activate virtual environment...
python3 -m venv ./$dir_name/venv
source $dir_name/venv/bin/activate

# Installing python dependencies...
FILE=$dir_name/lambda_function/requirements.txt

if [ -f "$FILE" ]; then
  echo "Installing dependencies..."
  echo "From: requirement.txt file exists..."
  pip install -r "$FILE"

else
  echo "Error: requirement.txt does not exist!"
fi

# Deactivate virtual environment...
deactivate

# Create deployment package...
echo "Creating deployment package..."
cp $dir_name/venv/lib/$runtime/site-packages/

#cd env_$function_name/lib/$runtime/site-packages/
#cp -r . $path_cwd/$dir_name
#cp -r $path_cwd/lambda_function/ $path_cwd/$dir_name

# Removing virtual environment folder...
echo "Removing virtual environment folder..."
rm -rf ./$dir_name/venv

echo "Finished script execution!"
