#!/usr/bin/env bash
#
# Create a christmas tree on the terminal with falling snow
#
# Author: Dave Eddy <dave@daveeddy.com>
# Modified by: James Mascarenhas
# Date: December 24, 2024
# License: MIT

# colors
color_tree=$(tput setaf 2)
color_star=$(tput setaf 227)

# lights - dave matched these to "vintaglo vintage christmas lights"
color_lights=(
	"$(tput setaf 111)"
	"$(tput setaf 208)"
	"$(tput setaf 198)"
	"$(tput setaf 155)"
)
len=${#color_lights[@]}

# the tree itself - each number represents a specific "light" color
IFS= read -r -d '' TREE <<-"EOF"
                  *
                 / \
                / 0 \
               / 1   \
              /       \
             /_ 2  1  _\
              /       \
             /  1   2  \
            /           \
           /   0  3  0   \
          /_        1    _\
           /    2        \
          /  1   0   0    \
         /    3         3  \
        /  2        1       \
        ---------------------
                 |||
                /|||\
EOF
TREE_HEIGHT=18

MESSAGE=(
	"${color_lights[3]}Merry Christmas Noodles!"
	"${color_lights[3]}From James"
	"${color_lights[1]}$ ${color_lights[0]}curl jamesmascarenhas.sh"
)

# Snowflake positions
declare -a snowflakes

# configure terminal for drawing
cleanup() {
	tput rmcup
	tput cnorm
}
trap cleanup EXIT
tput smcup
tput civis

# figure out our size
COLS=$(tput cols)
LINES=$(tput lines)
middle_y=$((LINES / 2 - (TREE_HEIGHT / 2)))

# Initialize snowflakes
generate_snowflakes() {
	for _ in {1..10}; do
		rand_x=$((RANDOM % COLS))
		# Ensure snowflakes don't overwrite the tree or message
		if ((rand_x < COLS / 2 - 10 || rand_x > COLS / 2 + 10)); then
			snowflakes+=("0 $rand_x")  # Add a new snowflake at the top
		fi
	done
}

# current color index
idx=0
while true; do
	# stylize and colorize tree
	t=$color_tree$TREE
	t=${t// \*/ ${color_star}*${color_tree} }
	t=${t// 0 / ${color_lights[idx % len]}o${color_tree} }
	t=${t// 1 / ${color_lights[(idx + 1) % len]}o${color_tree} }
	t=${t// 2 / ${color_lights[(idx + 2) % len]}o${color_tree} }
	t=${t// 3 / ${color_lights[(idx + 3) % len]}o${color_tree} }

	# display the tree
	tput cup "$middle_y" 0
	echo "$t"

	# display the text
	y=$((middle_y + TREE_HEIGHT + 1))
	for line in "${MESSAGE[@]}"; do
		tput cup "$y" $((COLS / 2 - 10))
		echo "$line"
		((y++))
	done

	# Move and display snowflakes
	new_snowflakes=()
	for flake in "${snowflakes[@]}"; do
		snow_y=${flake% *}
		snow_x=${flake#* }
		tput cup "$snow_y" "$snow_x"
		echo -n " "  # Clear the old snowflake
		((snow_y++))
		if ((snow_y < LINES)); then
			tput cup "$snow_y" "$snow_x"
			echo -n "*"
			new_snowflakes+=("$snow_y $snow_x")
		fi
	done
	snowflakes=("${new_snowflakes[@]}")

	# Generate new snowflakes
	generate_snowflakes

	# increment the lights and pause for the animation to play
	((idx++))
	sleep 0.1
done
