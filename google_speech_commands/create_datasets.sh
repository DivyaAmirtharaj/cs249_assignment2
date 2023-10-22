#!/bin/bash

declare -a commands=(
"backward"
"bed"
"bird"
"cat"
"dog"
"down"
"eight"
"five"
"follow"
"forward"
"four"
"go"
"happy"
"house"
"learn"
"left"
"marvin"
"nine"
"no"
"off"
"one"
"on"
"right"
"seven"
"sheila"
"six"
"stop"
"three"
"tree"
"two"
"up"
"visual"
"wow"
"yes"
"zero"
)

# Accept a keyword line argument for the chosen keyword
if [ $# -eq 0 ]; then
    echo "No keyword supplied"
    exit 1
fi
keyword=$1
num_processes=$2

# Check if the keyword is valid
valid_command=false
for i in "${commands[@]}"
do
    if [ "$i" == "$keyword" ]; then
        valid_command=true
        break
    fi
done

if [ "$valid_command" = false ]; then
    echo "Invalid keyword. Please choose one of the following:"
    printf '%s ' "${commands[@]}"
    exit 1
fi


declare -a dirs_to_process=("data/train" "data/test" "data/validation")
for top_dir in "${dirs_to_process[@]}"
do
    mv "$top_dir/$keyword"_sampled "$top_dir/$keyword"
    mkdir -p "$top_dir/other"
done

move_files() {
    file="$1"
    dir="$(dirname "$file")"
    if [ "$dir" != "$top_dir/$keyword" ] && [ "$dir" != "$top_dir/other" ]; then
        echo "Moving $file"
        mv "$file" "$top_dir/other/other.$(basename "$file")"
    fi
}

export -f move_files
export top_dir
export keyword

for top_dir in "${dirs_to_process[@]}"
do
    find "$top_dir" -type f | xargs -I {} -P "$num_processes" bash -c 'move_files "$@"' _ {}

    # remove the empty dirs
    find "$top_dir" -mindepth 1 -type d -empty -delete
done