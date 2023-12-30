#!/bin/bash

# Define the path variable
path=$1
new_path=$(echo "$path" | sed 's|^/||')
input=(H1 L1 V1)

for elem in "${input[@]}"; do
  input_string=$(<${elem}.lcf)
  values=$(echo "$input_string" | awk '{print $1, $2, $3, $4}')
  result="$(echo "$values" | tr ' ' '-').gwf"
  sed -i "s|file://localhost/.*|file://localhost/$new_path/$result|g" ${elem}.lcf
done
