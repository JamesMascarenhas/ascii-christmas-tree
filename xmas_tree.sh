#!/usr/bin/env bash
#
# Create a christmas tree with twinkling stars on the terminal
#
# Author: Dave Eddy <dave@daveeddy.com>
# Modified by: James Mascarenhas
# License: MIT

# colors
color_tree=$(tput setaf 2)
color_star=$(tput setaf 227)
color_twinkle=$(tput setaf 15)  # Bright white for twinkling stars

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

# star locations around the tree
star_positions=(
	"$((middle_y - 2)) 15"
	"$((middle_y - 3)) 20"
	"$((middle_y - 2)) 25"
	"$((middle_y - 4)) 18"
	"$((middle_y - 4)) 22"
)

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

	# display the twinkling stars
	for pos in "${star_positions[@]}"; do
		star_y=$(echo "$pos" | cut -d' ' -f1)
		star_x=$(echo "$pos" | cut -d' ' -f2)

		if ((RANDOM % 2)); then
			# Show a twinkling star
			tput cup "$star_y" "$star_x"
			echo -n "${color_twinkle}*"
		else
			# Clear the position
			tput cup "$star_y" "$star_x"
			echo -n " "
		fi
	done

	# display the text
	y=$((middle_y + 7))
	for line in "${MESSAGE[@]}"; do
		tput cup "$y" 35
		echo "$line"
		((y++))
	done

	# increment the lights and pause for the animation to play
	((idx++))
	sleep 1
done
